import { Router } from "express";
import { getOffers, createOffer, toggleOfferStatus, getAdViews } from "../controllers/offer.controller";

const router = Router();

router.get("/", getOffers);
router.post("/", createOffer);
router.patch("/:id/toggle", toggleOfferStatus);
router.get("/ad-views", getAdViews);

export default router;
