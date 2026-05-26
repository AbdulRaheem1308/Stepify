import { Request, Response, NextFunction } from "express";

export const adminAuthGuard = (req: Request, res: Response, next: NextFunction) => {
  const apiKey = req.headers["x-admin-api-key"] as string;
  const validKey = process.env.ADMIN_API_KEY || "fallback-secret-admin-key-2026";

  if (!apiKey || apiKey !== validKey) {
    return res.status(401).json({ 
      success: false, 
      message: "Unauthorized. Missing or invalid Admin API Key." 
    });
  }
  next();
};
