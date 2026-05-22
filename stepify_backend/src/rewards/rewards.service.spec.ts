import { Test, TestingModule } from "@nestjs/testing";
import { RewardsService } from "./rewards.service";
import { PrismaService } from "../prisma/prisma.service";
import { ConfigService } from "@nestjs/config";
import { QuestsService } from "../quests/quests.service";
import {} from "@nestjs/common";

describe("RewardsService", () => {
  let service: RewardsService;
  let prismaService: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RewardsService,
        {
          provide: ConfigService,
          useValue: { get: jest.fn() },
        },
        {
          provide: QuestsService,
          useValue: { checkQuests: jest.fn() },
        },
        {
          provide: PrismaService,
          useValue: {
            $transaction: jest.fn((callback) => callback(prismaService)),
            reward: {
              findUnique: jest.fn(),
              update: jest.fn(),
            },
            wallet: {
              findUnique: jest.fn(),
              update: jest.fn(),
            },
            userRedemption: {
              create: jest.fn(),
            },
            transaction: {
              create: jest.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<RewardsService>(RewardsService);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  it("should be defined", () => {
    expect(service).toBeDefined();
  });

  describe("redeemReward (Transactional Integrity)", () => {
    it("should successfully redeem a reward when balance is sufficient and stock is available", async () => {
      const mockReward = {
        id: "reward-1",
        coinCost: 100,
        availableStock: 10,
        isActive: true,
      };
      const mockWallet = { id: "wallet-1", userId: "user-1", balance: 200 };

      // Mock the tx methods
      (prismaService.reward.findUnique as jest.Mock).mockResolvedValue(
        mockReward,
      );
      (prismaService.wallet.findUnique as jest.Mock).mockResolvedValue(
        mockWallet,
      );
      (prismaService.wallet.update as jest.Mock).mockResolvedValue({
        ...mockWallet,
        balance: 100,
      });
      (prismaService.reward.update as jest.Mock).mockResolvedValue({
        ...mockReward,
        availableStock: 9,
      });

      const result = await service.redeemReward("user-1", "reward-1");

      expect(prismaService.$transaction).toHaveBeenCalled();
      expect(prismaService.wallet.update).toHaveBeenCalledWith({
        where: { userId: "user-1" },
        data: { balance: { decrement: 100 } },
      });
      expect(prismaService.userRedemption.create).toHaveBeenCalled();
      expect(result.success).toBe(true);
    });

    it("should throw Error if balance is insufficient", async () => {
      const mockReward = {
        id: "reward-1",
        coinCost: 100,
        availableStock: 10,
        isActive: true,
      };
      const mockWallet = { id: "wallet-1", userId: "user-1", balance: 50 }; // Too low!

      (prismaService.reward.findUnique as jest.Mock).mockResolvedValue(
        mockReward,
      );
      (prismaService.wallet.findUnique as jest.Mock).mockResolvedValue(
        mockWallet,
      );

      await expect(service.redeemReward("user-1", "reward-1")).rejects.toThrow(
        Error,
      );
      expect(prismaService.wallet.update).not.toHaveBeenCalled();
    });

    it("should throw Error if reward is out of stock", async () => {
      const mockReward = {
        id: "reward-1",
        coinCost: 100,
        availableStock: 0,
        isActive: true,
      }; // Out of stock
      const mockWallet = { id: "wallet-1", userId: "user-1", balance: 500 };

      (prismaService.reward.findUnique as jest.Mock).mockResolvedValue(
        mockReward,
      );
      (prismaService.wallet.findUnique as jest.Mock).mockResolvedValue(
        mockWallet,
      );

      await expect(service.redeemReward("user-1", "reward-1")).rejects.toThrow(
        Error,
      );
    });
  });
});
