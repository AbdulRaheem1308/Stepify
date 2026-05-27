import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Seeding Dummy Users...');

    const avatars = [
        'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
        'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka',
        'https://api.dicebear.com/7.x/avataaars/png?seed=Zoe',
        'https://api.dicebear.com/7.x/avataaars/png?seed=Max',
        'https://api.dicebear.com/7.x/avataaars/png?seed=Buddy',
        'https://api.dicebear.com/7.x/bottts/png?seed=Robot',
    ];

    const names = [
        'Alice Walker', 'Bob Runner', 'Charlie Step', 'Diana Dash', 'Evan Exercise',
        'Fiona Fit', 'George Go', 'Hannah Hike', 'Ian Incline', 'Julia Jog',
        'Kevin Kilo', 'Liam Legs', 'Mia Move', 'Noah Nimble', 'Olivia Out',
    ];

    for (let i = 0; i < names.length; i++) {
        const name = names[i];
        const email = `user${i}@test.com`;
        const phone = `+9198765${i.toString().padStart(5, '0')}`;
        const referralCount = Math.floor(Math.random() * 50);
        const referralCoinsEarned = referralCount * 100;

        // Upsert User
        const user = await prisma.user.upsert({
            where: { email },
            update: {
                name,
                phone,
                avatarUrl: avatars[i % avatars.length],
                referralCount,
                referralCoinsEarned,
                dailyStepGoal: 10000,
                heightCm: 170 + Math.random() * 20,
                weightKg: 60 + Math.random() * 30,
                age: 20 + Math.floor(Math.random() * 20),
            },
            create: {
                name,
                email,
                phone,
                avatarUrl: avatars[i % avatars.length],
                referralCount,
                referralCoinsEarned,
                referralCode: `REF${i}${Date.now()}`,
                dailyStepGoal: 10000,
                heightCm: 170 + Math.random() * 20,
                weightKg: 60 + Math.random() * 30,
                age: 20 + Math.floor(Math.random() * 20),
            }
        });

        // Upsert Steps for today
        const today = new Date();
        today.setHours(0, 0, 0, 0); // Normalize to start of day for unique constraint

        await prisma.step.upsert({
            where: {
                userId_date: {
                    userId: user.id,
                    date: today
                }
            },
            update: {
                stepCount: Math.floor(Math.random() * 15000),
                caloriesBurned: Math.floor(Math.random() * 500),
                distanceKm: Math.random() * 10,
            },
            create: {
                userId: user.id,
                date: today,
                stepCount: Math.floor(Math.random() * 15000),
                caloriesBurned: Math.floor(Math.random() * 500),
                distanceKm: Math.random() * 10,
            }
        });

        console.log(`Processed user: ${name}`);
    }

    console.log('✅ Seeding Complete');
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
