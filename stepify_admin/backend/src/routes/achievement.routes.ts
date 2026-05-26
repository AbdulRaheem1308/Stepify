import { Router } from "express";
import { getAchievements, createAchievement, updateAchievement, deleteAchievement } from "../controllers/achievement.controller";

const router = Router();

router.get("/", getAchievements);
router.post("/", createAchievement);
router.put("/:id", updateAchievement);
router.delete("/:id", deleteAchievement);

export default router;
