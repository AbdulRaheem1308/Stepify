import { Router } from "express";
import { 
  getQuests, createQuest, updateQuest, deleteQuest, createQuestStage, deleteQuestStage 
} from "../controllers/quest.controller";

const router = Router();

router.get("/", getQuests);
router.post("/", createQuest);
router.put("/:id", updateQuest);
router.delete("/:id", deleteQuest);

// Quest Stage CRUD
router.post("/:questId/stages", createQuestStage);
router.delete("/stages/:stageId", deleteQuestStage);

export default router;
