import { Router } from "express";
import { getFeedPosts, deleteFeedPost, getInvitations, createFeedPost } from "../controllers/social.controller";

const router = Router();

router.get("/feed", getFeedPosts);
router.post("/feed", createFeedPost);
router.delete("/feed/:id", deleteFeedPost);
router.get("/invitations", getInvitations);

export default router;
