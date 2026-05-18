import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function initializeAchievementsForAllUsers() {
    console.log('\n🚀 Initializing achievements for all users...\n');

    // Get all achievements
    const achievements = await prisma.achievement.findMany({
        where: { isActive: true },
    });
    console.log(`Found ${achievements.length} active achievements`);

    // Get all users
    const users = await prisma.user.findMany({
        select: { id: true, name: true, phone: true },
    });
    console.log(`Found ${users.length} users\n`);

    let created = 0;
    let skipped = 0;

    for (const user of users) {
        console.log(`Processing user: ${user.name || user.phone}`);

        for (const achievement of achievements) {
            // Check if record already exists
            const existing = await prisma.userAchievement.findUnique({
                where: {
                    userId_achievementId: {
                        userId: user.id,
                        achievementId: achievement.id,
                    },
                },
            });

            if (!existing) {
                await prisma.userAchievement.create({
                    data: {
                        userId: user.id,
                        achievementId: achievement.id,
                        unlocked: false,
                        progress: 0,
                        currentValue: 0,
                    },
                });
                created++;
            } else {
                skipped++;
            }
        }
    }

    console.log(`\n✅ Done!`);
    console.log(`   Created: ${created} new UserAchievement records`);
    console.log(`   Skipped: ${skipped} (already existed)`);

    // Verify
    const total = await prisma.userAchievement.count();
    console.log(`\n📊 Total UserAchievement records in database: ${total}`);
}

initializeAchievementsForAllUsers()
    .catch(console.error)
    .finally(() => prisma.$disconnect());
