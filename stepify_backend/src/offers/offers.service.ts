import { Injectable } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { CreateOfferDto } from "./dto/offer.dto";

@Injectable()
export class OffersService {
  constructor(private prisma: PrismaService) {}

  // Get all active offers
  async findAllActive() {
    return this.prisma.offer.findMany({
      where: { isActive: true },
      orderBy: { createdAt: "desc" },
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
      orderBy: { startedAt: "desc" },
    });
  }

  // Start an offer (user clicks on it)
  async startOffer(userId: string, offerId: string) {
    return this.prisma.userOffer.upsert({
      where: { userId_offerId: { userId, offerId } },
      create: { userId, offerId, status: "STARTED" },
      update: {}, // No update if already exists
      include: { offer: true },
    });
  }

  // Complete an offer and reward user
  async completeOffer(userId: string, offerId: string) {
    return this.prisma.$transaction(async (tx) => {
      const userOffer = await tx.userOffer.findUnique({
        where: { userId_offerId: { userId, offerId } },
        include: { offer: true },
      });

      if (!userOffer || userOffer.status !== "STARTED") {
        throw new Error("Offer not found or already completed");
      }

      // Update offer status
      await tx.userOffer.update({
        where: { id: userOffer.id },
        data: { status: "REWARDED", completedAt: new Date() },
      });

      // Credit wallet
      const rewardCoins = userOffer.offer.rewardCoins;
      await tx.wallet.upsert({
        where: { userId },
        create: {
          userId,
          balance: rewardCoins,
          lifetimePoints: rewardCoins,
          lastResetDate: new Date(),
        },
        update: {
          balance: { increment: rewardCoins },
          lifetimePoints: { increment: rewardCoins },
        },
      });

      // Create transaction
      await tx.transaction.create({
        data: {
          userId,
          type: "OFFER_REWARD",
          points: rewardCoins,
          description: `Completed offer: ${userOffer.offer.title}`,
          metadata: { offerId },
        },
      });

      return { rewarded: rewardCoins };
    });
  }

  // Create a new offer (admin)
  async createOffer(data: CreateOfferDto) {
    return this.prisma.offer.create({ data });
  }
}
