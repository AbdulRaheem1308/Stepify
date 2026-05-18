import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function dumpAllTables() {
    console.log('\n🗄️ COMPLETE DATABASE DUMP');
    console.log('='.repeat(80));
    console.log(`Timestamp: ${new Date().toISOString()}\n`);

    // Users
    const users = await prisma.user.findMany({ include: { wallet: true, streak: true } });
    console.log(`\n👤 USERS TABLE (${users.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(users, null, 2));

    // Achievements (master list)
    const achievements = await prisma.achievement.findMany({ orderBy: { category: 'asc' } });
    console.log(`\n🏆 ACHIEVEMENTS TABLE (${achievements.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(achievements, null, 2));

    // User Achievements
    const userAchievements = await prisma.userAchievement.findMany({ include: { achievement: true, user: { select: { name: true, phone: true } } } });
    console.log(`\n🎖️ USER_ACHIEVEMENTS TABLE (${userAchievements.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(userAchievements, null, 2));

    // Levels
    const levels = await prisma.level.findMany({ orderBy: { levelNumber: 'asc' } });
    console.log(`\n📊 LEVELS TABLE (${levels.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(levels, null, 2));

    // Challenges
    const challenges = await prisma.challenge.findMany();
    console.log(`\n🎯 CHALLENGES TABLE (${challenges.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(challenges, null, 2));

    // Steps (summary by user)
    const stepsCount = await prisma.step.groupBy({
        by: ['userId'],
        _count: { id: true },
        _sum: { stepCount: true },
    });
    console.log(`\n👣 STEPS TABLE SUMMARY (by user)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(stepsCount, null, 2));

    // Rewards
    const rewards = await prisma.reward.findMany();
    console.log(`\n🎁 REWARDS TABLE (${rewards.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(rewards, null, 2));

    // Offers
    const offers = await prisma.offer.findMany();
    console.log(`\n🏷️ OFFERS TABLE (${offers.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(offers, null, 2));

    // Avatars
    const avatars = await prisma.avatar.findMany();
    console.log(`\n🎭 AVATARS TABLE (${avatars.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(avatars, null, 2));

    // Transactions
    const transactions = await prisma.transaction.findMany({ take: 20, orderBy: { createdAt: 'desc' } });
    console.log(`\n💰 TRANSACTIONS TABLE (showing last 20)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(transactions, null, 2));

    // User Challenges
    const userChallenges = await prisma.userChallenge.findMany({ include: { challenge: true } });
    console.log(`\n🎯 USER_CHALLENGES TABLE (${userChallenges.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(userChallenges, null, 2));

    // Friendships
    const friendships = await prisma.friendship.findMany();
    console.log(`\n👥 FRIENDSHIPS TABLE (${friendships.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(friendships, null, 2));

    console.log('\n' + '='.repeat(80));
    console.log('✅ Complete database dump finished');
}

dumpAllTables()
    .catch(console.error)
    .finally(() => prisma.$disconnect());
