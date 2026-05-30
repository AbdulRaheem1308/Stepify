import { Test, TestingModule } from "@nestjs/testing";
import { Logger } from "@nestjs/common";
import { RewardsCronService } from "./rewards.cron.service";
import { PrismaService } from "../prisma/prisma.service";
import { RewardsService } from "./rewards.service";

jest.spyOn(Logger.prototype, "log").mockImplementation(() => undefined);
jest.spyOn(Logger.prototype, "error").mockImplementation(() => undefined);

describe("RewardsCronService", () => {
  let service: RewardsCronService;

  const mockPrisma: any = {
    step: {
      findMany: jest.fn(),
    },
  };

  const mockRewardsService = {
    processStepRewards: jest.fn().mockResolvedValue({ pointsEarned: 100 }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RewardsCronService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: RewardsService, useValue: mockRewardsService },
      ],
    }).compile();

    service = module.get<RewardsCronService>(RewardsCronService);
    jest.clearAllMocks();
  });

  it("should be defined", () => {
    expect(service).toBeDefined();
  });

  describe("handleRewardsSync", () => {
    it("should process rewards for each user with steps today", async () => {
      mockPrisma.step.findMany.mockResolvedValueOnce([
        { userId: "u1", stepCount: 5000 },
        { userId: "u2", stepCount: 8000 },
      ]);

      await service.handleRewardsSync();

      expect(mockRewardsService.processStepRewards).toHaveBeenCalledTimes(2);
      expect(mockRewardsService.processStepRewards).toHaveBeenCalledWith(
        "u1",
        5000,
        expect.any(Date),
      );
      expect(mockRewardsService.processStepRewards).toHaveBeenCalledWith(
        "u2",
        8000,
        expect.any(Date),
      );
    });

    it("should handle empty steps list gracefully", async () => {
      mockPrisma.step.findMany.mockResolvedValueOnce([]);

      await service.handleRewardsSync();

      expect(mockRewardsService.processStepRewards).not.toHaveBeenCalled();
    });

    it("should continue processing other users even if one fails", async () => {
      mockPrisma.step.findMany.mockResolvedValueOnce([
        { userId: "u1", stepCount: 5000 },
        { userId: "u2", stepCount: 8000 },
      ]);

      mockRewardsService.processStepRewards
        .mockRejectedValueOnce(new Error("Failure for u1"))
        .mockResolvedValueOnce({ pointsEarned: 800 });

      await service.handleRewardsSync();

      // Should still process u2 even though u1 failed
      expect(mockRewardsService.processStepRewards).toHaveBeenCalledTimes(2);
    });

    it("should handle and log error if prisma throws", async () => {
      mockPrisma.step.findMany.mockRejectedValueOnce(new Error("DB Error"));

      await expect(service.handleRewardsSync()).resolves.toBeUndefined();
    });
  });
});
