import express from "express";
import auth from "../middleware/auth.js";
import roles from "../middleware/roles.js";
import {
  getMyAppointments,
  cancelAppointment,
  confirmAppointment
} from "../controllers/patientAppointments.controller.js";
import {
  getProfile,
  updateProfile,
  uploadProfilePhoto,
  getPatientHistory
} from "../controllers/patient.controller.js";
import { uploadProfilePhoto as upload } from "../middleware/upload.js";

const router = express.Router();

// Routes pour le patient connecté
router.get("/me", auth, getProfile);
router.put("/me", auth, updateProfile);
router.put("/me/photo", auth, upload, uploadProfilePhoto);
router.get("/history", auth, getPatientHistory); // Nouveau

// Rendez-vous
router.get("/appointments", auth, getMyAppointments);
router.put("/appointments/:id/cancel", auth, cancelAppointment);
router.put("/appointments/:id/confirm", auth, roles("doctor", "admin"), confirmAppointment); // Nouveau

export default router;