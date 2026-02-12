// backend/src/routes/doctors.routes.js
import express from "express";
import User from "../models/User.js";

const router = express.Router();

// ✅ Liste des médecins VALIDÉS (visible pour patient)
router.get("/", async (req, res) => {
  try {
    const docs = await User.findAll({ role: "doctor" });
    const verified = docs.filter((d) => Number(d.isVerifiedDoctor) === 1);

    res.json(
      verified.map((d) => ({
        id: d.id,
        fullName: d.fullName,
        specialty: d.specialty,
        clinicAddress: d.clinicAddress,
        consultationPrice: d.consultationPrice,
        doctorPhoto: d.doctorPhoto,
      })),
    );
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Server error" });
  }
});

export default router;
