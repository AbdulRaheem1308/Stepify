import {
  Injectable,
  BadRequestException,
  Logger,
  ConflictException,
} from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { LogActivityDto } from "./dto/log-activity.dto";
import { GetActivitiesDto } from "./dto/get-activities.dto";
import { TransactionType } from "@prisma/client";
import {
  ACTIVITIES_CONSTANTS,
  ACTIVITY_SPEED_LIMITS,
  ACTIVITY_POINT_MULTIPLIERS,
} from "./constants/activities.constants";

@Injectable()
export class ActivitiesService {
  private readonly logger = new Logger(ActivitiesService.name);

  constructor(private prisma: PrismaService) {}

  async logActivity(userId: string, dto: LogActivityDto) {
    // ── Server-Side Anti-Cheat & Speed Constraints ─────────────────────
    if (dto.durationMinutes > ACTIVITIES_CONSTANTS.MAX_DURATION_MINUTES) {
      this.logger.warn(
        `User ${userId} attempted to log ${dto.durationMinutes} min. Max ${ACTIVITIES_CONSTANTS.MAX_DURATION_MINUTES} allowed.`,
      );
      throw new BadRequestException(
        `Duration cannot exceed ${ACTIVITIES_CONSTANTS.MAX_DURATION_MINUTES / 60} hours per session.`,
      );
    }

    if (dto.distanceKm) {
      const maxKm = this.getMaxDistanceKm(dto.type, dto.durationMinutes);
      if (dto.distanceKm > maxKm) {
        this.logger.warn(
          `Speed constraint violation: User ${userId} logged ${dto.distanceKm}km in ${dto.durationMinutes}m for ${dto.type}. Max allowed is ${maxKm}km.`,
        );
        throw new BadRequestException(
          `Distance entered (${dto.distanceKm} km) is physically impossible for ${dto.durationMinutes} minutes of ${dto.type}.`,
        );
      }
    }
    // ──────────────────────────────────────────────────────────────────

    // Idempotency / Double-submission check
    const existingActivity = await this.prisma.activity.findFirst({
      where: {
        userId,
        type: dto.type,
        startTime: new Date(dto.startTime),
      },
    });

    if (existingActivity) {
      this.logger.warn(
        `Idempotency caught duplicate activity log for user ${userId} at ${dto.startTime}`,
      );
      throw new ConflictException(
        "An activity of this type is already logged at the specified start time.",
      );
    }

    const multiplier = this.getPointsMultiplier(dto.type);
    const rawPoints = Math.floor(dto.durationMinutes * multiplier);
    const pointsEarned = Math.min(
      rawPoints,
      ACTIVITIES_CONSTANTS.MAX_POINTS_PER_SESSION,
    );

    // Atomic Transaction to guarantee data integrity between Activity and Wallet
    try {
      const activity = await this.prisma.$transaction(async (tx) => {
        // 1. Create the activity record
        const newActivity = await tx.activity.create({
          data: {
            userId,
            type: dto.type,
            durationMinutes: dto.durationMinutes,
            distanceKm: dto.distanceKm || 0,
            caloriesBurned: dto.caloriesBurned,
            pointsEarned,
            startTime: new Date(dto.startTime),
            source: dto.source || "manual",
          },
        });

        // 2. Award points atomically
        if (pointsEarned > 0) {
          await tx.transaction.create({
            data: {
              userId,
              type: TransactionType.STEPS,
              points: pointsEarned,
              description: `Earned ${pointsEarned} points for ${dto.durationMinutes}m of ${dto.type}`,
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

        return newActivity;
      });

      return activity;
    } catch (error) {
      this.logger.error(
        `Failed to log activity for user ${userId}: ${error.message}`,
        error.stack,
      );
      throw error; // Rethrow to let global filters handle it
    }
  }

  async getRecentActivities(userId: string, query: GetActivitiesDto) {
    const {
      page = ACTIVITIES_CONSTANTS.DEFAULT_PAGE,
      limit = ACTIVITIES_CONSTANTS.DEFAULT_LIMIT,
    } = query;
    const skip = (page - 1) * limit;

    const [activities, total] = await Promise.all([
      this.prisma.activity.findMany({
        where: { userId },
        orderBy: { startTime: "desc" },
        take: limit,
        skip,
      }),
      this.prisma.activity.count({ where: { userId } }),
    ]);

    return {
      data: activities,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  private getMaxDistanceKm(type: string, minutes: number): number {
    const limit =
      ACTIVITY_SPEED_LIMITS[type as keyof typeof ACTIVITY_SPEED_LIMITS];
    return limit !== undefined ? minutes * limit : 999;
  }

  private getPointsMultiplier(type: string): number {
    const multiplier =
      ACTIVITY_POINT_MULTIPLIERS[
        type as keyof typeof ACTIVITY_POINT_MULTIPLIERS
      ];
    return multiplier !== undefined ? multiplier : 1.0;
  }
}
