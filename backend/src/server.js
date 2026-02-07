import "dotenv/config";
import express from "express";
import cors from "cors";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import mongoose from "mongoose";
import path from "path";

import User from "./models/User.js";
import { uploadDoctorPhoto } from "./middleware/uploadDoctorPhoto.js";

const app = express();
app.use(cors());
app.use(express.json());

// ✅ servir les images
app.use("/uploads", express.static(path.resolve("uploads")));

const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || "CHANGE_ME";
const MONGO_URI = process.env.MONGO_URI || "mongodb://127.0.0.1:27017/med_rdv";

app.get("/", (req, res) => res.json({ ok: true, msg: "API MED-RDV running" }));

// ✅ REGISTER (patient JSON / doctor multipart + photo obligatoire)
app.post(
  "/auth/register",
  (req, res, next) => {
    // Si c'est doctor => multipart (photo)
    // Si patient => JSON normal
    const role = req.headers["x-role"]; // optionnel
    // On essaie de lire role via body si json, sinon via fields multipart
    // On ne sait pas à l'avance => on applique multer quand même, il accepte sans fichier.
    uploadDoctorPhoto.single("doctorPhoto")(req, res, (err) => {
      if (err) return res.status(400).json({ message: err.message });
      next();
    });
  },
  async (req, res) => {
    try {
      const {
        role, // "patient" | "doctor"
        fullName,
        email,
        phone,
        password,
        specialty,
        clinicAddress,
        consultationPrice,
      } = req.body;

      if (!role || !fullName || !email || !phone || !password) {
        return res.status(400).json({ message: "Missing required fields" });
      }
      if (!["patient", "doctor"].includes(role)) {
        return res.status(400).json({ message: "Invalid role" });
      }

      // ✅ doctor rules
      if (role === "doctor") {
        if (!req.file) {
          return res.status(400).json({ message: "Doctor photo is required" });
        }
        if (!specialty || !clinicAddress || consultationPrice == null) {
          return res.status(400).json({ message: "Doctor fields required" });
        }
      }

      const exists = await User.findOne({ email });
      if (exists)
        return res.status(409).json({ message: "Email already used" });

      const passwordHash = await bcrypt.hash(password, 10);

      const user = await User.create({
        role,
        fullName,
        email,
        phone,
        passwordHash,

        specialty: role === "doctor" ? specialty : undefined,
        clinicAddress: role === "doctor" ? clinicAddress : undefined,
        consultationPrice:
          role === "doctor" ? Number(consultationPrice) : undefined,
        doctorPhoto: role === "doctor" ? req.file.filename : undefined,
        isVerifiedDoctor: role === "doctor" ? false : undefined,
      });

      return res.status(201).json({ message: "Registered", userId: user._id });
    } catch (e) {
      console.error(e);
      return res.status(500).json({ message: "Server error" });
    }
  },
);

// ✅ LOGIN
app.post("/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ message: "Missing fields" });

    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ message: "Invalid credentials" });

    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) return res.status(401).json({ message: "Invalid credentials" });

    // (option) bloquer doctor non vérifié
    if (user.role === "doctor" && user.isVerifiedDoctor === false) {
      return res.status(403).json({ message: "Doctor not verified yet" });
    }

    const token = jwt.sign(
      { id: user._id.toString(), role: user.role, email: user.email },
      JWT_SECRET,
      { expiresIn: "7d" },
    );

    return res.json({
      token,
      user: {
        id: user._id,
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

// ✅ Start
mongoose
  .connect(MONGO_URI)
  .then(() => {
    console.log("✅ MongoDB connected");
    app.listen(PORT, () =>
      console.log(`✅ Server running on http://localhost:${PORT}`),
    );
  })
  .catch((err) => console.error("❌ MongoDB error:", err.message));
