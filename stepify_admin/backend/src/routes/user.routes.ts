import { Router } from "express";
import { getUsers, getUserById, toggleUserStatus } from "../controllers/user.controller";

const router = Router();

router.get("/", getUsers);
router.get("/:id", getUserById);
router.put("/:id/toggle-status", toggleUserStatus);

export default router;
