import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ConfigService } from '@nestjs/config';
import { SyncStepsDto } from './dto/steps.dto';
import { RewardsService } from '../rewards/rewards.service';

@Injectable()
export class StepsService {
    private readonly caloriesPerStep: number;
    private readonly kmPerStep: number;

    constructor(
        private prisma: PrismaService,
        private configService: ConfigService,
        private rewardsService: RewardsService,
    ) {
        this.caloriesPerStep = parseFloat(this.configService.get('CALORIES_PER_STEP', '0.04'));
        this.kmPerStep = parseFloat(this.configService.get('KM_PER_STEP', '0.000762'));
    }

    /**
     * Sync step data from device
     * Handles upsert for the given date
     */
    async syncSteps(userId: string, dto: SyncStepsDto) {
        const date = new Date(dto.date);
        date.setHours(0, 0, 0, 0);

        // Calculate derived values
        const caloriesBurned = Math.round(dto.stepCount * this.caloriesPerStep);
        const distanceKm = parseFloat((dto.stepCount * this.kmPerStep).toFixed(2));

        // Upsert step record
        const step = await this.prisma.step.upsert({
            where: {
                userId_date: {
                    userId,
                    date,
                },
            },
            update: {
                stepCount: dto.stepCount,
                caloriesBurned,
                distanceKm,
                activeMinutes: dto.activeMinutes || 0,
                source: dto.source || 'manual',
                synced: true,
            },
            create: {
                userId,
                date,
                stepCount: dto.stepCount,
                caloriesBurned,
                distanceKm,
                activeMinutes: dto.activeMinutes || 0,
                source: dto.source || 'manual',
                synced: true,
            },
        });

        // Update streak and rewards
        await this.rewardsService.processStepRewards(userId, dto.stepCount, date);

        return step;
    }

    /**
     * Ensure user has demo data if empty
     */
    private async ensureUserData(userId: string) {
        try {
            const count = await this.prisma.step.count({ where: { userId } });
            if (count > 0) return;

            // Seed 30 days
            const today = new Date();
            const stepsData = [];

            for (let i = 0; i < 30; i++) {
                const date = new Date(today);
                date.setDate(date.getDate() - i);
                date.setHours(0, 0, 0, 0);

                const steps = Math.floor(Math.random() * 12000) + 2000;
                const calories = Math.floor(steps * this.caloriesPerStep);
                const distance = parseFloat((steps * this.kmPerStep).toFixed(2));

                stepsData.push({
                    userId,
                    date,
                    stepCount: steps,
                    caloriesBurned: calories,
                    distanceKm: distance,
                    activeMinutes: Math.floor(steps / 110),
                    synced: true,
                    source: 'demo_gen',
                });
            }

            // Use createMany (Postgres supports it)
            await this.prisma.step.createMany({ data: stepsData });

            // Also ensure streak
            await this.prisma.streak.upsert({
                where: { userId },
                create: { userId, currentStreak: 5, longestStreak: 12 },
                update: {},
            });

            // Ensure wallet
            await this.prisma.wallet.upsert({
                where: { userId },
                create: { userId, balance: 500, lifetimePoints: 1200 },
                update: {},
            });
        } catch (error) {
            // Ignore constraint errors from other simultaneous parallel requests that created the data first
            console.warn('⚠️ Concurrency warning in ensureUserData:', error.message);
        }
    }

    /**
     * Get today's steps
     */
    async getTodaySteps(userId: string) {
        await this.ensureUserData(userId);

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const step = await this.prisma.step.findUnique({
            where: {
                userId_date: {
                    userId,
                    date: today,
                },
            },
        });

        // Get user's goal
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            select: { dailyStepGoal: true },
        });

        const stepCount = step?.stepCount || 0;
        const goal = user?.dailyStepGoal || 10000;

        const year = today.getFullYear();
        const month = String(today.getMonth() + 1).padStart(2, '0');
        const day = String(today.getDate()).padStart(2, '0');

        return {
            date: `${year}-${month}-${day}`,
            stepCount,
            caloriesBurned: step?.caloriesBurned || 0,
            distanceKm: step?.distanceKm || 0,
            activeMinutes: step?.activeMinutes || 0,
            goal,
            progress: Math.min(Math.round((stepCount / goal) * 100), 100),
            goalReached: stepCount >= goal,
        };
    }

    /**
     * Get step history with pagination
     */
    async getHistory(userId: string, page: number = 1, limit: number = 30) {
        const skip = (page - 1) * limit;

        const [steps, total] = await Promise.all([
            this.prisma.step.findMany({
                where: { userId },
                orderBy: { date: 'desc' },
                take: limit,
                skip,
            }),
            this.prisma.step.count({ where: { userId } }),
        ]);

        return {
            data: steps,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }

    /**
     * Get weekly summary
     */
    async getWeeklySummary(userId: string) {
        await this.ensureUserData(userId);

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Get start of week (Monday)
        const startOfWeek = new Date(today);
        const dayOfWeek = today.getDay();
        const diff = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
        startOfWeek.setDate(today.getDate() - diff);

        const steps = await this.prisma.step.findMany({
            where: {
                userId,
                date: {
                    gte: startOfWeek,
                    lte: today,
                },
            },
            orderBy: { date: 'asc' },
        });

        // Calculate totals
        const totalSteps = steps.reduce((sum, s) => sum + s.stepCount, 0);
        const totalCalories = steps.reduce((sum, s) => sum + s.caloriesBurned, 0);
        const totalDistance = steps.reduce((sum, s) => sum + Number(s.distanceKm), 0);
        const avgSteps = steps.length > 0 ? Math.round(totalSteps / steps.length) : 0;

        // Create daily breakdown
        const dailyData = [];
        for (let i = 0; i < 7; i++) {
            const date = new Date(startOfWeek);
            date.setDate(startOfWeek.getDate() + i);

            // Use local date string to avoid UTC shifts
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            const dateStr = `${year}-${month}-${day}`;

            const dayData = steps.find(s => {
                const sYear = s.date.getFullYear();
                const sMonth = String(s.date.getMonth() + 1).padStart(2, '0');
                const sDay = String(s.date.getDate()).padStart(2, '0');
                return `${sYear}-${sMonth}-${sDay}` === dateStr;
            });

            dailyData.push({
                date: dateStr,
                dayName: date.toLocaleDateString('en-US', { weekday: 'short' }),
                stepCount: dayData?.stepCount || 0,
                caloriesBurned: dayData?.caloriesBurned || 0,
            });
        }

        return {
            startDate: startOfWeek.toISOString().split('T')[0],
            endDate: today.toISOString().split('T')[0],
            totalSteps,
            totalCalories,
            totalDistanceKm: parseFloat(totalDistance.toFixed(2)),
            averageSteps: avgSteps,
            activeDays: steps.length,
            dailyBreakdown: dailyData,
        };
    }

    /**
     * Get monthly summary
     */
    async getMonthlySummary(userId: string, year?: number, month?: number) {
        const now = new Date();
        const targetYear = year || now.getFullYear();
        const targetMonth = month || now.getMonth() + 1;

        const startOfMonth = new Date(targetYear, targetMonth - 1, 1);
        const endOfMonth = new Date(targetYear, targetMonth, 0);

        const steps = await this.prisma.step.findMany({
            where: {
                userId,
                date: {
                    gte: startOfMonth,
                    lte: endOfMonth,
                },
            },
            orderBy: { date: 'asc' },
        });

        const totalSteps = steps.reduce((sum, s) => sum + s.stepCount, 0);
        const totalCalories = steps.reduce((sum, s) => sum + s.caloriesBurned, 0);
        const totalDistance = steps.reduce((sum, s) => sum + Number(s.distanceKm), 0);
        const avgSteps = steps.length > 0 ? Math.round(totalSteps / steps.length) : 0;

        // Get best day
        const bestDay = steps.reduce((max, s) =>
            s.stepCount > (max?.stepCount || 0) ? s : max, steps[0] || null);

        // Weekly breakdown
        const weeks = [];
        let currentWeek = { startDate: '', steps: 0, calories: 0 };
        let weekStart = new Date(startOfMonth);

        for (const step of steps) {
            const stepDate = new Date(step.date);
            const weekNum = Math.floor((stepDate.getDate() - 1) / 7);

            if (!weeks[weekNum]) {
                weeks[weekNum] = {
                    weekNumber: weekNum + 1,
                    steps: 0,
                    calories: 0,
                };
            }
            weeks[weekNum].steps += step.stepCount;
            weeks[weekNum].calories += step.caloriesBurned;
        }

        return {
            year: targetYear,
            month: targetMonth,
            monthName: startOfMonth.toLocaleDateString('en-US', { month: 'long' }),
            totalSteps,
            totalCalories,
            totalDistanceKm: parseFloat(totalDistance.toFixed(2)),
            averageSteps: avgSteps,
            activeDays: steps.length,
            totalDaysInMonth: endOfMonth.getDate(),
            bestDay: bestDay ? {
                date: (() => {
                    const d = bestDay.date;
                    const year = d.getFullYear();
                    const month = String(d.getMonth() + 1).padStart(2, '0');
                    const day = String(d.getDate()).padStart(2, '0');
                    return `${year}-${month}-${day}`;
                })(),
                stepCount: bestDay.stepCount,
            } : null,
            weeklyBreakdown: weeks.filter(Boolean),
        };
    }
}
