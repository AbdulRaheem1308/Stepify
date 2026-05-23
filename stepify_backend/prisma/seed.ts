import { PrismaClient, TransactionType, FeedType } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Seeding database...');

    // 1. Cleanup
    const tablenames = ['feed_comments', 'feed_reactions', 'feed_posts', 'friendships', 'user_challenges', 'user_redemptions', 'user_achievements', 'challenges', 'offers', 'rewards', 'avatars', 'steps', 'transactions', 'wallets', 'streaks', 'users'];
    // Truncate/Delete logic - careful with FKs. Deleting Users cascades to most.
    // For simplicity, we delete specific tables or just upsert.
    // Let's delete Demo User if exists to reset their data.
    const demoEmail = 'demo@stepify.com';
    await prisma.user.deleteMany({
        where: {
            email: { in: [demoEmail, 'alice@example.com'] }
        }
    });

    // Also clean up common tables to avoid duplicates if re-running
    await prisma.userAchievement.deleteMany();
    await prisma.achievement.deleteMany();

    await prisma.level.deleteMany();

    await prisma.userOffer.deleteMany();
    await prisma.offer.deleteMany();

    await prisma.userRedemption.deleteMany();
    await prisma.reward.deleteMany();

    await prisma.avatar.deleteMany();

    console.log('🧹 Cleanup done');

    // 2. Seed Levels
    const levels = [
        { levelNumber: 1, name: 'Beginner', minXp: 0, maxXp: 100, icon: 'directions_walk', color: '#9E9E9E' },
        { levelNumber: 2, name: 'Starter', minXp: 100, maxXp: 300, icon: 'directions_walk', color: '#795548' },
        { levelNumber: 3, name: 'Newcomer', minXp: 300, maxXp: 600, icon: 'directions_walk', color: '#FF9800' },
        { levelNumber: 4, name: 'Apprentice', minXp: 600, maxXp: 1000, icon: 'trending_up', color: '#FFC107' },
        { levelNumber: 5, name: 'Rookie Walker', minXp: 1000, maxXp: 1500, icon: 'directions_run', color: '#8BC34A' },
        { levelNumber: 6, name: 'Trail Finder', minXp: 1500, maxXp: 2200, icon: 'explore', color: '#4CAF50' },
        { levelNumber: 7, name: 'Path Seeker', minXp: 2200, maxXp: 3000, icon: 'map', color: '#009688' },
        { levelNumber: 8, name: 'Urban Explorer', minXp: 3000, maxXp: 4000, icon: 'location_city', color: '#00BCD4' },
        { levelNumber: 9, name: 'Street Strider', minXp: 4000, maxXp: 5200, icon: 'streetview', color: '#03A9F4' },
        { levelNumber: 10, name: 'City Walker', minXp: 5200, maxXp: 6500, icon: 'directions_walk', color: '#2196F3' },
        { levelNumber: 11, name: 'Trail Blazer', minXp: 6500, maxXp: 8000, icon: 'local_fire_department', color: '#3F51B5' },
        { levelNumber: 12, name: 'Distance Runner', minXp: 8000, maxXp: 10000, icon: 'directions_run', color: '#673AB7' },
        { levelNumber: 13, name: 'Marathon Master', minXp: 10000, maxXp: 15000, icon: 'emoji_events', color: '#9C27B0' },
        { levelNumber: 14, name: 'Step Champion', minXp: 15000, maxXp: 20000, icon: 'military_tech', color: '#E91E63' },
        { levelNumber: 15, name: 'Legendary Stepper', minXp: 20000, maxXp: 999999, icon: 'stars', color: '#FFD700' },
    ];
    for (const level of levels) {
        await prisma.level.create({ data: level });
    }
    console.log(`🎯 Seeded ${levels.length} levels`);

    // 3. Seed Avatars
    const avatars = [
        { url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Felix', category: 'male' },
        { url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka', category: 'female' },
        { url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Zoe', category: 'female' },
        { url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Max', category: 'male' },
        { url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Buddy', category: 'neutral' },
        { url: 'https://api.dicebear.com/7.x/bottts/png?seed=Robot', category: 'robot' },
    ];
    for (const av of avatars) {
        await prisma.avatar.create({ data: av });
    }
    console.log(`✅ Seeded ${avatars.length} avatars`);

    // 4. Seed Achievements (Badges)
    const achievements = [
        // Steps badges
        { code: 'FIRST_STEPS', name: 'First Steps', description: 'Walk your first 5,000 steps', icon: 'directions_walk', category: 'STEPS', pointsReward: 50, stepsRequired: 5000 },
        { code: 'DAILY_CHAMPION', name: 'Daily Champion', description: 'Reach your daily step goal', icon: 'flag', category: 'STEPS', pointsReward: 100, stepsRequired: 10000 },
        { code: 'MARATHON_MASTER', name: 'Marathon Master', description: 'Walk 42,195 steps in one day', icon: 'emoji_events', category: 'STEPS', pointsReward: 500, stepsRequired: 42195 },
        { code: 'STEP_LEGEND', name: 'Step Legend', description: 'Walk 1,000,000 lifetime steps', icon: 'stars', category: 'STEPS', pointsReward: 1000, stepsRequired: 1000000 },

        // Streak badges
        { code: 'STREAK_STARTER', name: 'Streak Starter', description: 'Maintain a 7-day streak', icon: 'local_fire_department', category: 'STREAK', pointsReward: 75, streakRequired: 7 },
        { code: 'WEEK_WARRIOR', name: 'Week Warrior', description: 'Maintain a 14-day streak', icon: 'calendar_today', category: 'STREAK', pointsReward: 150, streakRequired: 14 },
        { code: 'CONSISTENT_WALKER', name: 'Consistent Walker', description: 'Maintain a 30-day streak', icon: 'trending_up', category: 'STREAK', pointsReward: 500, streakRequired: 30 },

        // Time-based badges
        { code: 'EARLY_BIRD', name: 'Early Bird', description: 'Complete 2,000 steps before 8 AM', icon: 'wb_sunny', category: 'SPECIAL', pointsReward: 100 },
        { code: 'NIGHT_OWL', name: 'Night Owl', description: 'Complete 1,000 steps after 10 PM', icon: 'nightlight', category: 'SPECIAL', pointsReward: 100 },

        // Social badges
        { code: 'SOCIAL_BUTTERFLY', name: 'Social Butterfly', description: 'Invite 5 friends', icon: 'people', category: 'SOCIAL', pointsReward: 200, targetValue: 5 },
        { code: 'TEAM_PLAYER', name: 'Team Player', description: 'Complete a group challenge', icon: 'groups', category: 'SOCIAL', pointsReward: 150 },

        // Challenge badges
        { code: 'CHALLENGE_CHAMP', name: 'Challenge Champ', description: 'Complete 10 challenges', icon: 'military_tech', category: 'CHALLENGE', pointsReward: 300, targetValue: 10 },
        { code: 'FIRST_CHALLENGE', name: 'First Challenge', description: 'Complete your first challenge', icon: 'emoji_flags', category: 'CHALLENGE', pointsReward: 50, targetValue: 1 },

        // Coin badges
        { code: 'COIN_COLLECTOR', name: 'Coin Collector', description: 'Earn 10,000 step coins', icon: 'stars_rounded', category: 'COINS', pointsReward: 200, targetValue: 10000 },
        { code: 'FIRST_REWARD', name: 'First Reward', description: 'Redeem your first reward', icon: 'card_giftcard', category: 'COINS', pointsReward: 100, targetValue: 1 },
    ] as any[];

    const createdAchievements = [];
    for (const a of achievements) {
        createdAchievements.push(await prisma.achievement.create({ data: a }));
    }
    console.log(`🏆 Seeded ${achievements.length} achievements/badges`);

    // 4. Seed Rewards
    const rewards = [
        { title: '10% Off Nike Store', description: 'Get 10% discount on your next Nike purchase', coinCost: 500, category: 'FITNESS', partnerName: 'Nike', imageUrl: 'https://logo.clearbit.com/nike.com' },
        { title: 'Free Starbucks Coffee', description: 'Enjoy a free tall drink of your choice', coinCost: 300, category: 'FOOD', partnerName: 'Starbucks', imageUrl: 'https://logo.clearbit.com/starbucks.com' },
    ] as any[];
    for (const r of rewards) {
        await prisma.reward.create({ data: r });
    }

    // Removed Demo User and fake steps/transactions so you can test with real data!
    console.log('🎉 Seeding complete (Essential Master Data Only)!');
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
