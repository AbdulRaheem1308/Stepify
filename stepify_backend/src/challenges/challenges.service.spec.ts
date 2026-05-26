import { Test, TestingModule } from "@nestjs/testing";
import { ChallengesService } from "./challenges.service";
import { PrismaService } from "../prisma/prisma.service";
import { RedisService } from "../redis/redis.service";
import { NotificationsService } from "../notifications/notifications.service";
import {
  NotFoundException,
  BadRequestException,
  ConflictException,
} from "@nestjs/common";

const mockRedisClient = {
  set: jest.fn(),
  del: jest.fn(),
};

const mockRedisService = {
  getClient: jest.fn(() => mockRedisClient),
};

const mockNotificationsService = {
  createAndNotify: jest.fn().mockResolvedValue(true),
};

const mockPrismaService: any = {
  challenge: {
    updateMany: jest.fn(),
    create: jest.fn(),
    findMany: jest.fn(),
    findUnique: jest.fn(),
    upsert: jest.fn(),
  },
  userChallenge: {
    findMany: jest.fn(),
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
  },
  wallet: { upsert: jest.fn() },
  transaction: { create: jest.fn() },
  $transaction: jest.fn((queries) => {
    if (typeof queries === "function") {
      return queries(mockPrismaService);
    }
    return Promise.resolve(queries);
  }),
};

describe("ChallengesService", () => {
  let service: ChallengesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ChallengesService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: RedisService, useValue: mockRedisService },
        { provide: NotificationsService, useValue: mockNotificationsService },
      ],
    }).compile();
    service = module.get<ChallengesService>(ChallengesService);
    jest.clearAllMocks();
  });

  it("should be defined", () => {
    expect(service).toBeDefined();
  });

  describe("generateDailyMissions", () => {
    it("should skip if lock not acquired", async () => {
      mockRedisClient.set.mockResolvedValue(null);
      await service.generateDailyMissions();
      expect(mockPrismaService.challenge.updateMany).not.toHaveBeenCalled();
    });
    it("should run daily missions generation", async () => {
      mockRedisClient.set.mockResolvedValue("OK");
      mockPrismaService.challenge.updateMany.mockResolvedValue({ count: 1 });
      mockPrismaService.challenge.create.mockResolvedValue({});
      await service.generateDailyMissions();
      expect(mockPrismaService.challenge.updateMany).toHaveBeenCalled();
      expect(mockPrismaService.challenge.create).toHaveBeenCalledTimes(3);
    });
  });

  describe("findAll", () => {
    it("should return all challenges", async () => {
      mockPrismaService.challenge.findMany.mockResolvedValue([{ id: "c1" }]);
      const res = await service.findAll();
      expect(res.length).toBe(1);
    });
  });

  describe("findUserChallenges", () => {
    it("should return challenges for a user", async () => {
      mockPrismaService.userChallenge.findMany.mockResolvedValue([
        { id: "uc1" },
      ]);
      const res = await service.findUserChallenges("u1");
      expect(res.length).toBe(1);
    });
  });

  describe("findOne", () => {
    it("should throw NotFound if challenge does not exist", async () => {
      mockPrismaService.challenge.findUnique.mockResolvedValue(null);
      await expect(service.findOne("c1")).rejects.toThrow(NotFoundException);
    });
    it("should return challenge", async () => {
      mockPrismaService.challenge.findUnique.mockResolvedValue({ id: "c1" });
      const res = await service.findOne("c1");
      expect(res.id).toBe("c1");
    });
  });

  describe("create", () => {
    it("should create a challenge", async () => {
      mockPrismaService.challenge.create.mockResolvedValue({ id: "c1" });
      const res = await service.create({
        title: "T",
        description: "D",
        stepTarget: 100,
        durationDays: 1,
        challengeType: "SOLO",
        difficulty: "EASY",
        imageUrl: "",
      } as any);
      expect(res.id).toBe("c1");
    });
  });

  describe("join", () => {
    it("should throw NotFound if challenge not found", async () => {
      mockPrismaService.challenge.findUnique.mockResolvedValue(null);
      await expect(service.join("u1", "c1")).rejects.toThrow(NotFoundException);
    });
    it("should throw BadRequest if challenge is not active", async () => {
      mockPrismaService.challenge.findUnique.mockResolvedValue({
        id: "c1",
        isActive: false,
      });
      await expect(service.join("u1", "c1")).rejects.toThrow(
        BadRequestException,
      );
    });
    it("should throw Conflict if already joined", async () => {
      mockPrismaService.challenge.findUnique.mockResolvedValue({
        id: "c1",
        isActive: true,
      });
      mockPrismaService.userChallenge.findUnique.mockResolvedValue({
        id: "uc1",
      });
      await expect(service.join("u1", "c1")).rejects.toThrow(ConflictException);
    });
    it("should join successfully", async () => {
      mockPrismaService.challenge.findUnique.mockResolvedValue({
        id: "c1",
        isActive: true,
      });
      mockPrismaService.userChallenge.findUnique.mockResolvedValue(null);
      mockPrismaService.userChallenge.create.mockResolvedValue({ id: "uc1" });
      const res = await service.join("u1", "c1");
      expect(res.id).toBe("uc1");
    });
  });

  describe("updateProgress", () => {
    it("should throw NotFound if user challenge not found", async () => {
      mockPrismaService.userChallenge.findUnique.mockResolvedValue(null);
      await expect(service.updateProgress("u1", "c1", 100)).rejects.toThrow(
        NotFoundException,
      );
    });
    it("should throw BadRequest if challenge not ongoing", async () => {
      mockPrismaService.userChallenge.findUnique.mockResolvedValue({
        status: "COMPLETED",
      });
      await expect(service.updateProgress("u1", "c1", 100)).rejects.toThrow(
        BadRequestException,
      );
    });
    it("should update progress successfully", async () => {
      mockPrismaService.userChallenge.findUnique.mockResolvedValue({
        status: "ONGOING",
        currentSteps: 0,
        challenge: { stepTarget: 100, rewardCoins: 10 },
      });
      mockPrismaService.userChallenge.update.mockResolvedValue({
        status: "COMPLETED",
      });
      const res = await service.updateProgress("u1", "c1", 100);
      expect(res.status).toBe("COMPLETED");
    });
  });

  describe("findNewChallenges", () => {
    it("should return challenges not joined by user", async () => {
      mockPrismaService.userChallenge.findMany.mockResolvedValue([
        { challengeId: "c1" },
      ]);
      mockPrismaService.challenge.findMany.mockResolvedValue([{ id: "c2" }]);
      const res = await service.findNewChallenges("u1");
      expect(res.length).toBe(1);
      expect(res[0].id).toBe("c2");
    });
  });

  describe("seedDemoChallenges", () => {
    it("should upsert demo challenges", async () => {
      mockPrismaService.challenge.upsert.mockResolvedValue({});
      const res = await service.seedDemoChallenges();
      expect(res.message).toBe("Demo challenges seeded");
      expect(mockPrismaService.challenge.upsert).toHaveBeenCalled();
    });
  });
});
