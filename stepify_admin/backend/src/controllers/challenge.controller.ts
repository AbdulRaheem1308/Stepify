import { Request, Response, NextFunction } from "express";
import { prisma } from "../config/database";

export const getChallenges = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const challenges = await prisma.challenge.findMany({
      orderBy: { createdAt: "desc" }
    });
    res.json({ success: true, data: challenges });
  } catch (error) {
    next(error);
  }
};

export const createChallenge = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { title, description, stepTarget, rewardCoins, rewardXp, durationDays, challengeType, difficulty, imageUrl, isActive } = req.body;
    const challenge = await prisma.challenge.create({
      data: {
        title, description,
        stepTarget: Number(stepTarget),
        rewardCoins: Number(rewardCoins),
        rewardXp: Number(rewardXp),
        durationDays: Number(durationDays),
        challengeType, difficulty, imageUrl,
        isActive: Boolean(isActive)
      }
    });
    res.status(201).json({ success: true, data: challenge });
  } catch (error) {
    next(error);
  }
};

export const updateChallenge = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { title, description, stepTarget, rewardCoins, rewardXp, durationDays, challengeType, difficulty, imageUrl, isActive } = req.body;
    const challenge = await prisma.challenge.update({
      where: { id: req.params.id },
      data: {
        title, description,
        stepTarget: Number(stepTarget),
        rewardCoins: Number(rewardCoins),
        rewardXp: Number(rewardXp),
        durationDays: Number(durationDays),
        challengeType, difficulty, imageUrl,
        isActive: Boolean(isActive)
      }
    });
    res.json({ success: true, data: challenge });
  } catch (error) {
    next(error);
  }
};

export const deleteChallenge = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await prisma.challenge.delete({ where: { id: req.params.id } });
    res.json({ success: true, message: "Campaign challenge deleted successfully." });
  } catch (error) {
    next(error);
  }
};
