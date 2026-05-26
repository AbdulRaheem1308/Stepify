import { Processor, WorkerHost } from "@nestjs/bullmq";
import { Job } from "bullmq";
import { Injectable, Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { PostHogService } from "../analytics/posthog.service";
import { LeaderboardGateway } from "./gateways/leaderboard.gateway";

@Processor("steps-processing")
@Injectable()
export class StepsProcessor extends WorkerHost {
  private readonly logger = new Logger(StepsProcessor.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly postHog: PostHogService,
    private readonly leaderboardGateway: LeaderboardGateway,
  ) {
    super();
  }

  async process(job: Job<any, any, string>): Promise<any> {
    this.logger.log(
      `🔄 Processing background job ${job.id} of type ${job.name}`,
    );

    if (job.name === "process-sync") {
      const { userId, effectiveStepCount, effectiveSource } = job.data;

      // 1. Rewards processing has been moved to a 4-hour Cron job (RewardsCronService)
      // to reduce database load and eliminate race conditions.

      // 2. Update corporate leaderboard cache if the user is in a company
      try {
        const totalUserSteps = await this.prisma.step.aggregate({
          where: { userId },
          _sum: { stepCount: true },
        });
        const sumSteps = totalUserSteps._sum.stepCount || 0;

        const member = await this.prisma.companyMember.findUnique({
          where: { userId },
        });

        if (member) {
          await this.prisma.companyMember.update({
            where: { userId },
            data: { totalSteps: sumSteps },
          });
          this.logger.log(
            `📈 Updated company membership steps cache for user ${userId} to ${sumSteps}`,
          );

          // 3. Broadcast real-time leaderboard update to WebSocket clients
          const leaderboard = await this.prisma.companyMember.findMany({
            where: { companyId: member.companyId },
            orderBy: { totalSteps: "desc" },
            take: 20,
            include: {
              user: {
                select: {
                  name: true,
                  avatarUrl: true,
                },
              },
            },
          });
          this.leaderboardGateway.broadcastLeaderboardUpdate(
            member.companyId,
            leaderboard,
          );
        }
      } catch (err) {
        this.logger.error(
          `❌ Failed to update corporate leaderboard stats for user ${userId}: ${err.message}`,
        );
      }

      // 4. Asynchronously track PostHog analytics
      try {
        await this.postHog.trackStepSync(
          userId,
          effectiveStepCount,
          effectiveSource,
        );
        this.logger.log(`📊 Logged steps sync in Posthog for user ${userId}`);
      } catch (err) {
        this.logger.warn(
          `⚠️ PostHog analytics logging failed for user ${userId}: ${err.message}`,
        );
      }
    } else {
      this.logger.warn(`❓ Unknown background job type: ${job.name}`);
    }
  }
}
