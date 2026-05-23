import { Test, TestingModule } from '@nestjs/testing';
import { LeaderboardGateway } from './leaderboard.gateway';

describe('Steps LeaderboardGateway', () => {
  let gateway: LeaderboardGateway;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [LeaderboardGateway],
    }).compile();

    gateway = module.get<LeaderboardGateway>(LeaderboardGateway);
    gateway.server = {
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
    it('should log connection', () => {
      const loggerSpy = jest.spyOn((gateway as any).logger, 'log').mockImplementation();
      const client = { id: 'c1' } as any;
      gateway.handleConnection(client);
      expect(loggerSpy).toHaveBeenCalledWith('🔌 Client connected to Leaderboard WS: c1');
    });
  });

  describe('handleDisconnect', () => {
    it('should log disconnection', () => {
      const loggerSpy = jest.spyOn((gateway as any).logger, 'log').mockImplementation();
      const client = { id: 'c1' } as any;
      gateway.handleDisconnect(client);
      expect(loggerSpy).toHaveBeenCalledWith('🔌 Client disconnected from Leaderboard WS: c1');
    });
  });

  describe('broadcastLeaderboardUpdate', () => {
    it('should broadcast update for specific company', () => {
      const data = [{ id: '1' }];
      gateway.broadcastLeaderboardUpdate('comp1', data);
      expect(gateway.server.emit).toHaveBeenCalledWith('update:comp1', data);
    });
  });

  describe('broadcastGlobalLeaderboardUpdate', () => {
    it('should broadcast global update', () => {
      const data = [{ id: '1' }];
      gateway.broadcastGlobalLeaderboardUpdate(data);
      expect(gateway.server.emit).toHaveBeenCalledWith('global_update', data);
    });
  });

  describe('handlePing', () => {
    it('should return pong', () => {
      const res = gateway.handlePing({} as any);
      expect(res).toBe('pong');
    });
  });
});
