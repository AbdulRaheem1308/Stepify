import { Request, Response, NextFunction } from "express";
import { prisma } from "../config/database";
import { OfferType } from "@prisma/client";

export const getOffers = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const offers = await prisma.offer.findMany({
      orderBy: { createdAt: "desc" }
    });
    res.json({ success: true, data: offers });
  } catch (error) {
    next(error);
  }
};

export const createOffer = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { title, description, providerName, rewardCoins, offerType } = req.body;
    const offer = await prisma.offer.create({
      data: {
        title,
        description,
        providerName,
        rewardCoins: Number(rewardCoins),
        offerType: offerType as OfferType
      }
    });
    res.status(201).json({ success: true, data: offer });
  } catch (error) {
    next(error);
  }
};

export const toggleOfferStatus = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const offer = await prisma.offer.findUnique({ where: { id: req.params.id } });
    if (!offer) return res.status(404).json({ success: false, message: "Not found" });

    const updated = await prisma.offer.update({
      where: { id: req.params.id },
      data: { isActive: !offer.isActive }
    });
    res.json({ success: true, data: updated });
  } catch (error) {
    next(error);
  }
};

export const getAdViews = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const adViews = await prisma.adView.findMany({
      include: { user: { select: { name: true, email: true } } },
      orderBy: { completedAt: "desc" },
      take: 100
    });
    res.json({ success: true, data: adViews });
  } catch (error) {
    next(error);
  }
};
