import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import { ConfigService } from '@nestjs/config';
import { RewardsService } from '../rewards/rewards.service';
import { TransactionType, AdType } from '@prisma/client';

@Injectable()
export class AdsService {
    private readonly adRewardPoints: number;
    private readonly cooldownMinutes: number;

    constructor(
        private prisma: PrismaService,
        private redis: RedisService,
        private configService: ConfigService,
        private rewardsService: RewardsService,
    ) {
        this.adRewardPoints = parseInt(this.configService.get('AD_REWARD_POINTS', '10'));
        this.cooldownMinutes = parseInt(this.configService.get('AD_COOLDOWN_MINUTES', '5'));
    }

    /**
     * Check if user can watch a rewarded ad
     */
    async checkCanWatchAd(userId: string) {
        const canWatch = await this.redis.checkAdCooldown(userId);
        let cooldownRemaining = 0;

        if (!canWatch) {
            cooldownRemaining = await this.redis.getAdCooldownRemaining(userId);
        }

        // Get today's ad watch count
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const todayViews = await this.prisma.adView.count({
            where: {
                userId,
                adType: AdType.REWARDED,
                completedAt: { gte: today },
            },
        });

        const maxDailyAds = 10; // Limit rewarded ads per day

        return {
            canWatch: canWatch && todayViews < maxDailyAds,
            cooldownRemaining: canWatch ? 0 : cooldownRemaining,
            todayViews,
            maxDailyAds,
            remainingAds: Math.max(0, maxDailyAds - todayViews),
            pointsPerAd: this.adRewardPoints,
        };
    }

    /**
     * Claim reward for watching ad
     */
    async claimAdReward(userId: string, adType: AdType, adUnitId?: string) {
        // Verify cooldown for rewarded ads
        if (adType === AdType.REWARDED) {
            const canWatch = await this.redis.checkAdCooldown(userId);
            if (!canWatch) {
                const remaining = await this.redis.getAdCooldownRemaining(userId);
                throw new BadRequestException(
                    `Please wait ${remaining} seconds before watching another ad`
                );
            }

            // Check daily limit
            const today = new Date();
            today.setHours(0, 0, 0, 0);

            const todayViews = await this.prisma.adView.count({
                where: {
                    userId,
                    adType: AdType.REWARDED,
                    completedAt: { gte: today },
                },
            });

            if (todayViews >= 10) {
                throw new BadRequestException('Daily rewarded ad limit reached');
            }
        }

        const pointsEarned = adType === AdType.REWARDED ? this.adRewardPoints : 0;

        // Record ad view
        const adView = await this.prisma.adView.create({
            data: {
                userId,
                adType,
                adUnitId,
                pointsEarned,
            },
        });

        // Award points for rewarded ads
        if (pointsEarned > 0) {
            await this.rewardsService.addPoints(
                userId,
                pointsEarned,
                TransactionType.AD_REWARD,
                '📺 Reward for watching ad',
                { adViewId: adView.id }
            );

            // Set cooldown
            await this.redis.setAdCooldown(userId, this.cooldownMinutes);
        }

        return {
            success: true,
            pointsEarned,
            cooldownMinutes: adType === AdType.REWARDED ? this.cooldownMinutes : 0,
        };
    }

    /**
     * Get ad history for user
     */
    async getAdHistory(userId: string, page: number = 1, limit: number = 20) {
        const skip = (page - 1) * limit;

        const [adViews, total] = await Promise.all([
            this.prisma.adView.findMany({
                where: { userId },
                orderBy: { completedAt: 'desc' },
                take: limit,
                skip,
            }),
            this.prisma.adView.count({ where: { userId } }),
        ]);

        // Calculate totals
        const totals = await this.prisma.adView.aggregate({
            where: { userId },
            _sum: { pointsEarned: true },
            _count: true,
        });

        return {
            data: adViews,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
            summary: {
                totalAdsWatched: totals._count,
                totalPointsEarned: totals._sum.pointsEarned || 0,
            },
        };
    }
}
