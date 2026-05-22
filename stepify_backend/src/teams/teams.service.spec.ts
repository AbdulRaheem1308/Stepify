import { Test, TestingModule } from '@nestjs/testing';
import { TeamsService } from './teams.service';
import { PrismaService } from '../prisma/prisma.service';
import { BadRequestException, ForbiddenException, NotFoundException } from '@nestjs/common';

const mockPrismaService = {
  teamMember: { findMany: jest.fn(), create: jest.fn(), update: jest.fn(), deleteMany: jest.fn() },
  team: { findMany: jest.fn(), findUnique: jest.fn(), create: jest.fn(), update: jest.fn(), delete: jest.fn() },
  user: { findMany: jest.fn() },
  teamChallenge: { deleteMany: jest.fn(), findMany: jest.fn() },
  teamBattle: { findFirst: jest.fn(), create: jest.fn() },
  $transaction: jest.fn((queries) => {
    if (typeof queries === 'function') { return queries(mockPrismaService); }
    return Promise.resolve(queries);
  }),
};

describe('TeamsService', () => {
  let service: TeamsService;
  let prisma: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TeamsService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();
    service = module.get<TeamsService>(TeamsService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getMyTeams', () => {
    it('should return properly formatted user teams', async () => {
      mockPrismaService.teamMember.findMany.mockResolvedValue([
        { userId: 'u1', role: 'captain', team: { id: 't1', name: 'Team 1', inviteCode: 'CODE1', members: [{ id: 'm1' }] } },
      ]);
      const result = await service.getMyTeams('u1');
      expect(result.length).toBe(1);
      expect(result[0].inviteCode).toBe('CODE1');
      expect(result[0].memberCount).toBe(1);
    });
  });

  describe('getPublicTeams', () => {
    it('should return public teams excluding user teams', async () => {
      mockPrismaService.teamMember.findMany.mockResolvedValue([{ teamId: 't1' }]);
      mockPrismaService.team.findMany.mockResolvedValue([{ id: 't2', name: 'Team 2', members: [] }]);
      const result = await service.getPublicTeams('u1');
      expect(result.length).toBe(1);
      expect(result[0].id).toBe('t2');
    });
  });

  describe('getTeamDetails', () => {
    it('should throw Error if team not found', async () => {
      mockPrismaService.team.findUnique.mockResolvedValue(null);
      await expect(service.getTeamDetails('t1', 'u1')).rejects.toThrow('Team not found');
    });
    it('should return formatted team details', async () => {
      mockPrismaService.team.findUnique.mockResolvedValue({ id: 't1', captainId: 'u1', members: [{ userId: 'u1', role: 'captain', totalSteps: 100 }] });
      mockPrismaService.user.findMany.mockResolvedValue([{ id: 'u1', name: 'Captain' }]);
      const result = await service.getTeamDetails('t1', 'u1');
      expect(result.captainName).toBe('Captain');
    });
  });

  describe('createTeam', () => {
    it('should create team and add captain', async () => {
      mockPrismaService.team.create.mockResolvedValue({ id: 't1' });
      mockPrismaService.teamMember.create.mockResolvedValue({});
      jest.spyOn(service, 'getTeamDetails').mockResolvedValue({} as any);
      await service.createTeam('u1', { name: 'New Team', isPublic: false });
      expect(mockPrismaService.team.create).toHaveBeenCalled();
    });
  });

  describe('joinTeam', () => {
    it('should throw Error if team is full', async () => {
      mockPrismaService.team.findUnique.mockResolvedValue({ maxMembers: 1, members: [{ id: 'm1' }] });
      await expect(service.joinTeam('t1', 'u1')).rejects.toThrow('Team is full');
    });
  });

  describe('leaveTeam', () => {
    it('should handle standard member leaving', async () => {
      mockPrismaService.team.findUnique.mockResolvedValue({ id: 't1', captainId: 'u2', members: [{ userId: 'u1' }] });
      const res = await service.leaveTeam('t1', 'u1');
      expect(res.success).toBe(true);
    });
  });

  describe('initiateBattle', () => {
    it('should throw BadRequest if same team', async () => {
      await expect(service.initiateBattle('t1', 't1', 'u1')).rejects.toThrow(BadRequestException);
    });
    it('should create a battle successfully', async () => {
      mockPrismaService.team.findUnique.mockResolvedValueOnce({ captainId: 'u1' }).mockResolvedValueOnce({ id: 't2' });
      mockPrismaService.teamBattle.findFirst.mockResolvedValue(null);
      mockPrismaService.teamBattle.create.mockResolvedValue({ id: 'bnew' });
      const res = await service.initiateBattle('t1', 't2', 'u1');
      expect(res.success).toBe(true);
    });
  });

  describe('deleteTeam', () => {
    it('should throw Forbidden if not captain', async () => {
      mockPrismaService.team.findUnique.mockResolvedValue({ captainId: 'u2' });
      await expect(service.deleteTeam('t1', 'u1')).rejects.toThrow(ForbiddenException);
    });
    it('should delete team successfully', async () => {
      mockPrismaService.team.findUnique.mockResolvedValue({ captainId: 'u1', teamChallenges: [], members: [{ userId: 'u1' }] });
      const res = await service.deleteTeam('t1', 'u1');
      expect(res.success).toBe(true);
    });
  });
});
