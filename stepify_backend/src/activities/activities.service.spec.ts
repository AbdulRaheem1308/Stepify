import { Test, TestingModule } from '@nestjs/testing';
import { ActivitiesService } from './activities.service';
import { PrismaService } from '../prisma/prisma.service';
import { BadRequestException, ConflictException } from '@nestjs/common';

describe('ActivitiesService', () => {
  let service: ActivitiesService;
  let prisma: PrismaService;

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
    prisma = module.get<PrismaService>(PrismaService);
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
          type: 'WALKING' as any,
          durationMinutes: 301,
          startTime: new Date().toISOString(),
        })
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if distance violates speed constraints', async () => {
      await expect(
        service.logActivity('user1', {
          type: 'WALKING' as any,
          durationMinutes: 10,
          distanceKm: 2.0,
          startTime: new Date().toISOString(),
        })
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw ConflictException if idempotency check fails', async () => {
      mockPrismaService.activity.findFirst.mockResolvedValueOnce({ id: 'existing' });

      await expect(
        service.logActivity('user1', {
          type: 'RUNNING' as any,
          durationMinutes: 30,
          distanceKm: 5,
          startTime: new Date().toISOString(),
        })
      ).rejects.toThrow(ConflictException);
    });

    it('should successfully log activity and award points', async () => {
      mockPrismaService.activity.findFirst.mockResolvedValueOnce(null);
      mockPrismaService.$transaction.mockImplementationOnce(async (cb) => {
        const tx = {
          activity: { create: jest.fn().mockResolvedValue({ id: 'act1' }) },
          transaction: { create: jest.fn().mockResolvedValue({}) },
          wallet: { upsert: jest.fn().mockResolvedValue({}) },
        };
        return cb(tx);
      });

      const result = await service.logActivity('user1', {
        type: 'RUNNING' as any,
        durationMinutes: 30,
        distanceKm: 5,
        startTime: new Date().toISOString(),
      });

      expect(result).toEqual({ id: 'act1' });
      expect(mockPrismaService.$transaction).toHaveBeenCalled();
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
        type: 'YOGA' as any,
        durationMinutes: 0,
        startTime: new Date().toISOString(),
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
        });
  
        expect(result).toEqual({ id: 'act3' });
    });

    it('should handle transaction error', async () => {
      mockPrismaService.activity.findFirst.mockResolvedValueOnce(null);
      mockPrismaService.$transaction.mockRejectedValueOnce(new Error('Tx failed'));

      await expect(
        service.logActivity('user1', {
          type: 'RUNNING' as any,
          durationMinutes: 30,
          startTime: new Date().toISOString(),
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