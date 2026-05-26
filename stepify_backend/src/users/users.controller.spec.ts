import { Test, TestingModule } from "@nestjs/testing";
import { UsersController } from "./users.controller";
import { UsersService } from "./users.service";

describe("UsersController", () => {
  let controller: UsersController;
  let service: UsersService;

  const mockUsersService = {
    getAvatars: jest.fn(),
    findById: jest.fn(),
    update: jest.fn(),
    getUserStats: jest.fn(),
    getReferralLeaderboard: jest.fn(),
    getReferralStats: jest.fn(),
    applyReferralCode: jest.fn(),
    initializeAchievementsForAllUsers: jest.fn(),
    getSettings: jest.fn(),
    updateSettings: jest.fn(),
    exportData: jest.fn(),
    deleteAccount: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [{ provide: UsersService, useValue: mockUsersService }],
    }).compile();

    controller = module.get<UsersController>(UsersController);
    service = module.get<UsersService>(UsersService);
    jest.clearAllMocks();
  });

  it("should be defined", () => {
    expect(controller).toBeDefined();
  });

  it("should get avatars", async () => {
    mockUsersService.getAvatars.mockResolvedValue(["avatar1.png"]);
    const res = await controller.getAvatars();
    expect(res).toEqual(["avatar1.png"]);
  });

  it("should get profile", async () => {
    mockUsersService.findById.mockResolvedValue({ id: "u1" });
    const res = await controller.getProfile({ id: "u1" });
    expect(res).toEqual({ id: "u1" });
  });

  it("should update profile", async () => {
    mockUsersService.update.mockResolvedValue({ id: "u1", name: "new" });
    const res = await controller.updateProfile({ id: "u1" }, { name: "new" });
    expect(res).toEqual({ id: "u1", name: "new" });
  });

  it("should get stats", async () => {
    mockUsersService.getUserStats.mockResolvedValue({ steps: 100 });
    const res = await controller.getStats({ id: "u1" });
    expect(res).toEqual({ steps: 100 });
  });

  it("should get referral leaderboard with default limit", async () => {
    mockUsersService.getReferralLeaderboard.mockResolvedValue([]);
    await controller.getReferralLeaderboard();
    expect(service.getReferralLeaderboard).toHaveBeenCalledWith(20);
  });

  it("should get referral leaderboard with specific limit", async () => {
    mockUsersService.getReferralLeaderboard.mockResolvedValue([]);
    await controller.getReferralLeaderboard("10");
    expect(service.getReferralLeaderboard).toHaveBeenCalledWith(10);
  });

  it("should get referral leaderboard with invalid limit graceful fallback", async () => {
    mockUsersService.getReferralLeaderboard.mockResolvedValue([]);
    await controller.getReferralLeaderboard("abc");
    expect(service.getReferralLeaderboard).toHaveBeenCalledWith(20);
  });

  it("should get my referral stats", async () => {
    mockUsersService.getReferralStats.mockResolvedValue({ code: "ABC" });
    const res = await controller.getMyReferralStats({ id: "u1" });
    expect(res).toEqual({ code: "ABC" });
  });

  it("should apply referral code", async () => {
    mockUsersService.applyReferralCode.mockResolvedValue({ success: true });
    const res = await controller.applyReferralCode(
      { id: "u1" },
      { code: "REF123" },
    );
    expect(res).toEqual({ success: true });
  });

  it("should init achievements", async () => {
    mockUsersService.initializeAchievementsForAllUsers.mockResolvedValue({
      success: true,
    });
    const res = await controller.initializeAllUsersAchievements();
    expect(res).toEqual({ success: true });
  });

  it("should get settings", async () => {
    mockUsersService.getSettings.mockResolvedValue({ notifications: true });
    const res = await controller.getSettings({ id: "u1" });
    expect(res).toEqual({ notifications: true });
  });

  it("should update settings", async () => {
    mockUsersService.updateSettings.mockResolvedValue({ notifications: false });
    const res = await controller.updateSettings({ id: "u1" }, {} as any);
    expect(res).toEqual({ notifications: false });
  });

  it("should export data", async () => {
    mockUsersService.exportData.mockResolvedValue({ data: "secret" });
    const res = await controller.exportData({ id: "u1" });
    expect(res).toEqual({ data: "secret" });
  });

  it("should delete account", async () => {
    mockUsersService.deleteAccount.mockResolvedValue({ success: true });
    const res = await controller.deleteAccount({ id: "u1" });
    expect(res).toEqual({ success: true });
  });
});
