import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function dumpUserData(phone: string) {
    console.log(`\n🔍 Searching for user with phone: ${phone}\n`);
    console.log('='.repeat(80));

    // Find user
    const user = await prisma.user.findFirst({
        where: { phone },
        include: {
            wallet: true,
            streak: true,
        },
    });

    if (!user) {
        console.log('❌ User not found with this phone number');
        return;
    }

    console.log('\n📋 USER TABLE');
    console.log('-'.repeat(40));
    console.log(JSON.stringify(user, null, 2));

    // Steps
    const steps = await prisma.step.findMany({
        where: { userId: user.id },
        orderBy: { date: 'desc' },
    });
    console.log(`\n👣 STEPS TABLE (${steps.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(steps, null, 2));

    // Transactions
    const transactions = await prisma.transaction.findMany({
        where: { userId: user.id },
        orderBy: { createdAt: 'desc' },
    });
    console.log(`\n💰 TRANSACTIONS TABLE (${transactions.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(transactions, null, 2));

    // User Achievements
    const userAchievements = await prisma.userAchievement.findMany({
        where: { userId: user.id },
        include: { achievement: true },
    });
    console.log(`\n🏆 USER_ACHIEVEMENTS TABLE (${userAchievements.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(userAchievements, null, 2));

    // User Challenges
    const userChallenges = await prisma.userChallenge.findMany({
        where: { userId: user.id },
        include: { challenge: true },
    });
    console.log(`\n🎯 USER_CHALLENGES TABLE (${userChallenges.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(userChallenges, null, 2));

    // User Redemptions
    const userRedemptions = await prisma.userRedemption.findMany({
        where: { userId: user.id },
        include: { reward: true },
    });
    console.log(`\n🎁 USER_REDEMPTIONS TABLE (${userRedemptions.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(userRedemptions, null, 2));

    // User Offers
    const userOffers = await prisma.userOffer.findMany({
        where: { userId: user.id },
        include: { offer: true },
    });
    console.log(`\n🏷️ USER_OFFERS TABLE (${userOffers.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(userOffers, null, 2));

    // Ad Views
    const adViews = await prisma.adView.findMany({
        where: { userId: user.id },
    });
    console.log(`\n📺 AD_VIEWS TABLE (${adViews.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(adViews, null, 2));

    // Devices
    const devices = await prisma.device.findMany({
        where: { userId: user.id },
    });
    console.log(`\n📱 DEVICES TABLE (${devices.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(devices, null, 2));

    // Friendships
    const friendships = await prisma.friendship.findMany({
        where: { OR: [{ userId: user.id }, { friendId: user.id }] },
    });
    console.log(`\n👥 FRIENDSHIPS TABLE (${friendships.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(friendships, null, 2));

    // Feed Posts
    const feedPosts = await prisma.feedPost.findMany({
        where: { userId: user.id },
    });
    console.log(`\n📝 FEED_POSTS TABLE (${feedPosts.length} records)`);
    console.log('-'.repeat(40));
    console.log(JSON.stringify(feedPosts, null, 2));

    console.log('\n' + '='.repeat(80));
    console.log('✅ Database dump complete');
}

dumpUserData('+919550802278')
    .catch(console.error)
    .finally(() => prisma.$disconnect());
