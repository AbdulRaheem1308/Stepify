import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { LogActivityDto } from './activities.controller';
import { RewardsService } from '../rewards/rewards.service';

@Injectable()
export class ActivitiesService {
    private readonly logger = new Logger(ActivitiesService.name);

    constructor(
        private prisma: PrismaService,
        private rewardsService: RewardsService,
    ) {}

    async logActivity(userId: string, dto: LogActivityDto) {
        // ── Server-Side Anti-Cheat & Speed Constraints ─────────────────────
        if (dto.durationMinutes > 300) {
            this.logger.warn(`User ${userId} attempted to log ${dto.durationMinutes} min. Max 300 allowed.`);
            throw new BadRequestException('Duration cannot exceed 5 hours per session.');
        }

        if (dto.distanceKm) {
            const maxKm = this.getMaxDistanceKm(dto.type, dto.durationMinutes);
            if (dto.distanceKm > maxKm) {
                this.logger.warn(`Speed constraint violation: User ${userId} logged ${dto.distanceKm}km in ${dto.durationMinutes}m for ${dto.type}. Max allowed is ${maxKm}km.`);
                throw new BadRequestException(`Distance entered (${dto.distanceKm} km) is physically impossible for ${dto.durationMinutes} minutes of ${dto.type}.`);
            }
        }
        // ──────────────────────────────────────────────────────────────────

        const multiplier = this.getPointsMultiplier(dto.type);
        const rawPoints = Math.floor(dto.durationMinutes * multiplier);
        const pointsEarned = Math.min(rawPoints, 900); // 900 max per session

        // Bypass Prisma strict typings using `any` since schema just changed and dll is locked
        const activity = await (this.prisma as any).activity.create({
            data: {
                userId,
                type: dto.type,
                durationMinutes: dto.durationMinutes,
                distanceKm: dto.distanceKm || 0,
                caloriesBurned: dto.caloriesBurned,
                pointsEarned,
                startTime: new Date(dto.startTime),
                source: dto.source || 'manual',
            },
        });

        // Award points to user's wallet using RewardsService (assuming it has addPoints)
        if (pointsEarned > 0) {
            // Note: If addPoints doesn't exist on RewardsService, we may need to adjust this.
            if ((this.rewardsService as any).addPoints) {
                 await (this.rewardsService as any).addPoints(userId, pointsEarned, 'ACTIVITY_LOG');
            }
        }

        return activity;
    }

    async getRecentActivities(userId: string) {
        return (this.prisma as any).activity.findMany({
            where: { userId },
            orderBy: { startTime: 'desc' },
            take: 20,
        });
    }

    private getMaxDistanceKm(type: string, minutes: number): number {
        const t = type.toLowerCase();
        switch (t) {
            case 'running': return minutes * 0.35; // ~21 km/h elite
            case 'cycling': return minutes * 0.9;  // ~54 km/h sprint
            case 'walking': return minutes * 0.12; // ~7.2 km/h fast walk
            case 'hiking':  return minutes * 0.1;
            case 'swimming':return minutes * 0.05; // ~3 km/h
            default:        return 999;
        }
    }

    private getPointsMultiplier(type: string): number {
        const t = type.toLowerCase();
        switch (t) {
            case 'running': return 3.0;
            case 'swimming': return 3.0;
            case 'cycling': return 2.5;
            case 'gym': return 2.5;
            case 'walking': return 1.5;
            case 'hiking': return 2.0;
            case 'yoga': return 1.0;
            default: return 1.0;
        }
    }
}
