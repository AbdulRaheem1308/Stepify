import { Test, TestingModule } from "@nestjs/testing";
import { StepsProcessor } from "./steps.processor";
import { PrismaService } from "../prisma/prisma.service";
import { PostHogService } from "../analytics/posthog.service";
import { LeaderboardGateway } from "./gateways/leaderboard.gateway";
import { Logger } from "@nestjs/common";

describe("StepsProcessor", () => {
  let processor: StepsProcessor;
  let prismaService: any;
  let postHogService: any;
  let leaderboardGateway: any;

  beforeEach(async () => {
    prismaService = {
      step: {
        aggregate: jest.fn(),
      },
      companyMember: {
        findUnique: jest.fn(),
        update: jest.fn(),
        findMany: jest.fn(),
      },
    };

    postHogService = {
      trackStepSync: jest.fn(),
    };

    leaderboardGateway = {
      broadcastLeaderboardUpdate: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        StepsProcessor,
        { provide: PrismaService, useValue: prismaService },
        { provide: PostHogService, useValue: postHogService },
        { provide: LeaderboardGateway, useValue: leaderboardGateway },
      ],
    }).compile();

    processor = module.get<StepsProcessor>(StepsProcessor);
    jest.spyOn(Logger.prototype, "log").mockImplementation(() => {});
    jest.spyOn(Logger.prototype, "error").mockImplementation(() => {});
    jest.spyOn(Logger.prototype, "warn").mockImplementation(() => {});
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("should be defined", () => {
    expect(processor).toBeDefined();
  });

  describe("process-sync", () => {
    const jobData = {
      userId: "user1",
      effectiveStepCount: 1000,
      date: new Date().toISOString(),
      effectiveSource: "healthkit",
    };

    const mockJob: any = {
      id: "job-1",
      name: "process-sync",
      data: jobData,
    };

    it("should successfully update company cache and log analytics", async () => {
      // Mock corporate logic
      prismaService.step.aggregate.mockResolvedValue({
        _sum: { stepCount: 5000 },
      });
      const mockMember = { userId: "user1", companyId: "comp1" };
      prismaService.companyMember.findUnique.mockResolvedValue(mockMember);
      prismaService.companyMember.update.mockResolvedValue(mockMember);
      prismaService.companyMember.findMany.mockResolvedValue([mockMember]);

      // Mock posthog success
      postHogService.trackStepSync.mockResolvedValue(undefined);

      await processor.process(mockJob);

      expect(prismaService.step.aggregate).toHaveBeenCalled();
      expect(prismaService.companyMember.update).toHaveBeenCalledWith({
        where: { userId: "user1" },
        data: { totalSteps: 5000 },
      });
      expect(
        leaderboardGateway.broadcastLeaderboardUpdate,
      ).toHaveBeenCalledWith("comp1", [mockMember]);
      expect(postHogService.trackStepSync).toHaveBeenCalledWith(
        "user1",
        1000,
        "healthkit",
      );
    });

    it("should handle corporate leaderboard gracefully if user has no steps sum", async () => {
      prismaService.step.aggregate.mockResolvedValue({
        _sum: { stepCount: null },
      });
      prismaService.companyMember.findUnique.mockResolvedValue({
        userId: "user1",
        companyId: "comp1",
      });

      await processor.process(mockJob);

      expect(prismaService.companyMember.update).toHaveBeenCalledWith({
        where: { userId: "user1" },
        data: { totalSteps: 0 },
      });
    });

    it("should handle failure in corporate leaderboard update", async () => {
      prismaService.step.aggregate.mockRejectedValue(
        new Error("Prisma failure"),
      );

      await processor.process(mockJob);

      expect(Logger.prototype.error).toHaveBeenCalledWith(
        expect.stringContaining("Failed to update corporate leaderboard stats"),
      );
    });

    it("should handle failure in PostHog analytics", async () => {
      prismaService.step.aggregate.mockResolvedValue({
        _sum: { stepCount: 100 },
      });
      prismaService.companyMember.findUnique.mockResolvedValue(null);
      postHogService.trackStepSync.mockRejectedValue(new Error("Posthog down"));

      await processor.process(mockJob);

      expect(Logger.prototype.warn).toHaveBeenCalledWith(
        expect.stringContaining("PostHog analytics logging failed"),
      );
    });
  });

  describe("unknown job", () => {
    it("should log a warning for unknown job type", async () => {
      const mockJob: any = {
        id: "job-unknown",
        name: "unknown-type",
        data: {},
      };

      await processor.process(mockJob);
      expect(Logger.prototype.warn).toHaveBeenCalledWith(
        expect.stringContaining("Unknown background job type"),
      );
    });
  });
});
