/**
 * Seed script to regenerate community feed posts
 * Run with: npx ts-node prisma/seed-community.ts
 */
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const feedPostTemplates = [
    // Milestone posts
    { type: 'MILESTONE', content: '🎉 Just hit 10,000 steps today! New personal record!', likesCount: 45, commentsCount: 12 },
    { type: 'MILESTONE', content: '💪 Completed my first 5K walk! So proud of this achievement.', likesCount: 67, commentsCount: 18 },
    { type: 'MILESTONE', content: '🏆 Finally reached 100,000 lifetime steps! The journey continues.', likesCount: 89, commentsCount: 24 },
    { type: 'MILESTONE', content: '⭐ Level up! Just became a "Step Master" - Level 10!', likesCount: 34, commentsCount: 8 },
    { type: 'MILESTONE', content: '🎊 Earned 1000 coins this week! Time to redeem some rewards.', likesCount: 56, commentsCount: 14 },

    // Streak posts
    { type: 'STREAK', content: '🔥 7-day streak! Consistency is key!', likesCount: 32, commentsCount: 7 },
    { type: 'STREAK', content: '🔥🔥 30-day streak achieved! One month of daily goals!', likesCount: 78, commentsCount: 21 },
    { type: 'STREAK', content: '💪 My longest streak yet - 14 days and counting!', likesCount: 41, commentsCount: 9 },
    { type: 'STREAK', content: '🌟 Started a new streak today. Let\'s go!', likesCount: 23, commentsCount: 5 },
    { type: 'STREAK', content: '🔥 50-day streak! Halfway to 100!', likesCount: 91, commentsCount: 28 },

    // Challenge posts
    { type: 'CHALLENGE', content: '🏅 Just completed the "Weekend Warrior" challenge! Earned 500 coins.', likesCount: 54, commentsCount: 11 },
    { type: 'CHALLENGE', content: '🎯 Joined the 10K Steps Challenge. Who else is in?', likesCount: 38, commentsCount: 16 },
    { type: 'CHALLENGE', content: '🏆 Won 1st place in the group challenge! Team effort!', likesCount: 102, commentsCount: 32 },
    { type: 'CHALLENGE', content: '💪 Started the "Step Marathon" - 42K steps in one day. Wish me luck!', likesCount: 65, commentsCount: 19 },
    { type: 'CHALLENGE', content: '🎉 Completed 5 challenges this month! New personal best.', likesCount: 47, commentsCount: 13 },

    // Manual posts
    { type: 'MANUAL', content: 'Morning walk by the beach today. Perfect weather! 🌅', likesCount: 83, commentsCount: 15 },
    { type: 'MANUAL', content: 'Walking meeting with colleagues. Who says work can\'t be healthy? 👟', likesCount: 29, commentsCount: 6 },
    { type: 'MANUAL', content: 'Exploring a new hiking trail this weekend. Nature + steps = perfect combo 🌲', likesCount: 61, commentsCount: 17 },
    { type: 'MANUAL', content: 'Taking the stairs instead of elevator. Every step counts! 📈', likesCount: 44, commentsCount: 8 },
    { type: 'MANUAL', content: 'Dog walking duty = best cardio ever! 🐕', likesCount: 72, commentsCount: 22 },
    { type: 'MANUAL', content: 'Rainy day walk with music. Sometimes the best walks are in the rain ☔', likesCount: 36, commentsCount: 9 },
    { type: 'MANUAL', content: 'Kids are finally walking with me. Family fitness is the best! 👨‍👩‍👧', likesCount: 88, commentsCount: 26 },
    { type: 'MANUAL', content: 'Lunchtime walk around the office park. Fresh air = productivity boost 💡', likesCount: 25, commentsCount: 4 },
    { type: 'MANUAL', content: 'Evening sunset walk. These are the moments I live for 🌄', likesCount: 95, commentsCount: 31 },
    { type: 'MANUAL', content: 'Walking to work saved me gym money this month! 💰', likesCount: 51, commentsCount: 12 },
];

async function seedCommunityFeed() {
    console.log('🌱 Starting Community Feed seed...');

    // Get all users
    const users = await prisma.user.findMany({ take: 20 });

    if (users.length === 0) {
        console.log('❌ No users found! Please seed users first.');
        return;
    }

    console.log(`Found ${users.length} users to create posts for.`);

    // Clear existing feed posts
    await prisma.feedReaction.deleteMany();
    await prisma.feedComment.deleteMany();
    await prisma.feedPost.deleteMany();
    console.log('🗑️ Cleared existing feed data.');

    // Create posts for each user
    const posts = [];
    const now = new Date();

    for (let i = 0; i < feedPostTemplates.length; i++) {
        const template = feedPostTemplates[i];
        const user = users[i % users.length]; // Round-robin users

        // Create post with random timestamp in last 30 days
        const daysAgo = Math.floor(Math.random() * 30);
        const hoursAgo = Math.floor(Math.random() * 24);
        const createdAt = new Date(now);
        createdAt.setDate(createdAt.getDate() - daysAgo);
        createdAt.setHours(createdAt.getHours() - hoursAgo);

        const post = await prisma.feedPost.create({
            data: {
                userId: user.id,
                content: template.content,
                type: template.type as any,
                likesCount: template.likesCount,
                commentsCount: template.commentsCount,
                createdAt: createdAt,
            },
        });

        posts.push(post);
    }

    console.log(`✅ Created ${posts.length} feed posts.`);

    // Create some reactions
    let reactionCount = 0;
    for (const post of posts.slice(0, 10)) {
        // Add 3-5 reactions per post from different users
        const reactCount = 3 + Math.floor(Math.random() * 3);
        const reactingUsers = users.filter(u => u.id !== post.userId).slice(0, reactCount);

        for (const user of reactingUsers) {
            await prisma.feedReaction.create({
                data: {
                    postId: post.id,
                    userId: user.id,
                    type: ['like', 'clap', 'fire'][Math.floor(Math.random() * 3)],
                },
            });
            reactionCount++;
        }
    }

    console.log(`✅ Created ${reactionCount} reactions.`);

    // Create some comments
    const commentTemplates = [
        'Amazing progress! 👏',
        'Keep it up! 💪',
        'Inspiring! 🌟',
        'Goals! 🎯',
        'This is awesome!',
        'Love this! ❤️',
        'You\'re crushing it!',
        'Way to go! 🙌',
        'So motivating!',
        'This made my day!',
    ];

    let commentCount = 0;
    for (const post of posts.slice(0, 8)) {
        // Add 2-4 comments per post
        const numComments = 2 + Math.floor(Math.random() * 3);
        const commentingUsers = users.filter(u => u.id !== post.userId).slice(0, numComments);

        for (const user of commentingUsers) {
            const commentText = commentTemplates[Math.floor(Math.random() * commentTemplates.length)];
            await prisma.feedComment.create({
                data: {
                    postId: post.id,
                    userId: user.id,
                    content: commentText,
                },
            });
            commentCount++;
        }
    }

    console.log(`✅ Created ${commentCount} comments.`);

    console.log('\n🎉 Community Feed seeding complete!');
    console.log(`   📝 Posts: ${posts.length}`);
    console.log(`   ❤️ Reactions: ${reactionCount}`);
    console.log(`   💬 Comments: ${commentCount}`);
}

seedCommunityFeed()
    .catch(e => {
        console.error('❌ Error seeding community feed:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
