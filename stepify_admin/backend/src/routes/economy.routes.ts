import { Router } from "express";
import { getTransactions, getAppConfigs, setAppConfig } from "../controllers/economy.controller";

const router = Router();

router.get("/transactions", getTransactions);
router.get("/config", getAppConfigs);
router.post("/config", setAppConfig);

export default router;
