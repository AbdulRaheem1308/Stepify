import { Request, Response, NextFunction } from "express";
import { prisma } from "../config/database";

export const getUsers = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { search } = req.query;
    let whereClause = {};

    if (search) {
      whereClause = {
        OR: [
          { name: { contains: search as string, mode: "insensitive" } },
          { email: { contains: search as string, mode: "insensitive" } },
          { phone: { contains: search as string, mode: "insensitive" } }
        ]
      };
    }

    const users = await prisma.user.findMany({
      where: whereClause,
      include: {
        streak: true,
        wallet: true,
        _count: {
          select: { steps: true, userChallenges: true, userAchievements: true }
        }
      },
      orderBy: { createdAt: "desc" }
    });

    res.json({ success: true, data: users });
  } catch (error) {
    next(error);
  }
};

export const getUserById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.params.id },
      include: {
        streak: true,
        wallet: true,
        steps: { take: 10, orderBy: { date: "desc" } },
        transactions: { take: 15, orderBy: { createdAt: "desc" } },
        userChallenges: { include: { challenge: true } },
        userAchievements: { include: { achievement: true } }
      }
    });

    if (!user) {
      return res.status(404).json({ success: false, message: "User profile not found." });
    }

    res.json({ success: true, data: user });
  } catch (error) {
    next(error);
  }
};

export const toggleUserStatus = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await prisma.user.findUnique({ where: { id: req.params.id } });
    if (!user) {
      return res.status(404).json({ success: false, message: "User profile not found." });
    }

    const updatedUser = await prisma.user.update({
      where: { id: req.params.id },
      data: { isActive: !user.isActive }
    });

    res.json({
      success: true,
      data: updatedUser,
      message: `User compliance profile successfully ${updatedUser.isActive ? "activated" : "deactivated"}.`
    });
  } catch (error) {
    next(error);
  }
};
