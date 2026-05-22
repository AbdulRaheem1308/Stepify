import { Test, TestingModule } from "@nestjs/testing";
import { StepsService } from "./steps.service";
import { PrismaService } from "../prisma/prisma.service";
import { ConfigService } from "@nestjs/config";
import { RewardsService } from "../rewards/rewards.service";
import { PostHogService } from "../analytics/posthog.service";
import { RedisService } from "../redis/redis.service";
import { getQueueToken } from "@nestjs/bullmq";

describe("StepsService", () => {
  let service: StepsService;
  let prismaService: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        StepsService,
        {
          provide: RewardsService,
          useValue: { processStepMilestones: jest.fn() },
        },
        {
          provide: PostHogService,
          useValue: { capture: jest.fn() },
        },
        {
          provide: RedisService,
          useValue: {
            getClient: jest.fn().mockReturnValue({ zadd: jest.fn() }),
          },
        },
        {
          provide: getQueueToken("steps-processing"),
          useValue: { add: jest.fn() },
        },
        {
          provide: PrismaService,
          useValue: {
            $transaction: jest.fn((callback) => callback(prismaService)),
            step: {
              findUnique: jest.fn(),
              upsert: jest.fn(),
              findMany: jest.fn(),
              aggregate: jest.fn(),
            },
            user: {
              findUnique: jest.fn(),
              update: jest.fn(),
            },
            wallet: {
              upsert: jest.fn(),
            },
            transaction: {
              create: jest.fn(),
            },
            streak: {
              upsert: jest.fn(),
            },
            teamMember: {
              findMany: jest.fn(),
            },
            device: {
              findFirst: jest.fn(),
            },
          },
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn().mockReturnValue("100"), // E.g., points per 10k steps
          },
        },
      ],
    }).compile();

    service = module.get<StepsService>(StepsService);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  it("should be defined", () => {
    expect(service).toBeDefined();
  });

  describe("syncSteps (Atomic Guarantee)", () => {
    it("should successfully sync steps and update wallet atomically", async () => {
      const mockUser = { id: "user-1", dailyStepGoal: 10000 };
      const dto = {
        stepCount: 5000,
        date: "2026-05-22",
        source: "apple_health",
        deviceIdentifier: "watch-1",
      };
      const mockExistingStep = null; // No previous steps today
      const mockDevice = {
        id: "device-1",
        userId: "user-1",
        identifier: "watch-1",
      };

      (prismaService.user.findUnique as jest.Mock).mockResolvedValue(mockUser);
      (prismaService.step.findUnique as jest.Mock).mockResolvedValue(
        mockExistingStep,
      );
      (prismaService.step.upsert as jest.Mock).mockResolvedValue({
        ...dto,
        id: "step-1",
      });
      (prismaService.device.findFirst as jest.Mock).mockResolvedValue(
        mockDevice,
      );

      const result = await service.syncSteps("user-1", dto);

      expect(prismaService.$transaction).toHaveBeenCalled();
      expect(prismaService.step.findUnique).toHaveBeenCalled();
      expect(prismaService.step.upsert).toHaveBeenCalled();
      expect(result.id).toEqual("step-1");
    });

    it("should not decrement steps if incoming sync is lower than DB value", async () => {
      const mockUser = { id: "user-1", dailyStepGoal: 10000 };
      const dto = {
        stepCount: 2000,
        date: "2026-05-22",
        source: "google_fit",
        deviceIdentifier: "watch-1",
      };
      const mockExistingStep = { id: "step-1", stepCount: 5000 }; // DB has 5000
      const mockDevice = {
        id: "device-1",
        userId: "user-1",
        identifier: "watch-1",
      };

      (prismaService.user.findUnique as jest.Mock).mockResolvedValue(mockUser);
      (prismaService.step.findUnique as jest.Mock).mockResolvedValue(
        mockExistingStep,
      );
      (prismaService.step.upsert as jest.Mock).mockResolvedValue({
        ...dto,
        id: "step-1",
        stepCount: 5000,
      });
      (prismaService.device.findFirst as jest.Mock).mockResolvedValue(
        mockDevice,
      );

      const result = await service.syncSteps("user-1", dto);

      expect(prismaService.step.upsert).toHaveBeenCalledWith(
        expect.objectContaining({
          update: expect.objectContaining({
            stepCount: 5000, // Should preserve the higher count
          }),
        }),
      );
      expect(result.id).toEqual("step-1");
    });
  });
});
