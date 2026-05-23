import { Test, TestingModule } from '@nestjs/testing';
import { AdminController } from './admin.controller';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import { StepsService } from '../steps/steps.service';
import * as adminView from './admin.view';

jest.mock('./admin.view', () => ({
  getAdminDashboardHtml: jest.fn().mockReturnValue('<html>Dashboard</html>'),
}));

describe('AdminController', () => {
  let controller: AdminController;
  let mockPrisma: any;
  let mockRedis: any;
  let mockRedisClient: any;
  let mockSteps: any;

  beforeEach(async () => {
    mockPrisma = {
      user: { count: jest.fn(), findMany: jest.fn(), deleteMany: jest.fn() },
      step: { aggregate: jest.fn(), groupBy: jest.fn(), deleteMany: jest.fn() },
      wallet: { aggregate: jest.fn(), deleteMany: jest.fn() },
      transaction: { findMany: jest.fn(), deleteMany: jest.fn() },
      device: { findFirst: jest.fn(), create: jest.fn() },
      streak: { deleteMany: jest.fn() },
      userAchievement: { deleteMany: jest.fn() },
    };

    mockRedisClient = {
      status: 'ready',
      keys: jest.fn(),
      del: jest.fn(),
    };

    mockRedis = {
      getClient: jest.fn().mockReturnValue(mockRedisClient),
    };

    mockSteps = {
      syncSteps: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [AdminController],
      providers: [
        { provide: PrismaService, useValue: mockPrisma },
        { provide: RedisService, useValue: mockRedis },
        { provide: StepsService, useValue: mockSteps },
      ],
    }).compile();

    controller = module.get<AdminController>(AdminController);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getDashboardHtml', () => {
    it('should return html', async () => {
      const res = await controller.getDashboardHtml();
      expect(res).toBe('<html>Dashboard</html>');
      expect(adminView.getAdminDashboardHtml).toHaveBeenCalled();
    });
  });

  describe('clearAllData', () => {
    it('should delete all user data', async () => {
      const res = await controller.clearAllData();
      
      expect(mockPrisma.step.deleteMany).toHaveBeenCalled();
      expect(mockPrisma.streak.deleteMany).toHaveBeenCalled();
      expect(mockPrisma.wallet.deleteMany).toHaveBeenCalled();
      expect(mockPrisma.transaction.deleteMany).toHaveBeenCalled();
      expect(mockPrisma.userAchievement.deleteMany).toHaveBeenCalled();
      expect(mockPrisma.user.deleteMany).toHaveBeenCalled();
      
      expect(res.success).toBe(true);
      expect(res.message).toContain('cleared');
    });
  });

  describe('getMetrics', () => {
    it('should return metrics', async () => {
      mockPrisma.user.count.mockResolvedValue(10);
      mockPrisma.step.aggregate.mockResolvedValue({ _sum: { stepCount: 1000 } });
      mockPrisma.wallet.aggregate.mockResolvedValue({ _sum: { balance: 500 } });
      mockPrisma.user.findMany.mockResolvedValue([{ id: 'u1' }]);
      mockPrisma.transaction.findMany.mockResolvedValue([{ id: 't1' }]);
      mockPrisma.step.groupBy.mockResolvedValue([{ date: new Date('2026-05-20T00:00:00.000Z'), _sum: { stepCount: 500 } }]);

      const res = await controller.getMetrics();
      expect(res.usersCount).toBe(10);
      expect(res.stepsSum).toBe(1000);
      expect(res.coinsSum).toBe(500);
      expect(res.users.length).toBe(1);
      expect(res.recentTransactions.length).toBe(1);
      expect(res.chartData.length).toBe(1);
      expect(res.chartData[0].date).toBe('2026-05-20');
    });

    it('should handle null sums', async () => {
      mockPrisma.user.count.mockResolvedValue(0);
      mockPrisma.step.aggregate.mockResolvedValue({ _sum: { stepCount: null } });
      mockPrisma.wallet.aggregate.mockResolvedValue({ _sum: { balance: null } });
      mockPrisma.user.findMany.mockResolvedValue([]);
      mockPrisma.transaction.findMany.mockResolvedValue([]);
      mockPrisma.step.groupBy.mockResolvedValue([{ date: new Date(), _sum: { stepCount: null } }]);

      const res = await controller.getMetrics();
      expect(res.stepsSum).toBe(0);
      expect(res.coinsSum).toBe(0);
      expect(res.chartData[0].steps).toBe(0);
    });
  });

  describe('mockSyncSteps', () => {
    it('should create device if not exists and sync steps', async () => {
      mockPrisma.device.findFirst.mockResolvedValue(null);
      mockSteps.syncSteps.mockResolvedValue({ status: 'ok' });

      const body = { userId: 'u1', stepCount: 100, source: 'manual' };
      await controller.mockSyncSteps(body as any);

      expect(mockPrisma.device.create).toHaveBeenCalled();
      expect(mockSteps.syncSteps).toHaveBeenCalled();
    });

    it('should use existing device and sync steps', async () => {
      mockPrisma.device.findFirst.mockResolvedValue({ id: 'd1' });
      mockSteps.syncSteps.mockResolvedValue({ status: 'ok' });

      const body = { userId: 'u1', stepCount: 100, source: 'manual' };
      await controller.mockSyncSteps(body as any);

      expect(mockPrisma.device.create).not.toHaveBeenCalled();
      expect(mockSteps.syncSteps).toHaveBeenCalled();
    });
  });

  describe('resetNonces', () => {
    it('should reset nonces when redis is ready and keys exist', async () => {
      mockRedisClient.keys.mockResolvedValue(['nonce:1', 'nonce:2']);
      
      const res = await controller.resetNonces();
      
      expect(mockRedisClient.del).toHaveBeenCalledWith('nonce:1', 'nonce:2');
      expect(res.status).toBe('success');
      expect(res.flushedCount).toBe(2);
    });

    it('should do nothing when keys are empty', async () => {
      mockRedisClient.keys.mockResolvedValue([]);
      
      const res = await controller.resetNonces();
      
      expect(mockRedisClient.del).not.toHaveBeenCalled();
      expect(res.status).toBe('success');
      expect(res.flushedCount).toBe(0);
    });

    it('should return mock info when redis not ready', async () => {
      mockRedisClient.status = 'error';
      
      const res = await controller.resetNonces();
      
      expect(res.status).toBe('mock_in_memory_reset');
    });
  });
});
