import { Test, TestingModule } from "@nestjs/testing";
import { FriendsController } from "./friends.controller";
import { FriendsService } from "./friends.service";

describe("FriendsController", () => {
  let controller: FriendsController;
  let service: FriendsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [FriendsController],
      providers: [
        {
          provide: FriendsService,
          useValue: {
            getFriends: jest.fn(),
            getPendingRequests: jest.fn(),
            searchUsers: jest.fn(),
            getGlobalLeaderboard: jest.fn(),
            getMiniLeaderboard: jest.fn(),
            getInvitations: jest.fn(),
            sendFriendRequest: jest.fn(),
            acceptFriendRequest: jest.fn(),
            sendBoost: jest.fn(),
            createInvitation: jest.fn(),
            removeFriend: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<FriendsController>(FriendsController);
    service = module.get<FriendsService>(FriendsService);
  });

  it("should be defined", () => {
    expect(controller).toBeDefined();
  });

  describe("getFriends", () => {
    it("should get friends", async () => {
      const user = { id: "u1" };
      await controller.getFriends(user);
      expect(service.getFriends).toHaveBeenCalledWith("u1");
    });
  });

  describe("getPendingRequests", () => {
    it("should get pending requests", async () => {
      const user = { id: "u1" };
      await controller.getPendingRequests(user);
      expect(service.getPendingRequests).toHaveBeenCalledWith("u1");
    });
  });

  describe("searchUsers", () => {
    it("should search users", async () => {
      const user = { id: "u1" };
      await controller.searchUsers(user, "test");
      expect(service.searchUsers).toHaveBeenCalledWith("u1", "test");
    });
  });

  describe("getLeaderboard", () => {
    it("should return global leaderboard", async () => {
      const user = { id: "u1" };
      (service.getGlobalLeaderboard as jest.Mock).mockResolvedValueOnce([
        { id: "u1" },
        { id: "u2" },
      ]);
      const res = await controller.getLeaderboard(user, "global", "daily");

      expect(service.getGlobalLeaderboard).toHaveBeenCalledWith("daily");
      expect(res).toEqual([
        { id: "u1", isCurrentUser: true },
        { id: "u2", isCurrentUser: false },
      ]);
    });

    it("should return friends leaderboard", async () => {
      const user = { id: "u1" };
      (service.getMiniLeaderboard as jest.Mock).mockResolvedValueOnce([]);
      await controller.getLeaderboard(user, "friends", "weekly");

      expect(service.getMiniLeaderboard).toHaveBeenCalledWith("u1", "weekly");
    });
  });

  describe("getInvitations", () => {
    it("should get invitations", async () => {
      const user = { id: "u1" };
      await controller.getInvitations(user);
      expect(service.getInvitations).toHaveBeenCalledWith("u1");
    });
  });

  describe("sendRequest", () => {
    it("should send friend request", async () => {
      const user = { id: "u1" };
      await controller.sendRequest(user, { friendId: "u2" });
      expect(service.sendFriendRequest).toHaveBeenCalledWith("u1", "u2");
    });
  });

  describe("acceptRequest", () => {
    it("should accept friend request", async () => {
      const user = { id: "u1" };
      await controller.acceptRequest(user, { requesterId: "u2" });
      expect(service.acceptFriendRequest).toHaveBeenCalledWith("u1", "u2");
    });
  });

  describe("sendBoost", () => {
    it("should send boost", async () => {
      const user = { id: "u1" };
      await controller.sendBoost(user, { friendId: "u2" });
      expect(service.sendBoost).toHaveBeenCalledWith("u1", "u2");
    });
  });

  describe("createInvitation", () => {
    it("should create invitation", async () => {
      const user = { id: "u1" };
      await controller.createInvitation(user, {
        email: "t@t.com",
        phone: "123",
      });
      expect(service.createInvitation).toHaveBeenCalledWith(
        "u1",
        "t@t.com",
        "123",
      );
    });
  });

  describe("removeFriend", () => {
    it("should remove friend", async () => {
      const user = { id: "u1" };
      await controller.removeFriend(user, "u2");
      expect(service.removeFriend).toHaveBeenCalledWith("u1", "u2");
    });
  });
});
