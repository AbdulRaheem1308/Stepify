import { Request, Response, NextFunction } from "express";
import { prisma } from "../config/database";

export const getCompanies = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const companies = await prisma.company.findMany({
      include: {
        _count: {
          select: { members: true, departments: true, challenges: true }
        }
      },
      orderBy: { createdAt: "desc" }
    });
    res.json({ success: true, data: companies });
  } catch (error) {
    next(error);
  }
};

export const createCompany = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { name, domain } = req.body;
    // Generate a random 8-character invite code
    const inviteCode = Math.random().toString(36).substring(2, 10).toUpperCase();
    const company = await prisma.company.create({
      data: { name, domain, inviteCode }
    });
    res.status(201).json({ success: true, data: company });
  } catch (error) {
    next(error);
  }
};

export const deleteCompany = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await prisma.company.delete({ where: { id: req.params.id } });
    res.json({ success: true, message: "Company profile deleted." });
  } catch (error) {
    next(error);
  }
};
