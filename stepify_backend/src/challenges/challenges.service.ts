import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateChallengeDto, JoinChallengeDto, ChallengeStatus } from './dto/challenge.dto';

@Injectable()
export class ChallengesService {
    constructor(private prisma: PrismaService) { }

    /**
     * Get all available challenges (active and not expired)
     */
    async findAll() {
        return this.prisma.challenge.findMany({
            where: {
                isActive: true,
                OR: [
                    { endsAt: null },
                    { endsAt: { gte: new Date() } },
                ],
            },
            orderBy: { createdAt: 'desc' },
        });
    }

    /**
     * Get challenges for a specific user with their status
     */
    async findUserChallenges(userId: string, status?: ChallengeStatus) {
        const where: any = { userId };
        if (status) {
            where.status = status;
        }

        return this.prisma.userChallenge.findMany({
            where,
            include: {
                challenge: true,
            },
            orderBy: { joinedAt: 'desc' },
        });
    }

    /**
     * Get a single challenge by ID
     */
    async findOne(id: string) {
        const challenge = await this.prisma.challenge.findUnique({
            where: { id },
            include: {
                _count: {
                    select: { userChallenges: true },
                },
            },
        });

        if (!challenge) {
            throw new NotFoundException('Challenge not found');
        }

        return challenge;
    }

    /**
     * Create a new challenge (admin only)
     */
    async create(dto: CreateChallengeDto) {
        return this.prisma.challenge.create({
            data: {
                title: dto.title,
                description: dto.description,
                stepTarget: dto.stepTarget,
                rewardCoins: dto.rewardCoins || 0,
                rewardXp: dto.rewardXp || 0,
                durationDays: dto.durationDays,
                challengeType: dto.challengeType as any,
                difficulty: dto.difficulty as any,
                imageUrl: dto.imageUrl,
                isInviteOnly: dto.isInviteOnly || false,
                maxParticipants: dto.maxParticipants,
                startsAt: dto.startsAt ? new Date(dto.startsAt) : null,
                endsAt: dto.endsAt ? new Date(dto.endsAt) : null,
            },
        });
    }

    /**
     * Join a challenge
     */
    async join(userId: string, challengeId: string) {
        // Check if challenge exists and is active
        const challenge = await this.prisma.challenge.findUnique({
            where: { id: challengeId },
            include: {
                _count: {
                    select: { userChallenges: true },
                },
            },
        });

        if (!challenge) {
            throw new NotFoundException('Challenge not found');
        }

        if (!challenge.isActive) {
            throw new BadRequestException('Challenge is no longer active');
        }

        // Check if already joined
        const existing = await this.prisma.userChallenge.findUnique({
            where: {
                userId_challengeId: {
                    userId,
                    challengeId,
                },
            },
        });

        if (existing) {
            throw new ConflictException('Already joined this challenge');
        }

        // Check max participants
        if (challenge.maxParticipants && challenge._count.userChallenges >= challenge.maxParticipants) {
            throw new BadRequestException('Challenge is full');
        }

        // Create user challenge entry
        return this.prisma.userChallenge.create({
            data: {
                userId,
                challengeId,
                status: 'ONGOING',
                currentSteps: 0,
                progress: 0,
            },
            include: {
                challenge: true,
            },
        });
    }

    /**
     * Update challenge progress based on user steps
     */
    async updateProgress(userId: string, challengeId: string, stepsToAdd: number) {
        const userChallenge = await this.prisma.userChallenge.findUnique({
            where: {
                userId_challengeId: {
                    userId,
                    challengeId,
                },
            },
            include: {
                challenge: true,
            },
        });

        if (!userChallenge) {
            throw new NotFoundException('User challenge not found');
        }

        if (userChallenge.status !== 'ONGOING') {
            throw new BadRequestException('Challenge is not ongoing');
        }

        const newSteps = userChallenge.currentSteps + stepsToAdd;
        const progress = Math.min(100, Math.floor((newSteps / userChallenge.challenge.stepTarget) * 100));
        const isCompleted = newSteps >= userChallenge.challenge.stepTarget;

        const updated = await this.prisma.userChallenge.update({
            where: {
                userId_challengeId: {
                    userId,
                    challengeId,
                },
            },
            data: {
                currentSteps: newSteps,
                progress,
                status: isCompleted ? 'COMPLETED' : 'ONGOING',
                completedAt: isCompleted ? new Date() : null,
            },
            include: {
                challenge: true,
            },
        });

        // If completed, award coins and XP (we know it wasn't completed before since we checked status === ONGOING above)
        if (isCompleted) {
            await this.awardRewards(userId, userChallenge.challenge.rewardCoins, userChallenge.challenge.rewardXp);
        }

        return updated;
    }

    /**
     * Award coins and XP for completing a challenge
     */
    private async awardRewards(userId: string, coins: number, xp: number) {
        if (coins > 0) {
            await this.prisma.wallet.update({
                where: { userId },
                data: {
                    balance: { increment: coins },
                    lifetimePoints: { increment: coins },
                },
            });

            await this.prisma.transaction.create({
                data: {
                    userId,
                    type: 'MILESTONE',
                    points: coins,
                    description: 'Challenge completion reward',
                },
            });
        }
    }

    /**
     * Get new challenges (not joined by user)
     */
    async findNewChallenges(userId: string) {
        const joinedChallengeIds = await this.prisma.userChallenge.findMany({
            where: { userId },
            select: { challengeId: true },
        });

        const joinedIds = joinedChallengeIds.map((uc: { challengeId: string }) => uc.challengeId);

        return this.prisma.challenge.findMany({
            where: {
                isActive: true,
                id: { notIn: joinedIds },
                OR: [
                    { endsAt: null },
                    { endsAt: { gte: new Date() } },
                ],
            },
            orderBy: { createdAt: 'desc' },
        });
    }

    /**
     * Seed demo challenges
     */
    async seedDemoChallenges() {
        const challenges = [
            {
                title: '10K Daily Steps',
                description: 'Walk 10,000 steps every day for a week',
                stepTarget: 70000,
                rewardCoins: 500,
                rewardXp: 200,
                durationDays: 7,
                challengeType: 'SOLO' as any,
                difficulty: 'MEDIUM' as any,
            },
            {
                title: 'Weekend Warrior',
                description: 'Complete 20,000 steps over the weekend',
                stepTarget: 20000,
                rewardCoins: 200,
                rewardXp: 100,
                durationDays: 2,
                challengeType: 'SOLO' as any,
                difficulty: 'EASY' as any,
            },
            {
                title: 'Marathon Month',
                description: 'Walk the equivalent of a marathon (42km) in a month',
                stepTarget: 55000,
                rewardCoins: 1000,
                rewardXp: 500,
                durationDays: 30,
                challengeType: 'SOLO' as any,
                difficulty: 'HARD' as any,
            },
            {
                title: 'Team Trek',
                description: 'Join forces with others to complete 100K steps collectively',
                stepTarget: 100000,
                rewardCoins: 750,
                rewardXp: 350,
                durationDays: 7,
                challengeType: 'GROUP' as any,
                difficulty: 'MEDIUM' as any,
            },
        ];

        for (const challenge of challenges) {
            await this.prisma.challenge.upsert({
                where: { id: challenge.title.replace(/\s/g, '-').toLowerCase() },
                update: {},
                create: challenge,
            });
        }

        return { message: 'Demo challenges seeded' };
    }
}
