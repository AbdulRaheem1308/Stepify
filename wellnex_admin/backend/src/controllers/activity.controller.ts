import { Request, Response, NextFunction } from "express";
import { prisma } from "../config/database";

export const getActivities = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const activities = await prisma.activity.findMany({
      include: { user: { select: { name: true, email: true } } },
      orderBy: { startTime: "desc" },
      take: 100
    });
    res.json({ success: true, data: activities });
  } catch (error) {
    next(error);
  }
};

export const getSteps = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const steps = await prisma.step.findMany({
      include: { user: { select: { name: true, email: true } } },
      orderBy: { date: "desc" },
      take: 100
    });
    res.json({ success: true, data: steps });
  } catch (error) {
    next(error);
  }
};

export const deleteActivity = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await prisma.activity.delete({ where: { id: req.params.id } });
    res.json({ success: true, message: "Activity flagged and removed." });
  } catch (error) {
    next(error);
  }
};
