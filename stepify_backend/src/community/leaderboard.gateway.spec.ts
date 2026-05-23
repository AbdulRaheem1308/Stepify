import { Test, TestingModule } from '@nestjs/testing';
import { LeaderboardGateway } from './leaderboard.gateway';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';

describe('LeaderboardGateway', () => {
  let gateway: LeaderboardGateway;
  let mockPrisma: any;
  let mockJwtService: any;
  let mockConfigService: any;

  beforeEach(async () => {
    mockPrisma = {
      step: {
        findMany: jest.fn().mockResolvedValue([
          {
            stepCount: 10000,
            caloriesBurned: 500,
            user: { id: 'u1', name: 'User 1', avatarUrl: 'url1', fitnessLevel: 'active' },
          },
        ]),
      },
    };

    mockJwtService = {
      verify: jest.fn().mockReturnValue({ sub: 'u1' }),
    };

    mockConfigService = {
      get: jest.fn().mockReturnValue('secret'),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        LeaderboardGateway,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: JwtService, useValue: mockJwtService },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    gateway = module.get<LeaderboardGateway>(LeaderboardGateway);
    gateway.server = {
      to: jest.fn().mockReturnThis(),
      emit: jest.fn(),
    } as any;
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(gateway).toBeDefined();
  });

  describe('handleConnection', () => {
    it('should authenticate user with header', async () => {
      const client = {
        id: 'c1',
        handshake: { headers: { authorization: 'Bearer token123' }, auth: {} },
        disconnect: jest.fn(),
      } as any;

      await gateway.handleConnection(client);
      expect(mockJwtService.verify).toHaveBeenCalledWith('token123', { secret: 'secret' });
      expect(client.user).toEqual({ sub: 'u1' });
      expect(client.disconnect).not.toHaveBeenCalled();
    });

    it('should authenticate user with auth payload', async () => {
      const client = {
        id: 'c1',
        handshake: { headers: {}, auth: { token: 'token123' } },
        disconnect: jest.fn(),
      } as any;

      await gateway.handleConnection(client);
      expect(mockJwtService.verify).toHaveBeenCalledWith('token123', { secret: 'secret' });
      expect(client.user).toEqual({ sub: 'u1' });
      expect(client.disconnect).not.toHaveBeenCalled();
    });

    it('should disconnect if no token', async () => {
      const client = {
        id: 'c1',
        handshake: { headers: {}, auth: {} },
        disconnect: jest.fn(),
      } as any;

      await gateway.handleConnection(client);
      expect(client.disconnect).toHaveBeenCalled();
    });

    it('should disconnect if token verification fails', async () => {
      mockJwtService.verify.mockImplementation(() => { throw new Error('invalid'); });
      const client = {
        id: 'c1',
        handshake: { auth: { token: 'bad' } },
        disconnect: jest.fn(),
      } as any;

      await gateway.handleConnection(client);
      expect(client.disconnect).toHaveBeenCalled();
    });
  });

  describe('handleDisconnect', () => {
    it('should log disconnect', () => {
      const loggerSpy = jest.spyOn((gateway as any).logger, 'log').mockImplementation();
      gateway.handleDisconnect({ id: 'c1' } as any);
      expect(loggerSpy).toHaveBeenCalledWith('Client disconnected from leaderboard: c1');
    });
  });

  describe('handleJoinLeaderboard', () => {
    it('should join global_leaderboard and emit update', async () => {
      const client = {
        id: 'c1',
        user: { sub: 'u1' },
        join: jest.fn(),
        emit: jest.fn(),
      } as any;

      await gateway.handleJoinLeaderboard(client);
      
      expect(client.join).toHaveBeenCalledWith('global_leaderboard');
      expect(mockPrisma.step.findMany).toHaveBeenCalled();
      expect(client.emit).toHaveBeenCalledWith('leaderboard_update', [
        {
          rank: 1,
          userId: 'u1',
          name: 'User 1',
          avatarUrl: 'url1',
          fitnessLevel: 'active',
          stepCount: 10000,
          calories: 500,
        },
      ]);
    });

    it('should reject if no userId in payload', async () => {
      const client = {
        id: 'c1',
        user: {},
        join: jest.fn(),
        emit: jest.fn(),
      } as any;
      const loggerSpy = jest.spyOn((gateway as any).logger, 'warn').mockImplementation();

      await gateway.handleJoinLeaderboard(client);
      
      expect(loggerSpy).toHaveBeenCalledWith('Unauthenticated user attempted to join leaderboard. Rejecting.');
      expect(client.join).not.toHaveBeenCalled();
    });
  });

  describe('broadcastLeaderboardUpdate', () => {
    it('should emit leaderboard_update to global_leaderboard', async () => {
      await gateway.broadcastLeaderboardUpdate();
      
      expect(gateway.server.to).toHaveBeenCalledWith('global_leaderboard');
      expect((gateway.server.to as any)().emit).toHaveBeenCalledWith('leaderboard_update', [
        {
          rank: 1,
          userId: 'u1',
          name: 'User 1',
          avatarUrl: 'url1',
          fitnessLevel: 'active',
          stepCount: 10000,
          calories: 500,
        },
      ]);
    });
  });
});
