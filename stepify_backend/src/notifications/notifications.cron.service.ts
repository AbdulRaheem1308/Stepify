import { Injectable, Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { NotificationsService } from "./notifications.service";
import { Cron } from "@nestjs/schedule";

@Injectable()
export class NotificationsCronService {
  private readonly logger = new Logger(NotificationsCronService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  /**
   * Daily Motivation Reminder
   * Runs every day at 18:00 (6 PM) server time.
   * Finds users who have daily reminders enabled and haven't reached their daily step goal.
   */
  @Cron("0 18 * * *") // 6:00 PM every day
  async sendDailyReminders() {
    this.logger.log("Starting daily motivation reminders cron job...");

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    try {
      // Find all users who have dailyReminders enabled (or setting doesn't exist yet so it defaults to true)
      const users = await this.prisma.user.findMany({
        where: {
          isActive: true,
          fcmToken: { not: null },
          OR: [
            { settings: null },
            { settings: { dailyReminders: true, pushNotifications: true } },
          ],
        },
        select: {
          id: true,
          dailyStepGoal: true,
          steps: {
            where: { date: today },
            select: { stepCount: true },
          },
        },
      });

      let remindersSent = 0;

      for (const user of users) {
        const currentSteps = user.steps[0]?.stepCount || 0;
        const goal = user.dailyStepGoal || 10000;

        if (currentSteps < goal) {
          const remaining = goal - currentSteps;

          // Only send if they have a reasonable amount left, to not spam people who haven't moved at all if they aren't using the app today
          // Actually, let's just send it to everyone who hasn't hit it to encourage them
          let message = `You're only ${remaining} steps away from your daily goal! Let's get stepping! 🚶‍♂️`;

          if (currentSteps === 0) {
            message = `Don't forget your daily walk! Even a short stroll makes a big difference. 🏃‍♀️`;
          } else if (remaining < 2000) {
            message = `Almost there! Just ${remaining} more steps to crush your goal! 🔥`;
          }

          // Use sendPushToUser (which honors settings and handles invalid tokens)
          await this.notificationsService.sendPushToUser(
            user.id,
            "Daily Goal Reminder",
            message,
            { type: "reminder" },
          );

          remindersSent++;
        }
      }

      this.logger.log(
        `Daily motivation reminders completed. Sent to ${remindersSent} users.`,
      );
    } catch (error) {
      this.logger.error("Failed to run daily reminders cron job", error);
    }
  }
}
