// backend/src/routes/doctors.routes.js
import express from "express";
import pool from "../config/db.js";

const router = express.Router();

// ✅ GET /api/doctors (liste des doctors pour patient)
router.get("/", async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT id, fullName, specialty, clinicAddress, consultationPrice, doctorPhoto
       FROM users
       WHERE role='doctor' AND isVerifiedDoctor=1
       ORDER BY createdAt DESC`,
    );

    const PORT = process.env.PORT || 3000;

    return res.json(
      rows.map((d) => ({
        id: d.id,
        fullName: d.fullName,
        specialty: d.specialty,
        clinicAddress: d.clinicAddress,
        consultationPrice: d.consultationPrice,
        doctorPhoto: d.doctorPhoto,
        doctorPhotoUrl: d.doctorPhoto
          ? `http://localhost:${PORT}/uploads/doctors/${d.doctorPhoto}`
          : null,
      })),
    );
  } catch (e) {
    console.error("GET /api/doctors error:", e);
    return res.status(500).json({ message: "Server error" });
  }
});

export default router;
