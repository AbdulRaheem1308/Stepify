import { Request, Response, NextFunction } from "express";
import { prisma } from "../config/database";

export const getTransactions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const transactions = await prisma.transaction.findMany({
      include: { user: { select: { name: true, email: true } } },
      orderBy: { createdAt: "desc" },
      take: 100
    });
    res.json({ success: true, data: transactions });
  } catch (error) {
    next(error);
  }
};

export const getAppConfigs = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const configs = await prisma.appConfig.findMany();
    res.json({ success: true, data: configs });
  } catch (error) {
    next(error);
  }
};

export const setAppConfig = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { key, value } = req.body;
    const config = await prisma.appConfig.upsert({
      where: { key },
      update: { value },
      create: { key, value }
    });
    res.json({ success: true, data: config });
  } catch (error) {
    next(error);
  }
};
