// backend/src/routes/doctor.routes.js
import express from "express";
import pool from "../config/db.js";
import User from "../models/User.js";
import { requireAuth, requireRole } from "../middleware/auth.js";

const router = express.Router();

// ✅ GET /api/doctor/profile
router.get("/profile", requireAuth, requireRole("doctor"), async (req, res) => {
  try {
    const id = Number(req.user.id);
    const user = await User.findById(id);
    if (!user) return res.status(404).json({ message: "Doctor not found" });

    return res.json({
      id: user.id,
      role: user.role,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      specialty: user.specialty,
      clinicAddress: user.clinicAddress,
      consultationPrice: user.consultationPrice,
      doctorPhoto: user.doctorPhoto,
      isVerifiedDoctor: Number(user.isVerifiedDoctor),
    });
  } catch (e) {
    console.error("doctor profile GET error:", e);
    return res.status(500).json({ message: "Server error" });
  }
});

// ✅ PUT /api/doctor/profile
router.put("/profile", requireAuth, requireRole("doctor"), async (req, res) => {
  try {
    const id = Number(req.user.id);

    const fields = {
      fullName: req.body.fullName,
      email: req.body.email,
      phone: req.body.phone,
      specialty: req.body.specialty,
      clinicAddress: req.body.clinicAddress,
      consultationPrice: Number(req.body.consultationPrice ?? 0),
    };

    // ✅ remove undefined
    Object.keys(fields).forEach(
      (k) => fields[k] === undefined && delete fields[k],
    );

    const ok = await User.update(id, fields);
    if (!ok) return res.status(404).json({ message: "Doctor not found" });

    return res.json({ message: "Profile updated" });
  } catch (e) {
    console.error("doctor profile PUT error:", e);
    return res.status(500).json({ message: "Server error" });
  }
});

// ✅ GET /api/doctor/appointments  (all doctor appointments)
router.get(
  "/appointments",
  requireAuth,
  requireRole("doctor"),
  async (req, res) => {
    try {
      const doctorId = Number(req.user.id);

      const [rows] = await pool.execute(
        `
        SELECT 
          a.id,
          a.patientId,
          a.doctorId,
          a.appointmentDate,
          a.status,
          a.note,
          u.fullName AS patientName
        FROM appointments a
        JOIN users u ON u.id = a.patientId
        WHERE a.doctorId = ?
        ORDER BY a.appointmentDate DESC
        `,
        [doctorId],
      );

      return res.json(rows);
    } catch (e) {
      console.error("doctor appointments GET error:", e);
      return res.status(500).json({ message: "Server error" });
    }
  },
);

// ✅ PUT /api/doctor/appointments/:id  { status }
router.put(
  "/appointments/:id",
  requireAuth,
  requireRole("doctor"),
  async (req, res) => {
    try {
      const doctorId = Number(req.user.id);
      const appointmentId = Number(req.params.id);
      const status = String(req.body.status || "").toLowerCase();

      // ✅ must match DB enum: pending / accepted / rejected
      const allowed = ["pending", "accepted", "rejected"];
      if (!allowed.includes(status)) {
        return res.status(400).json({ message: "Invalid status" });
      }

      const [result] = await pool.execute(
        `UPDATE appointments SET status = ? WHERE id = ? AND doctorId = ?`,
        [status, appointmentId, doctorId],
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: "Appointment not found" });
      }

      return res.json({ message: "Appointment updated" });
    } catch (e) {
      console.error("doctor appointments PUT error:", e);
      return res.status(500).json({ message: "Server error" });
    }
  },
);

export default router;
