import { Injectable, BadRequestException, Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { RedisService } from "../redis/redis.service";
import { ConfigService } from "@nestjs/config";
import { TransactionType, AdType } from "@prisma/client";

@Injectable()
export class AdsService {
  private readonly logger = new Logger(AdsService.name);
  private readonly adRewardPoints: number;
  private readonly cooldownMinutes: number;
  private readonly maxDailyAds: number;

  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
    private readonly configService: ConfigService,
  ) {
    this.adRewardPoints = Number.parseInt(
      this.configService.get("AD_REWARD_POINTS", "10"),
      10,
    );
    this.cooldownMinutes = Number.parseInt(
      this.configService.get("AD_COOLDOWN_MINUTES", "5"),
      10,
    );
    this.maxDailyAds = 10;
  }

  async checkCanWatchAd(userId: string) {
    const canWatch = await this.redis.checkAdCooldown(userId);
    let cooldownRemaining = 0;

    if (!canWatch) {
      cooldownRemaining = await this.redis.getAdCooldownRemaining(userId);
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const todayViews = await this.prisma.adView.count({
      where: {
        userId,
        adType: AdType.REWARDED,
        completedAt: { gte: today },
      },
    });

    return {
      canWatch: canWatch && todayViews < this.maxDailyAds,
      cooldownRemaining: canWatch ? 0 : cooldownRemaining,
      todayViews,
      maxDailyAds: this.maxDailyAds,
      remainingAds: Math.max(0, this.maxDailyAds - todayViews),
      pointsPerAd: this.adRewardPoints,
    };
  }

  async claimAdReward(userId: string, adType: AdType, adUnitId?: string) {
    if (adType === AdType.REWARDED) {
      const canWatch = await this.redis.checkAdCooldown(userId);
      if (!canWatch) {
        const remaining = await this.redis.getAdCooldownRemaining(userId);
        throw new BadRequestException(
          `Please wait ${remaining} seconds before watching another ad`,
        );
      }

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const todayViews = await this.prisma.adView.count({
        where: {
          userId,
          adType: AdType.REWARDED,
          completedAt: { gte: today },
        },
      });

      if (todayViews >= this.maxDailyAds) {
        throw new BadRequestException("Daily rewarded ad limit reached");
      }
    }

    const pointsEarned = adType === AdType.REWARDED ? this.adRewardPoints : 0;

    try {
      // Atomic Transaction: Log AdView, Record Points Transaction, Update Wallet Balance
      await this.prisma.$transaction(async (tx) => {
        const adView = await tx.adView.create({
          data: {
            userId,
            adType,
            adUnitId,
            pointsEarned,
          },
        });

        if (pointsEarned > 0) {
          await tx.transaction.create({
            data: {
              userId,
              type: TransactionType.AD_REWARD,
              points: pointsEarned,
              description: "📺 Reward for watching ad",
              metadata: { adViewId: adView.id },
            },
          });

          await tx.wallet.upsert({
            where: { userId },
            update: {
              balance: { increment: pointsEarned },
              lifetimePoints: { increment: pointsEarned },
              monthlyXp: { increment: pointsEarned },
            },
            create: {
              userId,
              balance: pointsEarned,
              lifetimePoints: pointsEarned,
              monthlyXp: pointsEarned,
            },
          });
        }
      });

      if (pointsEarned > 0) {
        await this.redis.setAdCooldown(userId, this.cooldownMinutes);
      }

      return {
        success: true,
        pointsEarned,
        cooldownMinutes: adType === AdType.REWARDED ? this.cooldownMinutes : 0,
      };
    } catch (error) {
      this.logger.error(
        `Failed to process ad reward for user ${userId}: ${error.message}`,
        error.stack,
      );
      throw error;
    }
  }

  async getAdHistory(userId: string, page: number = 1, limit: number = 20) {
    const skip = (page - 1) * limit;

    const [adViews, total] = await Promise.all([
      this.prisma.adView.findMany({
        where: { userId },
        orderBy: { completedAt: "desc" },
        take: limit,
        skip,
      }),
      this.prisma.adView.count({ where: { userId } }),
    ]);

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
