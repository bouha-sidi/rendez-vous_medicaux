import express from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import User from "../models/User.js";
import { uploadDoctorPhoto } from "../middleware/uploadDoctorPhoto.js";

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || "CHANGE_ME";
const PORT = process.env.PORT || 3000;

// ✅ REGISTER
router.post(
  "/register",
  (req, res, next) => {
    uploadDoctorPhoto.single("doctorPhoto")(req, res, (err) => {
      if (err) return res.status(400).json({ message: err.message });
      next();
    });
  },
  async (req, res) => {
    try {
      const {
        role,
        name,
        fullName,
        email,
        phone,
        password,
        specialty,
        clinicAddress,
        consultationPrice,
      } = req.body;

      const userFullName = (fullName || name || "").trim();

      if (!role || !userFullName || !email || !phone || !password) {
        return res.status(400).json({ message: "Missing required fields" });
      }
      if (!["patient", "doctor"].includes(role)) {
        return res.status(400).json({ message: "Invalid role" });
      }

      if (role === "doctor") {
        if (!req.file)
          return res.status(400).json({ message: "Doctor photo is required" });
        if (!specialty || !clinicAddress || consultationPrice == null) {
          return res.status(400).json({ message: "Doctor fields required" });
        }
      }

      const exists = await User.findOne({ email });
      if (exists)
        return res.status(409).json({ message: "Email already used" });

      const passwordHash = await bcrypt.hash(password, 10);

      const created = await User.create({
        role,
        fullName: userFullName,
        email,
        phone,
        passwordHash,
        specialty: role === "doctor" ? specialty : null,
        clinicAddress: role === "doctor" ? clinicAddress : null,
        consultationPrice: role === "doctor" ? Number(consultationPrice) : null,
        doctorPhoto: role === "doctor" ? req.file.filename : null,
        isVerifiedDoctor: role === "doctor" ? 0 : null, // 0/1 en MySQL
      });

      return res
        .status(201)
        .json({ message: "Registered", userId: created._id });
    } catch (e) {
      console.error(e);
      return res.status(500).json({ message: "Server error" });
    }
  },
);

// ✅ LOGIN
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ message: "Missing fields" });

    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ message: "Invalid credentials" });

    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) return res.status(401).json({ message: "Invalid credentials" });

    // doctor non vérifié => 0
    if (
      user.role === "doctor" &&
      (user.isVerifiedDoctor === 0 || user.isVerifiedDoctor === false)
    ) {
      return res.status(403).json({ message: "Doctor not verified yet" });
    }

    const token = jwt.sign(
      { id: user.id, role: user.role, email: user.email },
      JWT_SECRET,
      { expiresIn: "7d" },
    );

    return res.json({
      token,
      user: {
        id: user.id,
        role: user.role,
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        specialty: user.specialty,
        clinicAddress: user.clinicAddress,
        consultationPrice: user.consultationPrice,
        doctorPhotoUrl: user.doctorPhoto
          ? `http://localhost:${PORT}/uploads/doctors/${user.doctorPhoto}`
          : null,
      },
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: "Server error" });
  }
});

export default router;
