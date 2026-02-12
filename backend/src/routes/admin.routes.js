// backend/src/routes/admin.routes.js
import express from "express";
import User from "../models/User.js";
import { requireAuth, requireRole } from "../middleware/auth.js";

const router = express.Router();

// ✅ list pending doctors
router.get(
  "/pending-doctors",
  requireAuth,
  requireRole("admin"),
  async (req, res) => {
    try {
      // Récupère tous les doctors
      const docs = await User.findAll({ role: "doctor" });

      // ✅ Fix: MySQL peut renvoyer 0, 1, "0", "1"
      const pending = docs.filter((d) => Number(d.isVerifiedDoctor) === 0);

      res.json(
        pending.map((d) => ({
          id: d.id,
          fullName: d.fullName,
          email: d.email,
          phone: d.phone,
          specialty: d.specialty,
          clinicAddress: d.clinicAddress,
          consultationPrice: d.consultationPrice,
          doctorPhoto: d.doctorPhoto,
          isVerifiedDoctor: Number(d.isVerifiedDoctor),
        })),
      );
    } catch (e) {
      console.error("pending-doctors error:", e);
      res.status(500).json({ message: "Server error" });
    }
  },
);

// ✅ verify doctor
router.patch(
  "/doctors/:id/verify",
  requireAuth,
  requireRole("admin"),
  async (req, res) => {
    try {
      const id = Number(req.params.id);
      const ok = await User.update(id, { isVerifiedDoctor: 1 });
      if (!ok) return res.status(404).json({ message: "Doctor not found" });

      res.json({ message: "Doctor verified" });
    } catch (e) {
      console.error("verify error:", e);
      res.status(500).json({ message: "Server error" });
    }
  },
);

// ✅ reject doctor
// IMPORTANT: ton Flutter utilise PATCH, donc on supporte PATCH ici
router.patch(
  "/doctors/:id/reject",
  requireAuth,
  requireRole("admin"),
  async (req, res) => {
    try {
      const id = Number(req.params.id);

      // Option 1: supprimer le compte
      const ok = await User.delete(id);
      if (!ok) return res.status(404).json({ message: "Doctor not found" });

      res.json({ message: "Doctor rejected (deleted)" });
    } catch (e) {
      console.error("reject error:", e);
      res.status(500).json({ message: "Server error" });
    }
  },
);

export default router;
