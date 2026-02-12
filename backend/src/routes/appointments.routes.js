// backend/src/routes/appointments.routes.js
import express from "express";
import pool from "../config/db.js";
import { requireAuth, requireRole } from "../middleware/auth.js";

const router = express.Router();

// ✅ Patient: créer demande de réservation
router.post("/", requireAuth, requireRole("patient"), async (req, res) => {
  try {
    const patientId = Number(req.user.id);
    const { doctorId, appointmentDate, note } = req.body;

    if (!doctorId || !appointmentDate) {
      return res
        .status(400)
        .json({ message: "doctorId and appointmentDate required" });
    }

    await pool.execute(
      `INSERT INTO appointments (patientId, doctorId, appointmentDate, status, note)
       VALUES (?, ?, ?, 'pending', ?)`,
      [patientId, Number(doctorId), appointmentDate, note || null],
    );

    res.status(201).json({ message: "Appointment request created (pending)" });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Server error" });
  }
});

// ✅ Patient: voir ses demandes
router.get("/me", requireAuth, requireRole("patient"), async (req, res) => {
  try {
    const patientId = Number(req.user.id);
    const [rows] = await pool.execute(
      `SELECT a.*, u.fullName AS doctorName, u.specialty
       FROM appointments a
       JOIN users u ON u.id = a.doctorId
       WHERE a.patientId = ?
       ORDER BY a.createdAt DESC`,
      [patientId],
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Server error" });
  }
});

// ✅ Doctor: voir les demandes reçues
router.get("/doctor", requireAuth, requireRole("doctor"), async (req, res) => {
  try {
    const doctorId = Number(req.user.id);
    const [rows] = await pool.execute(
      `SELECT a.*, u.fullName AS patientName, u.phone AS patientPhone
       FROM appointments a
       JOIN users u ON u.id = a.patientId
       WHERE a.doctorId = ?
       ORDER BY a.createdAt DESC`,
      [doctorId],
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Server error" });
  }
});

// ✅ Doctor: accepter
router.patch(
  "/:id/accept",
  requireAuth,
  requireRole("doctor"),
  async (req, res) => {
    try {
      const doctorId = Number(req.user.id);
      const id = Number(req.params.id);

      const [result] = await pool.execute(
        `UPDATE appointments SET status='accepted'
       WHERE id=? AND doctorId=?`,
        [id, doctorId],
      );

      if (result.affectedRows === 0)
        return res.status(404).json({ message: "Not found" });
      res.json({ message: "Accepted" });
    } catch (e) {
      console.error(e);
      res.status(500).json({ message: "Server error" });
    }
  },
);

// ✅ Doctor: refuser
router.patch(
  "/:id/reject",
  requireAuth,
  requireRole("doctor"),
  async (req, res) => {
    try {
      const doctorId = Number(req.user.id);
      const id = Number(req.params.id);

      const [result] = await pool.execute(
        `UPDATE appointments SET status='rejected'
       WHERE id=? AND doctorId=?`,
        [id, doctorId],
      );

      if (result.affectedRows === 0)
        return res.status(404).json({ message: "Not found" });
      res.json({ message: "Rejected" });
    } catch (e) {
      console.error(e);
      res.status(500).json({ message: "Server error" });
    }
  },
);

export default router;
