import { Test, TestingModule } from "@nestjs/testing";
import { QuestsService } from "./quests.service";
import { PrismaService } from "../prisma/prisma.service";
import { NotificationsService } from "../notifications/notifications.service";

describe("QuestsService", () => {
  let service: QuestsService;

  const mockPrismaService = {
    quest: {
      count: jest.fn(),
      create: jest.fn(),
      findMany: jest.fn(),
    },
    userQuest: {
      findUnique: jest.fn(),
      create: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
    },
    $transaction: jest.fn(),
    wallet: {
      upsert: jest.fn(),
    },
    transaction: {
      create: jest.fn(),
    },
    notification: {
      create: jest.fn(),
    },
  };

  const mockNotificationsService = {
    sendPushToUser: jest.fn().mockResolvedValue(true),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        QuestsService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: NotificationsService, useValue: mockNotificationsService },
      ],
    }).compile();

    service = module.get<QuestsService>(QuestsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("should be defined", () => {
    expect(service).toBeDefined();
  });

  describe("onModuleInit", () => {
    it("should seed quests if count is 0", async () => {
      mockPrismaService.quest.count.mockResolvedValueOnce(0);
      mockPrismaService.quest.create.mockResolvedValue({});

      await service.onModuleInit();

      expect(mockPrismaService.quest.count).toHaveBeenCalled();
      expect(mockPrismaService.quest.create).toHaveBeenCalledTimes(2);
    });

    it("should not seed quests if count > 0", async () => {
      mockPrismaService.quest.count.mockResolvedValueOnce(2);

      await service.onModuleInit();

      expect(mockPrismaService.quest.count).toHaveBeenCalled();
      expect(mockPrismaService.quest.create).not.toHaveBeenCalled();
    });
  });

  describe("findAll", () => {
    it("should return all quests", async () => {
      mockPrismaService.quest.findMany.mockResolvedValueOnce([{ id: "q1" }]);
      const result = await service.findAll();
      expect(result).toEqual([{ id: "q1" }]);
    });
  });

  describe("joinQuest", () => {
    it("should return existing user quest if already joined", async () => {
      mockPrismaService.userQuest.findUnique.mockResolvedValueOnce({
        id: "uq1",
      });
      const result = await service.joinQuest("user1", "q1");
      expect(result).toEqual({ id: "uq1" });
      expect(mockPrismaService.userQuest.create).not.toHaveBeenCalled();
    });

    it("should create new user quest if not joined", async () => {
      mockPrismaService.userQuest.findUnique.mockResolvedValueOnce(null);
      mockPrismaService.userQuest.create.mockResolvedValueOnce({ id: "uq2" });
      const result = await service.joinQuest("user1", "q1");
      expect(result).toEqual({ id: "uq2" });
      expect(mockPrismaService.userQuest.create).toHaveBeenCalled();
    });
  });

  describe("getUserQuests", () => {
    it("should return user quests", async () => {
      mockPrismaService.userQuest.findMany.mockResolvedValueOnce([
        { id: "uq1" },
      ]);
      const result = await service.getUserQuests("user1");
      expect(result).toEqual([{ id: "uq1" }]);
    });
  });

  describe("processQuestProgress", () => {
    it("should do nothing if no active quests", async () => {
      mockPrismaService.userQuest.findMany.mockResolvedValueOnce([]);
      await service.processQuestProgress("user1", 5000);
      expect(mockPrismaService.userQuest.update).not.toHaveBeenCalled();
    });

    it("should do nothing if step count < targetSteps", async () => {
      mockPrismaService.userQuest.findMany.mockResolvedValueOnce([
        {
          id: "uq1",
          currentStageIndex: 0,
          quest: { stages: [{ targetSteps: 10000 }] },
        },
      ]);
      await service.processQuestProgress("user1", 5000);
      expect(mockPrismaService.userQuest.update).not.toHaveBeenCalled();
    });

    it("should advance to next stage if step count >= targetSteps and not last stage", async () => {
      mockPrismaService.userQuest.findMany.mockResolvedValueOnce([
        {
          id: "uq1",
          currentStageIndex: 0,
          quest: {
            title: "Q",
            stages: [
              { title: "S1", targetSteps: 5000 },
              { title: "S2", targetSteps: 10000 },
            ],
          },
        },
      ]);
      mockPrismaService.userQuest.updateMany.mockResolvedValueOnce({ count: 1 });
      mockPrismaService.notification.create.mockResolvedValueOnce({});

      await service.processQuestProgress("user1", 5000);

      expect(mockPrismaService.userQuest.updateMany).toHaveBeenCalledWith({
        where: { id: "uq1", currentStageIndex: 0, status: "IN_PROGRESS" },
        data: { currentStageIndex: 1 },
      });
      expect(mockPrismaService.notification.create).toHaveBeenCalled();
      expect(mockPrismaService.$transaction).not.toHaveBeenCalled();
    });

    it("should complete quest and award rewards if last stage completed", async () => {
      mockPrismaService.userQuest.findMany.mockResolvedValueOnce([
        {
          id: "uq1",
          currentStageIndex: 1,
          quest: {
            title: "Q",
            rewardCoins: 100,
            rewardXp: 50,
            stages: [
              { title: "S1", targetSteps: 5000 },
              { title: "S2", targetSteps: 10000 },
            ],
          },
        },
      ]);

      mockPrismaService.$transaction.mockImplementationOnce(async (cb) => {
        const tx = {
          userQuest: { updateMany: jest.fn().mockResolvedValue({ count: 1 }) },
          wallet: { upsert: jest.fn().mockResolvedValue({}) },
          transaction: { create: jest.fn().mockResolvedValue({}) },
          notification: { create: jest.fn().mockResolvedValue({}) },
        };
        return cb(tx);
      });

      await service.processQuestProgress("user1", 10000);

      expect(mockPrismaService.$transaction).toHaveBeenCalled();
    });
  });
});
