import { Request, Response, NextFunction } from "express";
import { prisma } from "../config/database";

export const getRewards = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const rewards = await prisma.reward.findMany({
      orderBy: { createdAt: "desc" }
    });
    res.json({ success: true, data: rewards });
  } catch (error) {
    next(error);
  }
};

export const createReward = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { title, description, coinCost, category, imageUrl, partnerName, partnerLogoUrl, availableStock, totalStock, termsConditions, isActive } = req.body;
    const reward = await prisma.reward.create({
      data: {
        title, description, category, imageUrl, partnerName, partnerLogoUrl, termsConditions,
        coinCost: Number(coinCost),
        availableStock: Number(availableStock || -1),
        totalStock: Number(totalStock || -1),
        isActive: Boolean(isActive)
      }
    });
    res.status(201).json({ success: true, data: reward });
  } catch (error) {
    next(error);
  }
};

export const updateReward = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { title, description, coinCost, category, imageUrl, partnerName, partnerLogoUrl, availableStock, totalStock, termsConditions, isActive } = req.body;
    const reward = await prisma.reward.update({
      where: { id: req.params.id },
      data: {
        title, description, category, imageUrl, partnerName, partnerLogoUrl, termsConditions,
        coinCost: Number(coinCost),
        availableStock: Number(availableStock || -1),
        totalStock: Number(totalStock || -1),
        isActive: Boolean(isActive)
      }
    });
    res.json({ success: true, data: reward });
  } catch (error) {
    next(error);
  }
};

export const deleteReward = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await prisma.reward.delete({ where: { id: req.params.id } });
    res.json({ success: true, message: "Partner catalog reward removed successfully." });
  } catch (error) {
    next(error);
  }
};
