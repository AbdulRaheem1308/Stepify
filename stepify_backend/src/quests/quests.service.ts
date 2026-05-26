import { Injectable, OnModuleInit, Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class QuestsService implements OnModuleInit {
  constructor(private readonly prisma: PrismaService) {}

  // Seed data on init
  async onModuleInit() {
    const count = await this.prisma.quest.count();
    if (count === 0) {
      Logger.log("🌱 Seeding Quests...");
      await this.prisma.quest.create({
        data: {
          title: "The Beginner's Path",
          description: "Start your journey with a consistent walking routine.",
          imageUrl:
            "https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?auto=format&fit=crop&w=800&q=80",
          difficulty: "EASY",
          rewardXp: 500,
          rewardCoins: 150,
          stages: {
            create: [
              {
                order: 1,
                title: "Day 1: Warm Up",
                description: "Walk 4,000 steps",
                targetSteps: 4000,
              },
              {
                order: 2,
                title: "Day 2: Picking Up Pace",
                description: "Walk 6,000 steps",
                targetSteps: 6000,
              },
              {
                order: 3,
                title: "Day 3: The Finish Line",
                description: "Walk 8,000 steps",
                targetSteps: 8000,
              },
            ],
          },
        },
      });

      await this.prisma.quest.create({
        data: {
          title: "Mountain Hiker",
          description: "Conquer the virtual peaks with serious steps.",
          imageUrl:
            "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80",
          difficulty: "MEDIUM",
          rewardXp: 1500,
          rewardCoins: 400,
          stages: {
            create: [
              {
                order: 1,
                title: "Base Camp",
                description: "Walk 10,000 steps",
                targetSteps: 10000,
              },
              {
                order: 2,
                title: "The Ascent",
                description: "Walk 15,000 steps",
                targetSteps: 15000,
              },
              {
                order: 3,
                title: "The Summit",
                description: "Walk 20,000 steps",
                targetSteps: 20000,
              },
            ],
          },
        },
      });
    }
  }

  async findAll() {
    return this.prisma.quest.findMany({
      include: { stages: { orderBy: { order: "asc" } } },
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
        status: "IN_PROGRESS",
        currentStageIndex: 0,
      },
    });
  }

  async getUserQuests(userId: string) {
    return this.prisma.userQuest.findMany({
      where: { userId },
      include: { quest: { include: { stages: true } } },
    });
  }

  async processQuestProgress(userId: string, stepCount: number) {
    const activeQuests = await this.prisma.userQuest.findMany({
      where: { userId, status: "IN_PROGRESS" },
      include: {
        quest: {
          include: {
            stages: { orderBy: { order: "asc" } },
          },
        },
      },
    });

    for (const userQuest of activeQuests) {
      const { quest, currentStageIndex } = userQuest;
      const stages = quest.stages;
      if (!stages || stages.length === 0) continue;

      const currentStage = stages[currentStageIndex];
      if (!currentStage) continue;

      // Check if steps satisfy the target
      if (stepCount >= currentStage.targetSteps) {
        const nextStageIndex = currentStageIndex + 1;

        if (nextStageIndex >= stages.length) {
          // Completed the entire quest! Wrap in atomic transaction
          await this.prisma.$transaction(async (tx) => {
            const updateResult = await tx.userQuest.updateMany({
              where: { 
                id: userQuest.id,
                currentStageIndex: currentStageIndex,
                status: "IN_PROGRESS"
              },
              data: {
                status: "COMPLETED",
                currentStageIndex: nextStageIndex,
                completedAt: new Date(),
              },
            });

            // Only award points if this transaction actually advanced the quest
            if (updateResult.count > 0) {
              // Award points & XP
              await tx.wallet.upsert({
                where: { userId },
                update: {
                  balance: { increment: quest.rewardCoins },
                  lifetimePoints: { increment: quest.rewardCoins },
                  monthlyXp: { increment: quest.rewardXp },
                },
                create: {
                  userId,
                  balance: quest.rewardCoins,
                  lifetimePoints: quest.rewardCoins,
                  monthlyXp: quest.rewardXp,
                  lastResetDate: new Date(),
                },
              });

              // Create transaction
              await tx.transaction.create({
                data: {
                  userId,
                  type: "MILESTONE",
                  points: quest.rewardCoins,
                  description: `Adventure Quest completed: ${quest.title}`,
                },
              });

              // Create system notification
              await tx.notification.create({
                data: {
                  userId,
                  title: "Quest Completed! 🎉",
                  message: `Congratulations! You completed "${quest.title}" and earned ${quest.rewardCoins} coins and ${quest.rewardXp} XP!`,
                  type: "achievement",
                },
              });
            }
          });
        } else {
          // Advance to the next stage!
          const updateResult = await this.prisma.userQuest.updateMany({
            where: { 
              id: userQuest.id,
              currentStageIndex: currentStageIndex,
              status: "IN_PROGRESS"
            },
            data: {
              currentStageIndex: nextStageIndex,
            },
          });

          if (updateResult.count > 0) {
            // Create stage completed notification
            await this.prisma.notification.create({
              data: {
                userId,
                title: "Quest Stage Cleared! 🚀",
                message: `You cleared Stage ${currentStageIndex + 1} of "${quest.title}". Next stage: "${stages[nextStageIndex].title}"!`,
                type: "system",
              },
            });
          }
        }
      }
    }
  }
}
