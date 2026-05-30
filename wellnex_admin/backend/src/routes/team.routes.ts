import { Router } from "express";
import { getTeams, deleteTeam, getTeamBattles, createTeam } from "../controllers/team.controller";

const router = Router();

router.get("/", getTeams);
router.post("/", createTeam);
router.delete("/:id", deleteTeam);
router.get("/battles", getTeamBattles);

export default router;
