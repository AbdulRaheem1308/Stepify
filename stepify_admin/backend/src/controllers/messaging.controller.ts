import { Request, Response, NextFunction } from "express";
import { prisma } from "../config/database";

export const getConversations = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const conversations = await prisma.conversation.findMany({
      include: {
        participants: { include: { user: { select: { name: true, email: true } } } },
        _count: { select: { messages: true } }
      },
      orderBy: { updatedAt: "desc" },
      take: 50
    });
    res.json({ success: true, data: conversations });
  } catch (error) {
    next(error);
  }
};

export const deleteConversation = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await prisma.conversation.delete({ where: { id: req.params.id } });
    res.json({ success: true, message: "Conversation forcibly wiped for compliance." });
  } catch (error) {
    next(error);
  }
};
