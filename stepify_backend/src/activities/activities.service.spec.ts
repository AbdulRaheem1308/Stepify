import { Test, TestingModule } from '@nestjs/testing';
import { ActivitiesService } from './activities.service';
import { PrismaService } from '../prisma/prisma.service';
import { BadRequestException, ConflictException } from '@nestjs/common';

describe('ActivitiesService', () => {
  let service: ActivitiesService;
  let _prisma: PrismaService;

  const mockPrismaService = {
    activity: {
      findFirst: jest.fn(),
      findMany: jest.fn(),
      count: jest.fn(),
    },
    $transaction: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ActivitiesService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<ActivitiesService>(ActivitiesService);
    _prisma = module.get<PrismaService>(PrismaService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('logActivity', () => {
    it('should throw BadRequestException if duration exceeds max limit', async () => {
      await expect(
        service.logActivity('user1', {
          type: 'walking' as any,
          durationMinutes: 301,
          startTime: new Date().toISOString(),
          caloriesBurned: 100,
        })
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if distance violates speed constraints', async () => {
      await expect(
        service.logActivity('user1', {
          type: 'walking' as any,
          durationMinutes: 10,
          distanceKm: 2.0,
          startTime: new Date().toISOString(),
          caloriesBurned: 100,
        })
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw ConflictException if idempotency check fails', async () => {
      mockPrismaService.activity.findFirst.mockResolvedValueOnce({ id: 'existing' });

      await expect(
        service.logActivity('user1', {
          type: 'running' as any,
          durationMinutes: 30,
          distanceKm: 5,
          startTime: new Date().toISOString(),
          caloriesBurned: 100,
        })
      ).rejects.toThrow(ConflictException);
    });

    it('should successfully log a verified activity with 100% points', async () => {
      mockPrismaService.activity.findFirst.mockResolvedValueOnce(null);
      const activityCreateSpy = jest.fn().mockResolvedValue({ id: 'act_verified' });
      const transactionCreateSpy = jest.fn().mockResolvedValue({});
      const walletUpsertSpy = jest.fn().mockResolvedValue({});
      mockPrismaService.$transaction.mockImplementationOnce(async (cb) => {
        const tx = {
          activity: { create: activityCreateSpy },
          transaction: { create: transactionCreateSpy },
          wallet: { upsert: walletUpsertSpy },
        };
        return cb(tx);
      });

      const result = await service.logActivity('user1', {
        type: 'running' as any,
        durationMinutes: 30,
        distanceKm: 5,
        startTime: new Date().toISOString(),
        caloriesBurned: 100,
        source: 'google_fit',
      });

      expect(result).toEqual({ id: 'act_verified' });
      expect(activityCreateSpy).toHaveBeenCalledWith(expect.objectContaining({
        data: expect.objectContaining({
          pointsEarned: 90,
          source: 'google_fit',
        }),
      }));
      expect(transactionCreateSpy).toHaveBeenCalledWith(expect.objectContaining({
        data: expect.objectContaining({
          points: 90,
        }),
      }));
    });

    it('should successfully log a manual activity with 50% points', async () => {
      mockPrismaService.activity.findFirst.mockResolvedValueOnce(null);
      const activityCreateSpy = jest.fn().mockResolvedValue({ id: 'act_manual' });
      const transactionCreateSpy = jest.fn().mockResolvedValue({});
      const walletUpsertSpy = jest.fn().mockResolvedValue({});
      mockPrismaService.$transaction.mockImplementationOnce(async (cb) => {
        const tx = {
          activity: { create: activityCreateSpy },
          transaction: { create: transactionCreateSpy },
          wallet: { upsert: walletUpsertSpy },
        };
        return cb(tx);
      });

      const result = await service.logActivity('user1', {
        type: 'running' as any,
        durationMinutes: 30,
        distanceKm: 5,
        startTime: new Date().toISOString(),
        caloriesBurned: 100,
        source: 'manual',
      });

      expect(result).toEqual({ id: 'act_manual' });
      expect(activityCreateSpy).toHaveBeenCalledWith(expect.objectContaining({
        data: expect.objectContaining({
          pointsEarned: 45,
          source: 'manual',
        }),
      }));
      expect(transactionCreateSpy).toHaveBeenCalledWith(expect.objectContaining({
        data: expect.objectContaining({
          points: 45,
        }),
      }));
    });

    it('should handle activity with no points', async () => {
      mockPrismaService.activity.findFirst.mockResolvedValueOnce(null);
      let txActivityCreate;
      let txTransactionCreate;
      let txWalletUpsert;
      
      mockPrismaService.$transaction.mockImplementationOnce(async (cb) => {
        txActivityCreate = jest.fn().mockResolvedValue({ id: 'act2' });
        txTransactionCreate = jest.fn().mockResolvedValue({});
        txWalletUpsert = jest.fn().mockResolvedValue({});
        const tx = {
          activity: { create: txActivityCreate },
          transaction: { create: txTransactionCreate },
          wallet: { upsert: txWalletUpsert },
        };
        return cb(tx);
      });

      const result = await service.logActivity('user1', {
        type: 'yoga' as any,
        durationMinutes: 0,
        startTime: new Date().toISOString(),
        caloriesBurned: 100,
      });

      expect(result).toEqual({ id: 'act2' });
      expect(txTransactionCreate).not.toHaveBeenCalled();
      expect(txWalletUpsert).not.toHaveBeenCalled();
    });

    it('should handle unconstrained speed for unknown types', async () => {
        mockPrismaService.activity.findFirst.mockResolvedValueOnce(null);
        mockPrismaService.$transaction.mockImplementationOnce(async (cb) => {
          const tx = {
            activity: { create: jest.fn().mockResolvedValue({ id: 'act3' }) },
            transaction: { create: jest.fn().mockResolvedValue({}) },
            wallet: { upsert: jest.fn().mockResolvedValue({}) },
          };
          return cb(tx);
        });
  
        const result = await service.logActivity('user1', {
          type: 'UNKNOWN_TYPE' as any,
          durationMinutes: 30, 
          distanceKm: 100,
          startTime: new Date().toISOString(),
          caloriesBurned: 100,
        });
  
        expect(result).toEqual({ id: 'act3' });
    });

    it('should handle transaction error', async () => {
      mockPrismaService.activity.findFirst.mockResolvedValueOnce(null);
      mockPrismaService.$transaction.mockRejectedValueOnce(new Error('Tx failed'));

      await expect(
        service.logActivity('user1', {
          type: 'running' as any,
          durationMinutes: 30,
          startTime: new Date().toISOString(),
          caloriesBurned: 100,
        })
      ).rejects.toThrow('Tx failed');
    });
  });

  describe('getRecentActivities', () => {
    it('should return paginated activities', async () => {
      const activities = [{ id: '1' }, { id: '2' }];
      mockPrismaService.activity.findMany.mockResolvedValueOnce(activities);
      mockPrismaService.activity.count.mockResolvedValueOnce(10);

      const result = await service.getRecentActivities('user1', { page: 2, limit: 5 });

      expect(result.data).toEqual(activities);
      expect(result.meta.total).toBe(10);
      expect(result.meta.page).toBe(2);
      expect(result.meta.limit).toBe(5);
      expect(result.meta.totalPages).toBe(2);
      expect(mockPrismaService.activity.findMany).toHaveBeenCalledWith({
        where: { userId: 'user1' },
        orderBy: { startTime: 'desc' },
        take: 5,
        skip: 5,
      });
    });

    it('should return paginated activities with defaults', async () => {
      const activities = [{ id: '1' }];
      mockPrismaService.activity.findMany.mockResolvedValueOnce(activities);
      mockPrismaService.activity.count.mockResolvedValueOnce(1);

      const result = await service.getRecentActivities('user1', {});

      expect(result.data).toEqual(activities);
      expect(result.meta.total).toBe(1);
      expect(result.meta.page).toBe(1);
      expect(result.meta.limit).toBe(20);
      expect(mockPrismaService.activity.findMany).toHaveBeenCalledWith({
        where: { userId: 'user1' },
        orderBy: { startTime: 'desc' },
        take: 20,
        skip: 0,
      });
    });
  });
});