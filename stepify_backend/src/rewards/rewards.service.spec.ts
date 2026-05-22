import { Test, TestingModule } from '@nestjs/testing';
import { RewardsService } from './rewards.service';
import { PrismaService } from '../prisma/prisma.service';
import { ConfigService } from '@nestjs/config';
import { QuestsService } from '../quests/quests.service';
import { TransactionType } from '@prisma/client';

describe('RewardsService', () => {
  let service: RewardsService;
  let prisma: PrismaService;

  const mockPrisma: any = {
    $transaction: jest.fn(async (cb) => cb(mockPrisma)),
    user: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
    wallet: {
      update: jest.fn(),
      findUnique: jest.fn(),
      create: jest.fn(),
      upsert: jest.fn(),
    },
    transaction: {
      create: jest.fn(),
      findMany: jest.fn(),
      count: jest.fn(),
    },
    step: {
      findMany: jest.fn(),
      aggregate: jest.fn(),
    },
    streak: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    userAchievement: {
      updateMany: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
      upsert: jest.fn(),
    },
    level: {
      findMany: jest.fn(),
    },
    achievement: {
      findMany: jest.fn(),
    },
    userChallenge: {
      count: jest.fn(),
    },
    friendship: {
      count: jest.fn(),
    },
    reward: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    userRedemption: {
      create: jest.fn(),
      findMany: jest.fn(),
    },
  };

  const mockConfig = {
    get: jest.fn().mockImplementation((key, defaultVal) => {
      if (key === 'POINTS_PER_STEP') return '0.1';
      return defaultVal;
    }),
  };

  const mockQuestsService = {
    processQuestProgress: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RewardsService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: ConfigService, useValue: mockConfig },
        { provide: QuestsService, useValue: mockQuestsService },
      ],
    }).compile();

    service = module.get<RewardsService>(RewardsService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('processWalletExpiry', () => {
    it('should expire coins for inactive users', async () => {
      mockPrisma.user.findMany.mockResolvedValueOnce([{ id: 'u1', wallet: { balance: 100 } }]);
      await service.processWalletExpiry();
      expect(mockPrisma.wallet.update).toHaveBeenCalledWith(
        expect.objectContaining({ where: { userId: 'u1' }, data: { balance: 0 } })
      );
      expect(mockPrisma.transaction.create).toHaveBeenCalled();
    });

    it('should do nothing if no inactive users', async () => {
      mockPrisma.user.findMany.mockResolvedValueOnce([]);
      await service.processWalletExpiry();
      expect(mockPrisma.wallet.update).not.toHaveBeenCalled();
    });
  });

  describe('getWallet', () => {
    it('should return existing wallet', async () => {
      mockPrisma.wallet.findUnique.mockResolvedValueOnce({ id: 'w1', balance: 50 });
      const w = await service.getWallet('u1');
      expect(w.balance).toBe(50);
    });

    it('should create wallet if not found', async () => {
      mockPrisma.wallet.findUnique.mockResolvedValueOnce(null);
      mockPrisma.wallet.create.mockResolvedValueOnce({ id: 'w1', balance: 0 });
      const w = await service.getWallet('u1');
      expect(w.balance).toBe(0);
      expect(mockPrisma.wallet.create).toHaveBeenCalled();
    });
  });

  describe('processStepRewards', () => {
    it('should award points and process dependencies correctly', async () => {
      mockPrisma.user.findUnique.mockResolvedValue({ dailyStepGoal: 5000 });
      mockPrisma.transaction.create.mockResolvedValue({});
      mockPrisma.wallet.upsert.mockResolvedValue({});
      
      // Mock updateStreak
      mockPrisma.streak.findUnique.mockResolvedValue({ currentStreak: 1, longestStreak: 1, lastActiveDate: new Date() });
      mockPrisma.streak.update.mockResolvedValue({});
      mockPrisma.streak.create.mockResolvedValue({ currentStreak: 1, longestStreak: 1, lastActiveDate: new Date() });
      
      // Mock checkAchievements
      mockPrisma.step.findMany.mockResolvedValue([]);
      mockPrisma.step.aggregate.mockResolvedValue({ _sum: { stepCount: 10000 } });
      mockPrisma.wallet.findUnique.mockResolvedValue({ lifetimePoints: 1000, balance: 1000, lastResetDate: new Date() });
      mockPrisma.userChallenge.count.mockResolvedValue(0);
      mockPrisma.friendship.count.mockResolvedValue(0);
      mockPrisma.achievement.findMany.mockResolvedValue([]);
      
      const res = await service.processStepRewards('u1', 6000, new Date());
      expect(res.pointsEarned).toBe(600); // 6000 * 0.1
      expect(mockQuestsService.processQuestProgress).toHaveBeenCalledWith('u1', 6000);
    });
  });

  describe('updateStreak', () => {
    it('should increment streak on consecutive day', async () => {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      yesterday.setHours(0,0,0,0);

      mockPrisma.streak.findUnique.mockResolvedValue({
        userId: 'u1', currentStreak: 5, longestStreak: 5, lastActiveDate: yesterday
      });
      mockPrisma.streak.update.mockResolvedValue({ currentStreak: 6 });

      const res = await service.updateStreak('u1', new Date());
      expect(mockPrisma.streak.update).toHaveBeenCalledWith(
        expect.objectContaining({ data: expect.objectContaining({ currentStreak: 6 }) })
      );
    });

    it('should reset streak if missed a day', async () => {
      const past = new Date();
      past.setDate(past.getDate() - 3);
      past.setHours(0,0,0,0);

      mockPrisma.streak.findUnique.mockResolvedValue({
        userId: 'u1', currentStreak: 5, longestStreak: 5, lastActiveDate: past
      });
      mockPrisma.streak.update.mockResolvedValue({ currentStreak: 1 });

      await service.updateStreak('u1', new Date());
      expect(mockPrisma.streak.update).toHaveBeenCalledWith(
        expect.objectContaining({ data: expect.objectContaining({ currentStreak: 1 }) })
      );
    });
  });

  describe('redeemReward', () => {
    it('should redeem successfully when balance allows', async () => {
      const mockReward = { id: 'r1', coinCost: 100, availableStock: 10, isActive: true };
      const mockWallet = { id: 'w1', userId: 'u1', balance: 200 };

      mockPrisma.wallet.findUnique.mockResolvedValue(mockWallet);
      mockPrisma.reward.findUnique.mockResolvedValue(mockReward);
      mockPrisma.userRedemption.create.mockResolvedValue({ id: 'red1' });
      mockPrisma.wallet.update.mockResolvedValue({});
      mockPrisma.transaction.create.mockResolvedValue({});
      mockPrisma.reward.update.mockResolvedValue({});

      const res = await service.redeemReward('u1', 'r1');
      expect(res.success).toBe(true);
      expect(res.newBalance).toBe(100);
      expect(mockPrisma.wallet.update).toHaveBeenCalled();
    });

    it('should fail if insufficient coins', async () => {
      const mockReward = { id: 'r1', coinCost: 500, availableStock: 10, isActive: true };
      const mockWallet = { id: 'w1', userId: 'u1', balance: 200 };

      mockPrisma.wallet.findUnique.mockResolvedValue(mockWallet);
      mockPrisma.reward.findUnique.mockResolvedValue(mockReward);

      await expect(service.redeemReward('u1', 'r1')).rejects.toThrow('Insufficient coins');
    });
  });
});
