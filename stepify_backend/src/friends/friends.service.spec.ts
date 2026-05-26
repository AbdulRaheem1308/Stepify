import { Test, TestingModule } from "@nestjs/testing";
import { FriendsService } from "./friends.service";
import { PrismaService } from "../prisma/prisma.service";
import { RedisService } from "../redis/redis.service";
import {
  NotFoundException,
  ConflictException,
  BadRequestException,
} from "@nestjs/common";

describe("FriendsService", () => {
  let service: FriendsService;

  const mockPrisma: any = {
    $transaction: jest.fn(async (cb) => cb(mockPrisma)),
    friendship: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
    user: {
      findMany: jest.fn(),
    },
    friendBoost: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
    },
    wallet: {
      upsert: jest.fn(),
      findMany: jest.fn(),
    },
    transaction: {
      create: jest.fn(),
    },
    invitation: {
      create: jest.fn(),
      findMany: jest.fn(),
    },
  };

  const mockRedis = {
    getCache: jest.fn(),
    setCache: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FriendsService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: RedisService, useValue: mockRedis },
      ],
    }).compile();

    service = module.get<FriendsService>(FriendsService);

    jest.clearAllMocks();
  });

  it("should be defined", () => {
    expect(service).toBeDefined();
  });

  describe("getFriends", () => {
    it("should return empty array if no friends", async () => {
      mockPrisma.friendship.findMany.mockResolvedValueOnce([]);
      const res = await service.getFriends("u1");
      expect(res).toEqual([]);
    });

    it("should map friends and calculate steps/boosts", async () => {
      mockPrisma.friendship.findMany.mockResolvedValueOnce([
        { userId: "u1", friendId: "f1", status: "ACCEPTED" },
      ]);
      mockPrisma.user.findMany.mockResolvedValueOnce([
        {
          id: "f1",
          name: "Friend",
          steps: [{ stepCount: 500 }, { stepCount: 200 }],
        },
      ]);
      mockPrisma.friendBoost.findMany.mockResolvedValueOnce([
        { receiverId: "f1" },
      ]);

      const res = await service.getFriends("u1");
      expect(res).toHaveLength(1);
      expect(res[0].id).toBe("f1");
      expect(res[0].dailyStepCount).toBe(700);
      expect(res[0].boostSentToday).toBe(true);
    });
  });

  describe("getPendingRequests", () => {
    it("should return pending request senders", async () => {
      mockPrisma.friendship.findMany.mockResolvedValueOnce([{ userId: "u2" }]);
      mockPrisma.user.findMany.mockResolvedValueOnce([
        { id: "u2", name: "Sender" },
      ]);

      const res = await service.getPendingRequests("u1");
      expect(res).toHaveLength(1);
      expect(res[0].id).toBe("u2");
    });

    it("should return empty if no pending", async () => {
      mockPrisma.friendship.findMany.mockResolvedValueOnce([]);
      const res = await service.getPendingRequests("u1");
      expect(res).toEqual([]);
    });
  });

  describe("searchUsers", () => {
    it("should return empty if query is empty", async () => {
      const res = await service.searchUsers("u1", "");
      expect(res).toEqual([]);
    });

    it("should return empty if query too short", async () => {
      const res = await service.searchUsers("u1", "a");
      expect(res).toEqual([]);
    });

    it("should search users and map friendship status", async () => {
      mockPrisma.user.findMany.mockResolvedValueOnce([{ id: "u2" }]);
      mockPrisma.friendship.findMany.mockResolvedValueOnce([
        { userId: "u1", friendId: "u2", status: "PENDING" },
      ]);

      const res = await service.searchUsers("u1", "test");
      expect(res).toHaveLength(1);
      expect(res[0].friendshipStatus).toBe("PENDING");
    });
  });

  describe("sendFriendRequest", () => {
    it("should throw if self", async () => {
      await expect(service.sendFriendRequest("u1", "u1")).rejects.toThrow(
        BadRequestException,
      );
    });

    it("should throw if exists", async () => {
      mockPrisma.friendship.findFirst.mockResolvedValueOnce({ id: "f1" });
      await expect(service.sendFriendRequest("u1", "u2")).rejects.toThrow(
        ConflictException,
      );
    });

    it("should create request", async () => {
      mockPrisma.friendship.findFirst.mockResolvedValueOnce(null);
      mockPrisma.friendship.create.mockResolvedValueOnce({ id: "f1" });
      const res = await service.sendFriendRequest("u1", "u2");
      expect(res.id).toBe("f1");
    });
  });

  describe("acceptFriendRequest", () => {
    it("should throw if not found", async () => {
      mockPrisma.friendship.findFirst.mockResolvedValueOnce(null);
      await expect(service.acceptFriendRequest("u1", "u2")).rejects.toThrow(
        NotFoundException,
      );
    });

    it("should accept request", async () => {
      mockPrisma.friendship.findFirst.mockResolvedValueOnce({ id: "req1" });
      mockPrisma.friendship.update.mockResolvedValueOnce({
        status: "ACCEPTED",
      });
      const res = await service.acceptFriendRequest("u1", "u2");
      expect(res.status).toBe("ACCEPTED");
    });
  });

  describe("sendBoost", () => {
    it("should throw if boost already sent", async () => {
      mockPrisma.friendBoost.findFirst.mockResolvedValueOnce({ id: "b1" });
      await expect(service.sendBoost("u1", "u2")).rejects.toThrow(
        ConflictException,
      );
    });

    it("should throw if not friends", async () => {
      mockPrisma.friendBoost.findFirst.mockResolvedValueOnce(null);
      mockPrisma.friendship.findFirst.mockResolvedValueOnce(null);
      await expect(service.sendBoost("u1", "u2")).rejects.toThrow(
        BadRequestException,
      );
    });

    it("should send boost and award coins", async () => {
      mockPrisma.friendBoost.findFirst.mockResolvedValueOnce(null);
      mockPrisma.friendship.findFirst.mockResolvedValueOnce({ id: "f1" });
      mockPrisma.friendBoost.create.mockResolvedValueOnce({ id: "b1" });

      const res = await service.sendBoost("u1", "u2");
      expect(res.success).toBe(true);
      expect(mockPrisma.friendBoost.create).toHaveBeenCalled();
      expect(mockPrisma.wallet.upsert).toHaveBeenCalled();
    });
  });

  describe("getMiniLeaderboard", () => {
    it("should sort friends by daily steps and return top 5", async () => {
      mockPrisma.friendship.findMany.mockResolvedValueOnce([
        { userId: "u1", friendId: "f1", status: "ACCEPTED" },
        { userId: "u1", friendId: "f2", status: "ACCEPTED" },
      ]);
      mockPrisma.user.findMany.mockResolvedValueOnce([
        { id: "f1", steps: [{ stepCount: 100 }] },
        { id: "f2", steps: [{ stepCount: 500 }] },
      ]);
      mockPrisma.friendBoost.findMany.mockResolvedValueOnce([]);

      const res = await service.getMiniLeaderboard("u1");
      expect(res).toHaveLength(2);
      expect(res[0].id).toBe("f2"); // highest steps first
      expect(res[0].rank).toBe(1);
    });
  });

  describe("invitations", () => {
    it("should create invitation", async () => {
      mockPrisma.invitation.create.mockResolvedValueOnce({ id: "inv1" });
      const res = await service.createInvitation("u1", "t@t.com");
      expect(res.id).toBe("inv1");
    });

    it("should get invitations", async () => {
      mockPrisma.invitation.findMany.mockResolvedValueOnce([{ id: "inv1" }]);
      const res = await service.getInvitations("u1");
      expect(res).toHaveLength(1);
    });
  });

  describe("removeFriend", () => {
    it("should throw if not found", async () => {
      mockPrisma.friendship.findFirst.mockResolvedValueOnce(null);
      await expect(service.removeFriend("u1", "u2")).rejects.toThrow(
        NotFoundException,
      );
    });

    it("should remove friend", async () => {
      mockPrisma.friendship.findFirst.mockResolvedValueOnce({ id: "f1" });
      const res = await service.removeFriend("u1", "u2");
      expect(res.success).toBe(true);
      expect(mockPrisma.friendship.delete).toHaveBeenCalled();
    });
  });

  describe("getGlobalLeaderboard", () => {
    it("should return from cache", async () => {
      mockRedis.getCache.mockResolvedValueOnce([{ id: "u1" }]);
      const res = await service.getGlobalLeaderboard();
      expect(res).toHaveLength(1);
    });

    it("should compute monthly leaderboard", async () => {
      mockRedis.getCache.mockResolvedValueOnce(null);
      mockPrisma.wallet.findMany.mockResolvedValueOnce([
        { user: { id: "u1" }, monthlyXp: 100 },
      ]);
      const res = await service.getGlobalLeaderboard("monthly");
      expect(res[0].xp).toBe(100);
      expect(mockRedis.setCache).toHaveBeenCalled();
    });

    it("should compute allTime leaderboard", async () => {
      mockRedis.getCache.mockResolvedValueOnce(null);
      mockPrisma.wallet.findMany.mockResolvedValueOnce([
        { user: { id: "u1" }, lifetimePoints: 500 },
      ]);
      const res = await service.getGlobalLeaderboard("allTime");
      expect(res[0].xp).toBe(500);
    });

    it("should compute daily/weekly leaderboard", async () => {
      mockRedis.getCache.mockResolvedValueOnce(null);
      mockPrisma.user.findMany.mockResolvedValueOnce([
        { id: "u1", steps: [{ stepCount: 100 }] },
        { id: "u2", steps: [{ stepCount: 200 }] },
      ]);
      const res = await service.getGlobalLeaderboard("weekly");
      expect(res[0].todaySteps).toBe(200);
      expect(res[1].todaySteps).toBe(100);
    });
  });
});
