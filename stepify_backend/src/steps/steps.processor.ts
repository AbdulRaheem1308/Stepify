import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RewardsService } from '../rewards/rewards.service';
import { PostHogService } from '../analytics/posthog.service';
import { LeaderboardGateway } from './gateways/leaderboard.gateway';

@Processor('steps-processing')
@Injectable()
export class StepsProcessor extends WorkerHost {
    private readonly logger = new Logger(StepsProcessor.name);

    constructor(
        private prisma: PrismaService,
        private rewardsService: RewardsService,
        private postHog: PostHogService,
        private leaderboardGateway: LeaderboardGateway,
    ) {
        super();
    }

    async process(job: Job<any, any, string>): Promise<any> {
        this.logger.log(`🔄 Processing background job ${job.id} of type ${job.name}`);

        switch (job.name) {
            case 'process-sync': {
                const { userId, effectiveStepCount, date, effectiveSource } = job.data;
                const parsedDate = new Date(date);

                // 1. Process achievements, streaks, and wallet rewards asynchronously
                try {
                    await this.rewardsService.processStepRewards(userId, effectiveStepCount, parsedDate);
                    this.logger.log(`✅ Successfully processed step rewards for user ${userId}`);
                } catch (err) {
                    this.logger.error(`❌ Failed to process step rewards for user ${userId}: ${err.message}`);
                }

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
                        this.logger.log(`📈 Updated company membership steps cache for user ${userId} to ${sumSteps}`);

                        // 3. Broadcast real-time leaderboard update to WebSocket clients
                        const leaderboard = await this.prisma.companyMember.findMany({
                            where: { companyId: member.companyId },
                            orderBy: { totalSteps: 'desc' },
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
                        this.leaderboardGateway.broadcastLeaderboardUpdate(member.companyId, leaderboard);
                    }
                } catch (err) {
                    this.logger.error(`❌ Failed to update corporate leaderboard stats for user ${userId}: ${err.message}`);
                }

                // 4. Asynchronously track PostHog analytics
                try {
                    await this.postHog.trackStepSync(userId, effectiveStepCount, effectiveSource);
                    this.logger.log(`📊 Logged steps sync in Posthog for user ${userId}`);
                } catch (err) {
                    this.logger.warn(`⚠️ PostHog analytics logging failed for user ${userId}: ${err.message}`);
                }
                break;
            }
            default:
                this.logger.warn(`❓ Unknown background job type: ${job.name}`);
        }
    }
}
