import { Router } from "express";
import { getActivities, getSteps, deleteActivity } from "../controllers/activity.controller";

const router = Router();

router.get("/", getActivities);
router.get("/steps", getSteps);
router.delete("/:id", deleteActivity);

export default router;
