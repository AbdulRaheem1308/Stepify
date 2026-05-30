import { Request, Response, NextFunction } from "express";
import { prisma } from "../config/database";

export const getQuests = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const quests = await prisma.quest.findMany({
      include: { stages: true },
      orderBy: { createdAt: "desc" }
    });
    res.json({ success: true, data: quests });
  } catch (error) {
    next(error);
  }
};

export const createQuest = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { title, description, imageUrl, difficulty, rewardXp, rewardCoins, isActive } = req.body;
    const quest = await prisma.quest.create({
      data: {
        title, description, imageUrl, difficulty,
        rewardXp: Number(rewardXp),
        rewardCoins: Number(rewardCoins),
        isActive: Boolean(isActive)
      }
    });
    res.status(201).json({ success: true, data: quest });
  } catch (error) {
    next(error);
  }
};

export const updateQuest = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { title, description, imageUrl, difficulty, rewardXp, rewardCoins, isActive } = req.body;
    const quest = await prisma.quest.update({
      where: { id: req.params.id },
      data: {
        title, description, imageUrl, difficulty,
        rewardXp: Number(rewardXp),
        rewardCoins: Number(rewardCoins),
        isActive: Boolean(isActive)
      }
    });
    res.json({ success: true, data: quest });
  } catch (error) {
    next(error);
  }
};

export const deleteQuest = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await prisma.quest.delete({ where: { id: req.params.id } });
    res.json({ success: true, message: "Quest chain deleted successfully." });
  } catch (error) {
    next(error);
  }
};

export const createQuestStage = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { order, title, description, targetSteps } = req.body;
    const stage = await prisma.questStage.create({
      data: {
        questId: req.params.questId,
        order: Number(order),
        title, description,
        targetSteps: Number(targetSteps)
      }
    });
    res.status(201).json({ success: true, data: stage });
  } catch (error) {
    next(error);
  }
};

export const deleteQuestStage = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await prisma.questStage.delete({ where: { id: req.params.stageId } });
    res.json({ success: true, message: "Quest stage deleted successfully." });
  } catch (error) {
    next(error);
  }
};
