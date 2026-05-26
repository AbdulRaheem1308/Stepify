import { Request, Response, NextFunction } from "express";
import { prisma } from "../config/database";

export const getAchievements = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const achievements = await prisma.achievement.findMany({
      orderBy: { createdAt: "desc" }
    });
    res.json({ success: true, data: achievements });
  } catch (error) {
    next(error);
  }
};

export const createAchievement = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { code, name, description, icon, category, pointsReward, stepsRequired, streakRequired, targetValue, isActive } = req.body;
    const achievement = await prisma.achievement.create({
      data: {
        code, name, description, icon, category,
        pointsReward: Number(pointsReward || 0),
        stepsRequired: stepsRequired ? Number(stepsRequired) : null,
        streakRequired: streakRequired ? Number(streakRequired) : null,
        targetValue: targetValue ? Number(targetValue) : null,
        isActive: Boolean(isActive)
      }
    });
    res.status(201).json({ success: true, data: achievement });
  } catch (error) {
    next(error);
  }
};

export const updateAchievement = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { code, name, description, icon, category, pointsReward, stepsRequired, streakRequired, targetValue, isActive } = req.body;
    const achievement = await prisma.achievement.update({
      where: { id: req.params.id },
      data: {
        code, name, description, icon, category,
        pointsReward: Number(pointsReward || 0),
        stepsRequired: stepsRequired ? Number(stepsRequired) : null,
        streakRequired: streakRequired ? Number(streakRequired) : null,
        targetValue: targetValue ? Number(targetValue) : null,
        isActive: Boolean(isActive)
      }
    });
    res.json({ success: true, data: achievement });
  } catch (error) {
    next(error);
  }
};

export const deleteAchievement = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await prisma.achievement.delete({ where: { id: req.params.id } });
    res.json({ success: true, message: "Achievement badge configuration deleted." });
  } catch (error) {
    next(error);
  }
};
