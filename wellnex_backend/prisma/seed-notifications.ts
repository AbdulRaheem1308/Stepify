/**
 * Seed script to populate Notification table from existing Transactions and Achievements
 * Run with: npx ts-node prisma/seed-notifications.ts
 */
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function seedNotifications() {
    console.log('🌱 Starting Notification seed...');

    // Get all users
    const users = await prisma.user.findMany();

    if (users.length === 0) {
        console.log('❌ No users found!');
        return;
    }

    // Clear existing notifications
    await (prisma as any).notification.deleteMany(); // Cast as any in case types aren't updated yet
    console.log('🗑️ Cleared existing notifications.');

    let totalNotifications = 0;

    for (const user of users) {
        // 1. Convert Transactions
        const transactions = await prisma.transaction.findMany({
            where: { userId: user.id },
            orderBy: { createdAt: 'desc' },
            take: 20,
        });

        for (const tx of transactions) {
            await (prisma as any).notification.create({
                data: {
                    userId: user.id,
                    title: getTitleForType(tx.type),
                    message: tx.description || 'You earned points!',
                    type: tx.type.toLowerCase(),
                    isRead: Math.random() > 0.3, // 70% chance of being read
                    createdAt: tx.createdAt,
                },
            });
            totalNotifications++;
        }

        // 2. Convert Achievements
        const achievements = await prisma.userAchievement.findMany({
            where: { userId: user.id },
            include: { achievement: true },
            orderBy: { unlockedAt: 'desc' },
            take: 10,
        });

        for (const ua of achievements) {
            await (prisma as any).notification.create({
                data: {
                    userId: user.id,
                    title: '🏆 Badge Unlocked!',
                    message: `You earned: ${ua.achievement.name}`,
                    type: 'achievement',
                    isRead: Math.random() > 0.3,
                    createdAt: ua.unlockedAt ?? new Date(),
                },
            });
            totalNotifications++;
        }

        // 3. Add some manual system notifications
        await (prisma as any).notification.create({
            data: {
                userId: user.id,
                title: '👋 Welcome to Wellnex!',
                message: 'Start walking to earn rewards. Check out our Challenges section!',
                type: 'system',
                isRead: true,
                createdAt: user.createdAt,
            },
        });
        totalNotifications++;
    }

    console.log(`✅ Created ${totalNotifications} notifications for ${users.length} users.`);
}

function getTitleForType(type: string): string {
    switch (type) {
        case 'STEPS': return '👟 Steps Reward';
        case 'STREAK_BONUS': return '🔥 Streak Bonus!';
        case 'MILESTONE': return '🏅 Milestone Achieved';
        case 'AD_REWARD': return '🎬 Ad Reward';
        case 'REFERRAL': return '👥 Referral Bonus';
        case 'REDEMPTION': return '🎁 Reward Redeemed';
        case 'OFFER_REWARD': return '🎉 Offer Completed';
        default: return '📢 Notification';
    }
}

seedNotifications()
    .catch(e => {
        console.error('❌ Error seeding notifications:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
