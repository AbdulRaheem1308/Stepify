import { Test, TestingModule } from "@nestjs/testing";
import { Logger } from "@nestjs/common";
import { NotificationsCronService } from "./notifications.cron.service";
import { PrismaService } from "../prisma/prisma.service";
import { NotificationsService } from "./notifications.service";

jest.spyOn(Logger.prototype, "log").mockImplementation(() => undefined);
jest.spyOn(Logger.prototype, "error").mockImplementation(() => undefined);

describe("NotificationsCronService", () => {
  let service: NotificationsCronService;

  const mockPrisma: any = {
    user: {
      findMany: jest.fn(),
    },
  };

  const mockNotificationsService = {
    sendPushToUser: jest.fn().mockResolvedValue(undefined),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationsCronService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: NotificationsService, useValue: mockNotificationsService },
      ],
    }).compile();

    service = module.get<NotificationsCronService>(NotificationsCronService);
    jest.clearAllMocks();
  });

  it("should be defined", () => {
    expect(service).toBeDefined();
  });

  describe("sendDailyReminders", () => {
    it("should skip users who have already reached their goal", async () => {
      mockPrisma.user.findMany.mockResolvedValueOnce([
        { id: "u1", dailyStepGoal: 5000, steps: [{ stepCount: 6000 }] },
      ]);

      await service.sendDailyReminders();

      expect(mockNotificationsService.sendPushToUser).not.toHaveBeenCalled();
    });

    it("should send general reminder to user who hasn't moved", async () => {
      mockPrisma.user.findMany.mockResolvedValueOnce([
        { id: "u1", dailyStepGoal: 10000, steps: [] },
      ]);

      await service.sendDailyReminders();

      expect(mockNotificationsService.sendPushToUser).toHaveBeenCalledWith(
        "u1",
        "Daily Goal Reminder",
        expect.stringContaining("daily walk"),
        { type: "reminder" },
      );
    });

    it("should send 'almost there' reminder when under 2000 steps remain", async () => {
      mockPrisma.user.findMany.mockResolvedValueOnce([
        { id: "u1", dailyStepGoal: 10000, steps: [{ stepCount: 8500 }] },
      ]);

      await service.sendDailyReminders();

      expect(mockNotificationsService.sendPushToUser).toHaveBeenCalledWith(
        "u1",
        "Daily Goal Reminder",
        expect.stringContaining("Almost there"),
        { type: "reminder" },
      );
    });

    it("should send generic motivation reminder for users with some steps but far from goal", async () => {
      mockPrisma.user.findMany.mockResolvedValueOnce([
        { id: "u1", dailyStepGoal: 10000, steps: [{ stepCount: 4000 }] },
      ]);

      await service.sendDailyReminders();

      expect(mockNotificationsService.sendPushToUser).toHaveBeenCalledWith(
        "u1",
        "Daily Goal Reminder",
        expect.stringContaining("6000 steps away"),
        { type: "reminder" },
      );
    });

    it("should use default goal of 10000 if user has none set", async () => {
      mockPrisma.user.findMany.mockResolvedValueOnce([
        { id: "u1", dailyStepGoal: null, steps: [] },
      ]);

      await service.sendDailyReminders();

      expect(mockNotificationsService.sendPushToUser).toHaveBeenCalledWith(
        "u1",
        "Daily Goal Reminder",
        expect.any(String),
        { type: "reminder" },
      );
    });

    it("should handle and log error if prisma throws", async () => {
      mockPrisma.user.findMany.mockRejectedValueOnce(new Error("DB Error"));

      await expect(service.sendDailyReminders()).resolves.toBeUndefined();
    });

    it("should process multiple users and send correct count", async () => {
      mockPrisma.user.findMany.mockResolvedValueOnce([
        { id: "u1", dailyStepGoal: 10000, steps: [{ stepCount: 2000 }] },
        { id: "u2", dailyStepGoal: 5000, steps: [{ stepCount: 5000 }] }, // goal reached
        { id: "u3", dailyStepGoal: 8000, steps: [] },
      ]);

      await service.sendDailyReminders();

      expect(mockNotificationsService.sendPushToUser).toHaveBeenCalledTimes(2);
      expect(mockNotificationsService.sendPushToUser).toHaveBeenCalledWith("u1", expect.any(String), expect.any(String), expect.any(Object));
      expect(mockNotificationsService.sendPushToUser).toHaveBeenCalledWith("u3", expect.any(String), expect.any(String), expect.any(Object));
    });
  });
});
