import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class QuestsService implements OnModuleInit {
    constructor(private prisma: PrismaService) { }

    // Seed data on init
    async onModuleInit() {
        const count = await this.prisma.quest.count();
        if (count === 0) {
            console.log('🌱 Seeding Quests...');
            await this.prisma.quest.create({
                data: {
                    title: "The Beginner's Path",
                    description: "Start your journey with a consistent walking routine.",
                    imageUrl: "https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?auto=format&fit=crop&w=800&q=80",
                    difficulty: "EASY",
                    rewardXp: 500,
                    rewardCoins: 150,
                    stages: {
                        create: [
                            { order: 1, title: 'Day 1: Warm Up', description: 'Walk 4,000 steps', targetSteps: 4000 },
                            { order: 2, title: 'Day 2: Picking Up Pace', description: 'Walk 6,000 steps', targetSteps: 6000 },
                            { order: 3, title: 'Day 3: The Finish Line', description: 'Walk 8,000 steps', targetSteps: 8000 },
                        ]
                    }
                }
            });

            await this.prisma.quest.create({
                data: {
                    title: "Mountain Hiker",
                    description: "Conquer the virtual peaks with serious steps.",
                    imageUrl: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80",
                    difficulty: "MEDIUM",
                    rewardXp: 1500,
                    rewardCoins: 400,
                    stages: {
                        create: [
                            { order: 1, title: 'Base Camp', description: 'Walk 10,000 steps', targetSteps: 10000 },
                            { order: 2, title: 'The Ascent', description: 'Walk 15,000 steps', targetSteps: 15000 },
                            { order: 3, title: 'The Summit', description: 'Walk 20,000 steps', targetSteps: 20000 },
                        ]
                    }
                }
            });
        }
    }

    async findAll() {
        return this.prisma.quest.findMany({
            include: { stages: { orderBy: { order: 'asc' } } }
        });
    }

    async joinQuest(userId: string, questId: string) {
        const existing = await this.prisma.userQuest.findUnique({
            where: {
                userId_questId: {
                    userId,
                    questId,
                },
            },
        });

        if (existing) {
            return existing;
        }

        return this.prisma.userQuest.create({
            data: {
                userId,
                questId,
                status: 'IN_PROGRESS',
                currentStageIndex: 0
            }
        });
    }

    async getUserQuests(userId: string) {
        return this.prisma.userQuest.findMany({
            where: { userId },
            include: { quest: { include: { stages: true } } }
        });
    }
}
