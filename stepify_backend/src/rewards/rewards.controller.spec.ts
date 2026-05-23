import { Test, TestingModule } from '@nestjs/testing';
import { RewardsController } from './rewards.controller';
import { RewardsService } from './rewards.service';
import { RedeemRewardDto } from './dto/reward.dto';

describe('RewardsController', () => {
  let controller: RewardsController;
  let service: RewardsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [RewardsController],
      providers: [
        {
          provide: RewardsService,
          useValue: {
            getWallet: jest.fn(),
            getTransactions: jest.fn(),
            getStreak: jest.fn(),
            getAchievements: jest.fn(),
            getLevels: jest.fn(),
            getRewardsCatalog: jest.fn(),
            getRewardDetails: jest.fn(),
            redeemReward: jest.fn(),
            getMyOffers: jest.fn(),
            seedDemoRewards: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<RewardsController>(RewardsController);
    service = module.get<RewardsService>(RewardsService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getWallet', () => {
    it('should return wallet', async () => {
      const user = { id: 'u1' };
      await controller.getWallet(user);
      expect(service.getWallet).toHaveBeenCalledWith('u1');
    });
  });

  describe('getTransactions', () => {
    it('should return transactions with default pagination', async () => {
      const user = { id: 'u1' };
      await controller.getTransactions(user);
      expect(service.getTransactions).toHaveBeenCalledWith('u1', 1, 20);
    });

    it('should return transactions with custom pagination', async () => {
      const user = { id: 'u1' };
      await controller.getTransactions(user, 2, 10);
      expect(service.getTransactions).toHaveBeenCalledWith('u1', 2, 10);
    });
  });

  describe('getStreak', () => {
    it('should return streak', async () => {
      const user = { id: 'u1' };
      await controller.getStreak(user);
      expect(service.getStreak).toHaveBeenCalledWith('u1');
    });
  });

  describe('getAchievements', () => {
    it('should return achievements', async () => {
      const user = { id: 'u1' };
      await controller.getAchievements(user);
      expect(service.getAchievements).toHaveBeenCalledWith('u1');
    });
  });

  describe('getLevels', () => {
    it('should return levels', async () => {
      await controller.getLevels();
      expect(service.getLevels).toHaveBeenCalled();
    });
  });

  describe('getCatalog', () => {
    it('should return catalog without category', async () => {
      const user = { id: 'u1' };
      await controller.getCatalog(user);
      expect(service.getRewardsCatalog).toHaveBeenCalledWith('u1', undefined);
    });

    it('should return catalog with category', async () => {
      const user = { id: 'u1' };
      await controller.getCatalog(user, 'food');
      expect(service.getRewardsCatalog).toHaveBeenCalledWith('u1', 'food');
    });
  });

  describe('getRewardDetails', () => {
    it('should return reward details', async () => {
      const user = { id: 'u1' };
      await controller.getRewardDetails('r1', user);
      expect(service.getRewardDetails).toHaveBeenCalledWith('r1', 'u1');
    });
  });

  describe('redeemReward', () => {
    it('should redeem reward', async () => {
      const user = { id: 'u1' };
      const dto: RedeemRewardDto = { rewardId: 'r1' };
      await controller.redeemReward(user, dto);
      expect(service.redeemReward).toHaveBeenCalledWith('u1', 'r1');
    });
  });

  describe('getMyOffers', () => {
    it('should return my offers without status', async () => {
      const user = { id: 'u1' };
      await controller.getMyOffers(user);
      expect(service.getMyOffers).toHaveBeenCalledWith('u1', undefined);
    });

    it('should return my offers with status', async () => {
      const user = { id: 'u1' };
      await controller.getMyOffers(user, 'active');
      expect(service.getMyOffers).toHaveBeenCalledWith('u1', 'active');
    });
  });

  describe('seedRewards', () => {
    it('should seed rewards', async () => {
      await controller.seedRewards();
      expect(service.seedDemoRewards).toHaveBeenCalled();
    });
  });
});
