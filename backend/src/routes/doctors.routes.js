import express from "express";
import { getDoctors } from "../controllers/doctors.controller.js";
import auth from "../middleware/auth.js";

const router = express.Router();

// Accessible uniquement aux utilisateurs connectés
router.get("/", auth, getDoctors);

export default router;
