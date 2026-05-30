import { Injectable, Logger } from "@nestjs/common";
import { Cron } from "@nestjs/schedule";
import { PrismaService } from "../prisma/prisma.service";
import { RewardsService } from "./rewards.service";

@Injectable()
export class RewardsCronService {
  private readonly logger = new Logger(RewardsCronService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly rewardsService: RewardsService,
  ) {}

  /**
   * Run every 4 hours.
   * Processes all steps and assigns coins, quests, and achievements.
   */
  @Cron("0 */4 * * *")
  async handleRewardsSync() {
    this.logger.log("Starting 4-hour rewards sync job...");

    try {
      const now = new Date();
      // Wellnex date format is at midnight UTC in the database
      const year = now.getUTCFullYear();
      const month = String(now.getUTCMonth() + 1).padStart(2, "0");
      const day = String(now.getUTCDate()).padStart(2, "0");
      const dateStr = `${year}-${month}-${day}T00:00:00.000Z`;

      const todaySteps = await this.prisma.step.findMany({
        where: {
          date: new Date(dateStr),
        },
      });

      this.logger.log(
        `Found ${todaySteps.length} users with steps today. Processing rewards...`,
      );

      for (const stepData of todaySteps) {
        try {
          // The robust in-memory filtering inside processStepRewards ensures
          // no double counting occurs even if this job runs multiple times today.
          await this.rewardsService.processStepRewards(
            stepData.userId,
            stepData.stepCount,
            now,
          );
        } catch (err) {
          this.logger.error(
            `Failed to process rewards for user ${stepData.userId}`,
            err.stack,
          );
        }
      }

      this.logger.log("4-hour rewards sync job completed.");
    } catch (error) {
      this.logger.error(
        "Failed to execute 4-hour rewards sync job",
        error.stack,
      );
    }
  }
}
