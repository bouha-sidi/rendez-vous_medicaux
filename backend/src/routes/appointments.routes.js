import express from "express";
import auth from "../middleware/auth.js";
import { createAppointment } from "../controllers/appointments.controller.js";

const router = express.Router();

router.post("/", auth, createAppointment);

export default router;