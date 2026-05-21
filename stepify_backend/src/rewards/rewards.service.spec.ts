import { Test, TestingModule } from '@nestjs/testing';
import { RewardsService } from './rewards.service';
import { PrismaService } from '../prisma/prisma.service';
import { ConfigService } from '@nestjs/config';
import { QuestsService } from '../quests/quests.service';
import { TransactionType } from '@prisma/client';

// ── Mocks ──────────────────────────────────────────────────────────────────
const mockPrisma = {
  wallet: {
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    upsert: jest.fn(),
  },
  transaction: {
    findMany: jest.fn(),
    count: jest.fn(),
    create: jest.fn(),
  },
  reward: {
    findMany: jest.fn(),
    findUnique: jest.fn(),
    update: jest.fn(),
    create: jest.fn(),
  },
  userRedemption: {
    create: jest.fn(),
    findMany: jest.fn(),
  },
  streak: {
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  },
  step: {
    findMany: jest.fn(),
    aggregate: jest.fn(),
  },
  achievement: { findMany: jest.fn() },
  userAchievement: {
    findUnique: jest.fn(),
    upsert: jest.fn(),
    updateMany: jest.fn(),
  },
  userChallenge: { count: jest.fn() },
  friendship: { count: jest.fn() },
  user: { findMany: jest.fn(), findUnique: jest.fn() },
};

const mockConfig = {
  get: jest.fn((key: string, def?: any) => {
    const map: Record<string, any> = {
      POINTS_PER_STEP: '0.1',
    };
    return map[key] ?? def;
  }),
};

const mockQuests = {
  processQuestProgress: jest.fn(),
};

// ── Tests ──────────────────────────────────────────────────────────────────
describe('RewardsService', () => {
  let service: RewardsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RewardsService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: ConfigService, useValue: mockConfig },
        { provide: QuestsService, useValue: mockQuests },
      ],
    }).compile();

    service = module.get<RewardsService>(RewardsService);
    jest.clearAllMocks();
  });

  // ── getWallet ─────────────────────────────────────────────────────────────
  describe('getWallet()', () => {
    it('should return existing wallet if found', async () => {
      const wallet = { userId: 'user-1', balance: 500, lifetimePoints: 1200 };
      mockPrisma.wallet.findUnique.mockResolvedValue(wallet);

      const result = await service.getWallet('user-1');
      expect(result).toEqual(wallet);
      expect(mockPrisma.wallet.create).not.toHaveBeenCalled();
    });

    it('should create and return new wallet if not found', async () => {
      const newWallet = { userId: 'user-1', balance: 0, lifetimePoints: 0 };
      mockPrisma.wallet.findUnique.mockResolvedValue(null);
      mockPrisma.wallet.create.mockResolvedValue(newWallet);

      const result = await service.getWallet('user-1');
      expect(result).toEqual(newWallet);
      expect(mockPrisma.wallet.create).toHaveBeenCalledWith(
        expect.objectContaining({ data: expect.objectContaining({ userId: 'user-1', balance: 0 }) })
      );
    });
  });

  // ── addPoints ─────────────────────────────────────────────────────────────
  describe('addPoints()', () => {
    it('should create a transaction record and update wallet balance', async () => {
      mockPrisma.transaction.create.mockResolvedValue({ id: 'tx-1', points: 100 });
      mockPrisma.wallet.upsert.mockResolvedValue({ balance: 600 });

      await service.addPoints('user-1', 100, TransactionType.STEPS, 'Earned for steps');

      expect(mockPrisma.transaction.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ userId: 'user-1', points: 100, type: TransactionType.STEPS }),
        })
      );
      expect(mockPrisma.wallet.upsert).toHaveBeenCalledWith(
        expect.objectContaining({
          update: expect.objectContaining({ balance: { increment: 100 } }),
        })
      );
    });
  });

  // ── processStepRewards ────────────────────────────────────────────────────
  describe('processStepRewards()', () => {
    it('should award correct points (0.1 per step)', async () => {
      // Setup: user with a 10000 step goal
      mockPrisma.user.findUnique = jest.fn().mockResolvedValue({ dailyStepGoal: 10000 });
      mockPrisma.transaction.create.mockResolvedValue({});
      mockPrisma.wallet.upsert.mockResolvedValue({});
      // Streak and achievement mocks
      mockPrisma.step.findMany.mockResolvedValue([]);
      mockPrisma.streak.findUnique.mockResolvedValue(null);
      mockPrisma.streak.create.mockResolvedValue({ currentStreak: 1, longestStreak: 1, lastActiveDate: new Date() });
      mockPrisma.streak.update.mockResolvedValue({ currentStreak: 1, longestStreak: 1 });
      mockPrisma.step.aggregate.mockResolvedValue({ _sum: { stepCount: 5000 } });
      mockPrisma.wallet.findUnique.mockResolvedValue({ lifetimePoints: 0 });
      mockPrisma.userChallenge.count.mockResolvedValue(0);
      mockPrisma.friendship.count.mockResolvedValue(0);
      mockPrisma.achievement.findMany.mockResolvedValue([]);
      mockQuests.processQuestProgress.mockResolvedValue({});

      const result = await service.processStepRewards('user-1', 5000, new Date());

      // 5000 steps * 0.1 = 500 points
      expect(result.pointsEarned).toBe(500);
    });

    it('should update streak when step goal is reached', async () => {
      mockPrisma.user.findUnique = jest.fn().mockResolvedValue({ dailyStepGoal: 10000 });
      mockPrisma.transaction.create.mockResolvedValue({});
      mockPrisma.wallet.upsert.mockResolvedValue({});
      mockPrisma.step.findMany.mockResolvedValue([]);
      mockPrisma.streak.findUnique.mockResolvedValue(null);
      mockPrisma.streak.create.mockResolvedValue({ currentStreak: 1, longestStreak: 1, lastActiveDate: new Date() });
      mockPrisma.step.aggregate.mockResolvedValue({ _sum: { stepCount: 10000 } });
      mockPrisma.wallet.findUnique.mockResolvedValue({ lifetimePoints: 0 });
      mockPrisma.userChallenge.count.mockResolvedValue(0);
      mockPrisma.friendship.count.mockResolvedValue(0);
      mockPrisma.achievement.findMany.mockResolvedValue([]);
      mockQuests.processQuestProgress.mockResolvedValue({});

      await service.processStepRewards('user-1', 10000, new Date());

      // Streak create/update should be called since 10000 >= goal of 10000
      expect(mockPrisma.streak.create).toHaveBeenCalled();
    });
  });

  // ── updateStreak ──────────────────────────────────────────────────────────
  describe('updateStreak()', () => {
    it('should create streak=1 if no prior streak exists', async () => {
      mockPrisma.streak.findUnique.mockResolvedValue(null);
      mockPrisma.streak.create.mockResolvedValue({ currentStreak: 1, longestStreak: 1 });

      await service.updateStreak('user-1', new Date());

      expect(mockPrisma.streak.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ currentStreak: 1, longestStreak: 1 }),
        })
      );
    });

    it('should increment streak for consecutive day', async () => {
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      yesterday.setHours(0, 0, 0, 0);

      mockPrisma.streak.findUnique.mockResolvedValue({
        userId: 'user-1',
        currentStreak: 5,
        longestStreak: 10,
        lastActiveDate: yesterday,
      });
      mockPrisma.streak.update.mockResolvedValue({ currentStreak: 6, longestStreak: 10 });
      mockPrisma.transaction.create.mockResolvedValue({});
      mockPrisma.wallet.upsert.mockResolvedValue({});

      const result = await service.updateStreak('user-1', new Date());
      expect(mockPrisma.streak.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ currentStreak: 6 }),
        })
      );
    });

    it('should reset streak to 1 when streak is broken', async () => {
      const twoDaysAgo = new Date();
      twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);
      twoDaysAgo.setHours(0, 0, 0, 0);

      mockPrisma.streak.findUnique.mockResolvedValue({
        userId: 'user-1',
        currentStreak: 10,
        longestStreak: 15,
        lastActiveDate: twoDaysAgo,
      });
      mockPrisma.streak.update.mockResolvedValue({ currentStreak: 1, longestStreak: 15 });

      await service.updateStreak('user-1', new Date());
      expect(mockPrisma.streak.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ currentStreak: 1, longestStreak: 15 }),
        })
      );
    });
  });

  // ── redeemReward ──────────────────────────────────────────────────────────
  describe('redeemReward()', () => {
    it('should throw if reward is not found', async () => {
      mockPrisma.wallet.findUnique.mockResolvedValue({ balance: 1000 });
      mockPrisma.wallet.create = jest.fn();
      mockPrisma.reward.findUnique.mockResolvedValue(null);

      await expect(service.redeemReward('user-1', 'nonexistent-reward')).rejects.toThrow('Reward not found');
    });

    it('should throw if user has insufficient coins', async () => {
      mockPrisma.wallet.findUnique.mockResolvedValue({ balance: 50 });
      mockPrisma.reward.findUnique.mockResolvedValue({ id: 'r-1', isActive: true, coinCost: 200, availableStock: -1 });

      await expect(service.redeemReward('user-1', 'r-1')).rejects.toThrow('Insufficient coins');
    });

    it('should throw if reward is out of stock', async () => {
      mockPrisma.wallet.findUnique.mockResolvedValue({ balance: 1000 });
      mockPrisma.reward.findUnique.mockResolvedValue({ id: 'r-1', isActive: true, coinCost: 200, availableStock: 0 });

      await expect(service.redeemReward('user-1', 'r-1')).rejects.toThrow('Reward is out of stock');
    });

    it('should create redemption, deduct coins, and log transaction on success', async () => {
      mockPrisma.wallet.findUnique.mockResolvedValue({ balance: 1000 });
      const mockReward = { id: 'r-1', title: 'Coffee Voucher', isActive: true, coinCost: 200, availableStock: -1, expiryDate: null };
      mockPrisma.reward.findUnique.mockResolvedValue(mockReward);
      mockPrisma.userRedemption.create.mockResolvedValue({ id: 'redeem-1', reward: mockReward, voucherCode: 'STEP-XXXX' });
      mockPrisma.wallet.update.mockResolvedValue({ balance: 800 });
      mockPrisma.transaction.create.mockResolvedValue({});

      const result = await service.redeemReward('user-1', 'r-1');

      expect(mockPrisma.userRedemption.create).toHaveBeenCalled();
      expect(mockPrisma.wallet.update).toHaveBeenCalledWith(
        expect.objectContaining({ data: { balance: { decrement: 200 } } })
      );
      expect(mockPrisma.transaction.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ points: -200, type: 'REDEMPTION' }),
        })
      );
    });
  });

  // ── getTransactions ───────────────────────────────────────────────────────
  describe('getTransactions()', () => {
    it('should clamp page limit to 100 max', async () => {
      mockPrisma.transaction.findMany.mockResolvedValue([]);
      mockPrisma.transaction.count.mockResolvedValue(0);

      await service.getTransactions('user-1', 1, 500);

      expect(mockPrisma.transaction.findMany).toHaveBeenCalledWith(
        expect.objectContaining({ take: 100 })
      );
    });

    it('should return correct pagination metadata', async () => {
      mockPrisma.transaction.findMany.mockResolvedValue(Array(20).fill({ points: 10 }));
      mockPrisma.transaction.count.mockResolvedValue(45);

      const result = await service.getTransactions('user-1', 1, 20);

      expect(result.pagination.total).toBe(45);
      expect(result.pagination.totalPages).toBe(3); // ceil(45/20)
    });
  });
});
