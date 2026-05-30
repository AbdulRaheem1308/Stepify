import { Router } from "express";
import { getSummary, getInteractions } from "../controllers/analytics.controller";

const router = Router();

router.get("/summary", getSummary);
router.get("/interactions", getInteractions);

export default router;
