// backend/src/routes/doctor.routes.js
import express from "express";
import User from "../models/User.js";
import { requireAuth, requireRole } from "../middleware/auth.js";

const router = express.Router();

// ✅ GET /api/doctor/profile
router.get("/profile", requireAuth, requireRole("doctor"), async (req, res) => {
  try {
    // req.user.id comes from JWT
    const user = await User.findById(req.user.id);
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
      doctorPhoto: user.doctorPhoto, // filename (optional)
    });
  } catch (e) {
    console.error("doctor/profile GET error:", e);
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
      consultationPrice: req.body.consultationPrice,
    };

    // ✅ remove undefined keys
    Object.keys(fields).forEach((k) => {
      if (fields[k] === undefined) delete fields[k];
    });

    const ok = await User.update(id, fields);
    if (!ok) return res.status(404).json({ message: "Doctor not found" });

    return res.json({ message: "Profile updated" });
  } catch (e) {
    console.error("doctor/profile PUT error:", e);
    return res.status(500).json({ message: "Server error" });
  }
});

export default router;
