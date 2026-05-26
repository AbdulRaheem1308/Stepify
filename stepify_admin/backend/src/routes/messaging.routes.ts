import { Router } from "express";
import { getConversations, deleteConversation } from "../controllers/messaging.controller";

const router = Router();

router.get("/", getConversations);
router.delete("/:id", deleteConversation);

export default router;
