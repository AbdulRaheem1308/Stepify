import { Test, TestingModule } from '@nestjs/testing';
import { TeamsController } from './teams.controller';
import { TeamsService } from './teams.service';
import { CreateTeamDto, JoinTeamDto, InitiateBattleDto } from './dto/team.dto';

describe('TeamsController', () => {
  let controller: TeamsController;
  let service: TeamsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TeamsController],
      providers: [
        {
          provide: TeamsService,
          useValue: {
            getMyTeams: jest.fn(),
            getPublicTeams: jest.fn(),
            getTeamLeaderboard: jest.fn(),
            getTeamDetails: jest.fn(),
            getTeamChallenges: jest.fn(),
            createTeam: jest.fn(),
            joinTeam: jest.fn(),
            leaveTeam: jest.fn(),
            initiateBattle: jest.fn(),
            deleteTeam: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<TeamsController>(TeamsController);
    service = module.get<TeamsService>(TeamsService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getMyTeams', () => {
    it('should get my teams', async () => {
      const req = { user: { id: 'u1' } } as any;
      await controller.getMyTeams(req);
      expect(service.getMyTeams).toHaveBeenCalledWith('u1');
    });
  });

  describe('getPublicTeams', () => {
    it('should get public teams', async () => {
      const req = { user: { id: 'u1' } } as any;
      await controller.getPublicTeams(req);
      expect(service.getPublicTeams).toHaveBeenCalledWith('u1');
    });
  });

  describe('getLeaderboard', () => {
    it('should get leaderboard', async () => {
      await controller.getLeaderboard();
      expect(service.getTeamLeaderboard).toHaveBeenCalled();
    });
  });

  describe('getTeamDetails', () => {
    it('should get team details', async () => {
      const req = { user: { id: 'u1' } } as any;
      await controller.getTeamDetails('t1', req);
      expect(service.getTeamDetails).toHaveBeenCalledWith('t1', 'u1');
    });
  });

  describe('getTeamChallenges', () => {
    it('should get team challenges', async () => {
      await controller.getTeamChallenges('t1');
      expect(service.getTeamChallenges).toHaveBeenCalledWith('t1');
    });
  });

  describe('createTeam', () => {
    it('should create team', async () => {
      const req = { user: { id: 'u1' } } as any;
      const dto: CreateTeamDto = { name: 'Team A', description: 'Desc', isPublic: true };
      await controller.createTeam(req, dto);
      expect(service.createTeam).toHaveBeenCalledWith('u1', dto);
    });
  });

  describe('joinTeam', () => {
    it('should join team', async () => {
      const req = { user: { id: 'u1' } } as any;
      const dto: JoinTeamDto = { inviteCode: 'CODE123' };
      await controller.joinTeam('t1', req, dto);
      expect(service.joinTeam).toHaveBeenCalledWith('t1', 'u1', 'CODE123');
    });
  });

  describe('leaveTeam', () => {
    it('should leave team', async () => {
      const req = { user: { id: 'u1' } } as any;
      await controller.leaveTeam('t1', req);
      expect(service.leaveTeam).toHaveBeenCalledWith('t1', 'u1');
    });
  });

  describe('initiateBattle', () => {
    it('should initiate battle', async () => {
      const req = { user: { id: 'u1' } } as any;
      const dto: InitiateBattleDto = { opponentTeamId: 't2' };
      await controller.initiateBattle('t1', dto, req);
      expect(service.initiateBattle).toHaveBeenCalledWith('t1', 't2', 'u1');
    });
  });

  describe('deleteTeam', () => {
    it('should delete team', async () => {
      const req = { user: { id: 'u1' } } as any;
      await controller.deleteTeam('t1', req);
      expect(service.deleteTeam).toHaveBeenCalledWith('t1', 'u1');
    });
  });
});
