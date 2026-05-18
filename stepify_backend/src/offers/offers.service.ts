import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';


@Injectable()
export class OffersService {
    constructor(private prisma: PrismaService) { }

    // Get all active offers
    async findAllActive() {
        return this.prisma.offer.findMany({
            where: { isActive: true },
            orderBy: { createdAt: 'desc' },
        });
    }

    // Get user's offer history (My Offers - Screen 17)
    async getUserOffers(userId: string, status?: string) {
        return this.prisma.userOffer.findMany({
            where: {
                userId,
                ...(status && { status: status as any }),
            },
            include: { offer: true },
            orderBy: { startedAt: 'desc' },
        });
    }

    // Start an offer (user clicks on it)
    async startOffer(userId: string, offerId: string) {
        return this.prisma.userOffer.upsert({
            where: { userId_offerId: { userId, offerId } },
            create: { userId, offerId, status: 'STARTED' },
            update: {}, // No update if already exists
            include: { offer: true },
        });
    }

    // Complete an offer and reward user
    async completeOffer(userId: string, offerId: string) {
        const userOffer = await this.prisma.userOffer.findUnique({
            where: { userId_offerId: { userId, offerId } },
            include: { offer: true },
        });

        if (!userOffer || userOffer.status !== 'STARTED') {
            throw new Error('Offer not found or already completed');
        }

        // Update offer status
        await this.prisma.userOffer.update({
            where: { id: userOffer.id },
            data: { status: 'REWARDED', completedAt: new Date() },
        });

        // Credit wallet
        const rewardCoins = userOffer.offer.rewardCoins;
        await this.prisma.wallet.upsert({
            where: { userId },
            create: { userId, balance: rewardCoins, lifetimePoints: rewardCoins },
            update: {
                balance: { increment: rewardCoins },
                lifetimePoints: { increment: rewardCoins },
            },
        });

        // Create transaction
        await this.prisma.transaction.create({
            data: {
                userId,
                type: 'OFFER_REWARD' as any,
                points: rewardCoins,
                description: `Completed offer: ${userOffer.offer.title}`,
                metadata: { offerId },
            },
        });

        return { rewarded: rewardCoins };
    }

    // Create a new offer (admin)
    async createOffer(data: {
        title: string;
        description: string;
        providerName: string;
        rewardCoins: number;
        offerType?: string;
        imageUrl?: string;
        actionUrl?: string;
        expiryDate?: Date;
    }) {
        return this.prisma.offer.create({ data: data as any });
    }
}
