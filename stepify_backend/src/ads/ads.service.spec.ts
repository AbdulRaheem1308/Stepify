import { Test, TestingModule } from '@nestjs/testing';
import { AdsService } from './ads.service';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import { ConfigService } from '@nestjs/config';
import { BadRequestException } from '@nestjs/common';
import { AdType } from '@prisma/client';

describe('AdsService', () => {
  let service: AdsService;
  let prisma: PrismaService;
  let redis: RedisService;
  let config: ConfigService;

  const mockPrismaService = {
    adView: {
      count: jest.fn(),
      create: jest.fn(),
      findMany: jest.fn(),
      aggregate: jest.fn(),
    },
    transaction: {
      create: jest.fn(),
    },
    wallet: {
      upsert: jest.fn(),
    },
    $transaction: jest.fn(),
  };

  const mockRedisService = {
    checkAdCooldown: jest.fn(),
    getAdCooldownRemaining: jest.fn(),
    setAdCooldown: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn((key: string, defaultValue: string) => {
      if (key === 'AD_REWARD_POINTS') return '10';
      if (key === 'AD_COOLDOWN_MINUTES') return '5';
      return defaultValue;
    }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AdsService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: RedisService, useValue: mockRedisService },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    service = module.get<AdsService>(AdsService);
    prisma = module.get<PrismaService>(PrismaService);
    redis = module.get<RedisService>(RedisService);
    config = module.get<ConfigService>(ConfigService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('checkCanWatchAd', () => {
    it('should return canWatch=true if cooldown passes and under daily limit', async () => {
      mockRedisService.checkAdCooldown.mockResolvedValueOnce(true);
      mockPrismaService.adView.count.mockResolvedValueOnce(5);

      const result = await service.checkCanWatchAd('user1');
      expect(result).toEqual({
        canWatch: true,
        cooldownRemaining: 0,
        todayViews: 5,
        maxDailyAds: 10,
        remainingAds: 5,
        pointsPerAd: 10,
      });
    });

    it('should return canWatch=false if in cooldown', async () => {
      mockRedisService.checkAdCooldown.mockResolvedValueOnce(false);
      mockRedisService.getAdCooldownRemaining.mockResolvedValueOnce(120);
      mockPrismaService.adView.count.mockResolvedValueOnce(5);

      const result = await service.checkCanWatchAd('user1');
      expect(result).toEqual({
        canWatch: false,
        cooldownRemaining: 120,
        todayViews: 5,
        maxDailyAds: 10,
        remainingAds: 5,
        pointsPerAd: 10,
      });
    });

    it('should return canWatch=false if daily limit reached', async () => {
      mockRedisService.checkAdCooldown.mockResolvedValueOnce(true);
      mockPrismaService.adView.count.mockResolvedValueOnce(10);

      const result = await service.checkCanWatchAd('user1');
      expect(result).toEqual({
        canWatch: false,
        cooldownRemaining: 0,
        todayViews: 10,
        maxDailyAds: 10,
        remainingAds: 0,
        pointsPerAd: 10,
      });
    });
  });

  describe('claimAdReward', () => {
    it('should throw if in cooldown and ad is rewarded', async () => {
      mockRedisService.checkAdCooldown.mockResolvedValueOnce(false);
      mockRedisService.getAdCooldownRemaining.mockResolvedValueOnce(60);

      await expect(service.claimAdReward('user1', AdType.REWARDED)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should throw if daily limit reached and ad is rewarded', async () => {
      mockRedisService.checkAdCooldown.mockResolvedValueOnce(true);
      mockPrismaService.adView.count.mockResolvedValueOnce(10);

      await expect(service.claimAdReward('user1', AdType.REWARDED)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should successfully claim reward, process tx, and set cooldown', async () => {
      mockRedisService.checkAdCooldown.mockResolvedValueOnce(true);
      mockPrismaService.adView.count.mockResolvedValueOnce(5);

      mockPrismaService.$transaction.mockImplementationOnce(async (cb) => {
        const tx = {
          adView: { create: jest.fn().mockResolvedValue({ id: 'ad1' }) },
          transaction: { create: jest.fn().mockResolvedValue({}) },
          wallet: { upsert: jest.fn().mockResolvedValue({}) },
        };
        return cb(tx);
      });

      const result = await service.claimAdReward('user1', AdType.REWARDED);

      expect(result).toEqual({
        success: true,
        pointsEarned: 10,
        cooldownMinutes: 5,
      });
      expect(mockRedisService.setAdCooldown).toHaveBeenCalledWith('user1', 5);
      expect(mockPrismaService.$transaction).toHaveBeenCalled();
    });

    it('should claim unrewarded ad without limits and 0 points', async () => {
      mockPrismaService.$transaction.mockImplementationOnce(async (cb) => {
        const tx = {
          adView: { create: jest.fn().mockResolvedValue({ id: 'ad2' }) },
        };
        return cb(tx);
      });

      const result = await service.claimAdReward('user1', AdType.INTERSTITIAL);

      expect(result).toEqual({
        success: true,
        pointsEarned: 0,
        cooldownMinutes: 0,
      });
      expect(mockRedisService.checkAdCooldown).not.toHaveBeenCalled();
      expect(mockRedisService.setAdCooldown).not.toHaveBeenCalled();
    });

    it('should handle transaction error', async () => {
      mockRedisService.checkAdCooldown.mockResolvedValueOnce(true);
      mockPrismaService.adView.count.mockResolvedValueOnce(5);

      mockPrismaService.$transaction.mockRejectedValueOnce(new Error('Tx failed'));

      await expect(service.claimAdReward('user1', AdType.REWARDED)).rejects.toThrow('Tx failed');
    });
  });

  describe('getAdHistory', () => {
    it('should return paginated ad views and summary', async () => {
      const views = [{ id: '1' }];
      mockPrismaService.adView.findMany.mockResolvedValueOnce(views);
      mockPrismaService.adView.count.mockResolvedValueOnce(1);
      mockPrismaService.adView.aggregate.mockResolvedValueOnce({
        _count: 1,
        _sum: { pointsEarned: 10 },
      });

      const result = await service.getAdHistory('user1', 1, 10);

      expect(result.data).toEqual(views);
      expect(result.pagination).toEqual({ page: 1, limit: 10, total: 1, totalPages: 1 });
      expect(result.summary).toEqual({ totalAdsWatched: 1, totalPointsEarned: 10 });
    });
  });
});