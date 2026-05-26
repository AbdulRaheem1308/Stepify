import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function seedComprehensiveTestData() {
    console.log('\n🌱 SEEDING COMPREHENSIVE TEST DATA\n');
    console.log('='.repeat(60));

    // Get existing users
    const users = await prisma.user.findMany();
    const abdulUser = users.find(u => u.phone === '+919550802278');
    const demoUser = users.find(u => u.email === 'demo@stepify.com');

    if (!abdulUser || !demoUser) {
        console.log('❌ Required users not found. Run seed first.');
        return;
    }

    // 1. CHALLENGES
    console.log('\n🎯 Seeding CHALLENGES...');
    const challenges = [
        { title: 'New Year 10K Challenge', description: 'Walk 10,000 steps every day this week', stepTarget: 80000, rewardCoins: 600, rewardXp: 300, durationDays: 7, challengeType: 'SOLO' as any, difficulty: 'MEDIUM' as any, isActive: true },
        { title: 'Weekend Warrior', description: 'Complete 30,000 steps over the weekend', stepTarget: 30000, rewardCoins: 250, rewardXp: 150, durationDays: 2, challengeType: 'SOLO' as any, difficulty: 'HARD' as any, isActive: true },
        { title: 'Monthly Marathon', description: 'Walk 300,000 steps this month', stepTarget: 300000, rewardCoins: 1000, rewardXp: 500, durationDays: 30, challengeType: 'SOLO' as any, difficulty: 'HARD' as any, isActive: true },
        { title: 'Team Step Sprint', description: 'Team up and reach 100K steps together', stepTarget: 100000, rewardCoins: 300, rewardXp: 150, durationDays: 7, challengeType: 'GROUP' as any, difficulty: 'MEDIUM' as any, isActive: true },
    ];

    for (const c of challenges) {
        await prisma.challenge.create({ data: c }).catch(() => { });
    }
    console.log(`   ✅ ${challenges.length} challenges created`);

    // Get created challenges
    const allChallenges = await prisma.challenge.findMany();

    // 2. USER_CHALLENGES
    console.log('\n🎮 Seeding USER_CHALLENGES...');
    if (allChallenges.length >= 2) {
        const userChallenges = [
            { userId: abdulUser.id, challengeId: allChallenges[0].id, currentSteps: 45000, progress: 64, status: 'ONGOING' as any },
            { userId: abdulUser.id, challengeId: allChallenges[2]?.id || allChallenges[1].id, currentSteps: 120000, progress: 40, status: 'ONGOING' as any },
            { userId: demoUser.id, challengeId: allChallenges[0].id, currentSteps: 70000, progress: 100, status: 'COMPLETED' as any },
            { userId: demoUser.id, challengeId: allChallenges[1].id, currentSteps: 25000, progress: 100, status: 'COMPLETED' as any },
        ];
        for (const uc of userChallenges) {
            await prisma.userChallenge.create({ data: uc }).catch(() => { });
        }
        console.log(`   ✅ User challenges created`);
    }

    // 3. OFFERS
    console.log('\n🏷️ Seeding OFFERS...');
    const offers = [
        { title: 'Watch & Earn 100 Coins', description: 'Watch a short video to earn coins!', providerName: 'AdMob', rewardCoins: 100, offerType: 'WATCH_TO_EARN' as any, isActive: true },
        { title: 'Complete Survey', description: 'Share your feedback and earn rewards', providerName: 'SurveyMonkey', rewardCoins: 250, offerType: 'SURVEY' as any, isActive: true },
        { title: 'Try Fitness App', description: 'Download and try this fitness app', providerName: 'FitPartner', rewardCoins: 500, offerType: 'APP_INSTALL' as any, isActive: true },
    ];
    for (const o of offers) {
        await prisma.offer.create({ data: o }).catch(() => { });
    }
    console.log(`   ✅ ${offers.length} offers created`);

    const allOffers = await prisma.offer.findMany();

    // 4. USER_OFFERS
    console.log('\n🎁 Seeding USER_OFFERS...');
    for (const offer of allOffers) {
        await prisma.userOffer.create({
            data: { userId: abdulUser.id, offerId: offer.id, status: 'STARTED' as any }
        }).catch(() => { });
    }
    console.log(`   ✅ User offers created`);

    // 5. TRANSACTIONS
    console.log('\n💰 Seeding TRANSACTIONS...');
    const transactions = [
        { userId: abdulUser.id, type: 'STEPS' as any, points: 100, description: 'Daily steps reward' },
        { userId: abdulUser.id, type: 'MILESTONE' as any, points: 75, description: 'Streak Starter badge unlocked' },
        { userId: abdulUser.id, type: 'AD_REWARD' as any, points: 25, description: 'Watched reward ad' },
        { userId: demoUser.id, type: 'STEPS' as any, points: 200, description: 'Daily steps reward' },
        { userId: demoUser.id, type: 'STREAK_BONUS' as any, points: 150, description: '7-day streak bonus' },
        { userId: demoUser.id, type: 'REFERRAL' as any, points: 100, description: 'Friend joined via referral' },
    ];
    for (const t of transactions) {
        await prisma.transaction.create({ data: t }).catch(() => { });
    }
    console.log(`   ✅ ${transactions.length} transactions created`);

    // 6. AD_VIEWS
    console.log('\n📺 Seeding AD_VIEWS...');
    const adViews = [
        { userId: abdulUser.id, adType: 'REWARDED' as any, coinsEarned: 25, duration: 30 },
        { userId: abdulUser.id, adType: 'REWARDED' as any, coinsEarned: 25, duration: 30 },
        { userId: demoUser.id, adType: 'REWARDED' as any, coinsEarned: 25, duration: 30 },
    ];
    for (const ad of adViews) {
        await prisma.adView.create({ data: ad }).catch(() => { });
    }
    console.log(`   ✅ Ad views created`);

    // 7. FEED_POSTS
    console.log('\n📝 Seeding FEED_POSTS...');
    const feedPosts = [
        { userId: demoUser.id, type: 'MILESTONE' as any, content: 'Just unlocked Week Warrior! 🎉', isPublic: true },
        { userId: demoUser.id, type: 'STREAK' as any, content: 'Hit 100,000 lifetime steps! 💪', isPublic: true },
        { userId: abdulUser.id, type: 'CHALLENGE' as any, content: 'Joined the New Year 10K Challenge!', isPublic: true },
    ];
    for (const fp of feedPosts) {
        await prisma.feedPost.create({ data: fp }).catch(() => { });
    }
    console.log(`   ✅ Feed posts created`);

    const allPosts = await prisma.feedPost.findMany();

    // 8. FEED_REACTIONS
    console.log('\n❤️ Seeding FEED_REACTIONS...');
    if (allPosts.length > 0) {
        await prisma.feedReaction.create({ data: { userId: abdulUser.id, postId: allPosts[0].id, type: 'like' } }).catch(() => { });
        if (allPosts.length > 1) {
            await prisma.feedReaction.create({ data: { userId: abdulUser.id, postId: allPosts[1].id, type: 'fire' } }).catch(() => { });
        }
    }
    console.log(`   ✅ Feed reactions created`);

    // 9. FEED_COMMENTS
    console.log('\n💬 Seeding FEED_COMMENTS...');
    if (allPosts.length > 0) {
        await prisma.feedComment.create({ data: { userId: abdulUser.id, postId: allPosts[0].id, content: 'Congratulations! 🎊' } }).catch(() => { });
    }
    console.log(`   ✅ Feed comments created`);

    // 10. USER_REDEMPTIONS
    console.log('\n🎁 Seeding USER_REDEMPTIONS...');
    const rewards = await prisma.reward.findMany();
    if (rewards.length > 0) {
        await prisma.userRedemption.create({
            data: {
                userId: demoUser.id,
                rewardId: rewards[0].id,
                coinCost: rewards[0].coinCost,
                status: 'ACTIVE' as any,
                voucherCode: 'NIKE-XYZ-123',
            }
        }).catch(() => { });
    }
    console.log(`   ✅ User redemption created`);

    // 11. DEVICES
    console.log('\n📱 Seeding DEVICES...');
    const devices = [
        { userId: abdulUser.id, name: 'Samsung Galaxy', type: 'PHONE' as any, identifier: 'android-uuid-12345' },
        { userId: demoUser.id, name: 'Apple Watch', type: 'WATCH_APPLE' as any, identifier: 'ios-uuid-67890' },
    ];
    for (const d of devices) {
        await prisma.device.create({ data: d }).catch(() => { });
    }
    console.log(`   ✅ Devices created`);

    // 12. APP_CONFIG
    console.log('\n⚙️ Seeding APP_CONFIG...');
    const configs = [
        { key: 'steps_to_coins_ratio', value: '100' },
        { key: 'daily_ad_limit', value: '5' },
        { key: 'referral_bonus', value: '100' },
        { key: 'min_steps_for_streak', value: '5000' },
    ];
    for (const cfg of configs) {
        await prisma.appConfig.upsert({
            where: { key: cfg.key },
            update: { value: cfg.value },
            create: cfg,
        });
    }
    console.log(`   ✅ App configs created`);

    // 13. Update wallets
    console.log('\n💰 Updating WALLETS...');
    await prisma.wallet.update({
        where: { userId: abdulUser.id },
        data: { balance: 325, lifetimePoints: 500 },
    });
    console.log(`   ✅ Wallets updated`);

    // 14. Update streaks
    console.log('\n🔥 Updating STREAKS...');
    await prisma.streak.update({
        where: { userId: abdulUser.id },
        data: { currentStreak: 5, longestStreak: 12, lastActiveDate: new Date() },
    });
    console.log(`   ✅ Streaks updated`);

    // 15. INVITATIONS
    console.log('\n📧 Seeding INVITATIONS...');
    const referralCode = `INV${Date.now()}`;
    await prisma.invitation.create({
        data: {
            inviterId: abdulUser.id,
            inviteePhone: '+919876543210',
            referralCode,
            status: 'SENT' as any,
        }
    }).catch(() => { });
    console.log(`   ✅ Invitation created`);

    // 16. FRIEND_BOOSTS
    console.log('\n🚀 Seeding FRIEND_BOOSTS...');
    await prisma.friendBoost.create({
        data: { senderId: demoUser.id, receiverId: abdulUser.id }
    }).catch(() => { });
    console.log(`   ✅ Friend boost created`);

    // SUMMARY
    console.log('\n' + '='.repeat(60));
    console.log('✅ COMPREHENSIVE SEED COMPLETE!\n');

    const counts = await Promise.all([
        prisma.challenge.count(),
        prisma.userChallenge.count(),
        prisma.offer.count(),
        prisma.userOffer.count(),
        prisma.transaction.count(),
        prisma.adView.count(),
        prisma.feedPost.count(),
        prisma.feedReaction.count(),
        prisma.feedComment.count(),
        prisma.userRedemption.count(),
        prisma.device.count(),
        prisma.appConfig.count(),
        prisma.invitation.count(),
        prisma.friendBoost.count(),
    ]);

    console.log('📊 Table Counts:');
    console.log(`   challenges:       ${counts[0]}`);
    console.log(`   user_challenges:  ${counts[1]}`);
    console.log(`   offers:           ${counts[2]}`);
    console.log(`   user_offers:      ${counts[3]}`);
    console.log(`   transactions:     ${counts[4]}`);
    console.log(`   ad_views:         ${counts[5]}`);
    console.log(`   feed_posts:       ${counts[6]}`);
    console.log(`   feed_reactions:   ${counts[7]}`);
    console.log(`   feed_comments:    ${counts[8]}`);
    console.log(`   user_redemptions: ${counts[9]}`);
    console.log(`   devices:          ${counts[10]}`);
    console.log(`   app_config:       ${counts[11]}`);
    console.log(`   invitations:      ${counts[12]}`);
    console.log(`   friend_boosts:    ${counts[13]}`);
}

seedComprehensiveTestData()
    .catch(console.error)
    .finally(() => prisma.$disconnect());
