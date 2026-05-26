import { Router } from "express";
import analyticsRouter from "./analytics.routes";
import userRouter from "./user.routes";
import challengeRouter from "./challenge.routes";
import achievementRouter from "./achievement.routes";
import rewardRouter from "./reward.routes";
import questRouter from "./quest.routes";
import socialRouter from "./social.routes";
import teamRouter from "./team.routes";
import offerRouter from "./offer.routes";
import economyRouter from "./economy.routes";
import activityRouter from "./activity.routes";
import corporateRouter from "./corporate.routes";
import messagingRouter from "./messaging.routes";
import { deleteQuestStage } from "../controllers/quest.controller";

const router = Router();

// Mount sub-routers
router.use("/analytics", analyticsRouter);
router.use("/users", userRouter);
router.use("/challenges", challengeRouter);
router.use("/achievements", achievementRouter);
router.use("/rewards", rewardRouter);
router.use("/quests", questRouter);
router.use("/social", socialRouter);
router.use("/teams", teamRouter);
router.use("/offers", offerRouter);
router.use("/economy", economyRouter);
router.use("/activities", activityRouter);
router.use("/corporate", corporateRouter);
router.use("/messaging", messagingRouter);

// Stage deletion route mount (for backward compatibility / convenience in frontend paths)
router.delete("/stages/:stageId", deleteQuestStage);

export default router;
