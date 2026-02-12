import express from "express";
import bcrypt from "bcrypt";
import User from "../models/User.js";

const router = express.Router();

// ⚠️ استعملها مرة وحدة ثم احذفها
router.post("/create-admin", async (req, res) => {
  try {
    const { fullName, email, phone, password } = req.body;

    if (!fullName || !email || !phone || !password) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const exists = await User.findOne({ email });
    if (exists) return res.status(409).json({ message: "Email already used" });

    const passwordHash = await bcrypt.hash(password, 10);

    const created = await User.create({
      role: "admin",
      fullName,
      email,
      phone,
      passwordHash,
      specialty: null,
      clinicAddress: null,
      consultationPrice: null,
      doctorPhoto: null,
      isVerifiedDoctor: true,
    });

    res.status(201).json({ message: "Admin created", id: created._id });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Server error" });
  }
});

export default router;
