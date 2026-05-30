import { Router } from "express";
import { getChallenges, createChallenge, updateChallenge, deleteChallenge } from "../controllers/challenge.controller";

const router = Router();

router.get("/", getChallenges);
router.post("/", createChallenge);
router.put("/:id", updateChallenge);
router.delete("/:id", deleteChallenge);

export default router;
