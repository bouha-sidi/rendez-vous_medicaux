// backend/src/server.js
import "dotenv/config";
import express from "express";
import cors from "cors";
import path from "path";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

import User from "./models/User.js";
import { uploadDoctorPhoto } from "./middleware/uploadDoctorPhoto.js";
import { initializeDatabase } from "./config/db.js";

// ✅ ROUTES (IMPORTANT: doctorRoutes != doctorsRoutes)
import doctorsRoutes from "./routes/doctors.routes.js"; // ✅ LIST doctors (patient)
import doctorRoutes from "./routes/doctor.routes.js"; // ✅ PROFILE + appointments (doctor)
import appointmentsRoutes from "./routes/appointments.routes.js";
import adminRoutes from "./routes/admin.routes.js";

const app = express();

const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || "CHANGE_ME";

// ================== MIDDLEWARES ==================

// ✅ CORS (باش يخدم من الهاتف)
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
);

app.use(express.json());

// Static uploads (photos)
app.use("/uploads", express.static(path.resolve("uploads")));

// ================== ROUTES MODULES ==================
app.use("/api/appointments", appointmentsRoutes);
app.use("/api/doctors", doctorsRoutes); // ✅ patient list doctors
app.use("/api/doctor", doctorRoutes); // ✅ doctor profile + appointments
app.use("/api/admin", adminRoutes);

// ================== BASIC ROOT ==================
app.get("/", (req, res) => res.json({ ok: true, msg: "API MED-RDV running" }));

// ================== AUTH (REGISTER + LOGIN) ==================

// ✅ REGISTER (patient/doctor/admin)
app.post(
  "/api/auth/register",
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

      if (
        !["patient", "doctor", "admin"].includes((role || "").toLowerCase())
      ) {
        return res.status(400).json({ message: "Invalid role" });
      }
      const r = role.toLowerCase();

      if (!userFullName || !email || !phone || !password) {
        return res.status(400).json({ message: "Missing required fields" });
      }

      if (r === "doctor") {
        if (!req.file) {
          return res.status(400).json({ message: "Doctor photo is required" });
        }
        if (!specialty || !clinicAddress || consultationPrice == null) {
          return res.status(400).json({ message: "Doctor fields required" });
        }
      }

      const exists = await User.findOne({ email });
      if (exists) {
        return res.status(409).json({ message: "Email already used" });
      }

      const passwordHash = await bcrypt.hash(password, 10);

      const created = await User.create({
        role: r,
        fullName: userFullName,
        email,
        phone,
        passwordHash,

        specialty: r === "doctor" ? specialty : null,
        clinicAddress: r === "doctor" ? clinicAddress : null,
        consultationPrice: r === "doctor" ? Number(consultationPrice) : null,
        doctorPhoto: r === "doctor" ? req.file.filename : null,

        // ✅ IMPORTANT: doctor starts not verified (0), others verified (1)
        isVerifiedDoctor: r === "doctor" ? 0 : 1,
      });

      return res
        .status(201)
        .json({ message: "Registered", userId: created.id });
    } catch (e) {
      console.error("register error:", e);
      return res.status(500).json({ message: "Server error" });
    }
  },
);

// ✅ LOGIN
app.post("/api/auth/login", async (req, res) => {
  try {
    const { email, password } = req.body || {};
    if (!email || !password) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ message: "Invalid credentials" });

    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) return res.status(401).json({ message: "Invalid credentials" });

    if (user.role === "doctor" && Number(user.isVerifiedDoctor) === 0) {
      return res.status(403).json({ message: "Doctor not verified yet" });
    }

    const token = jwt.sign(
      { id: String(user.id), role: user.role, email: user.email },
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
    console.error("login error:", e);
    return res.status(500).json({ message: "Server error" });
  }
});

// ================== START SERVER ==================
initializeDatabase()
  .then(() => {
    console.log("✅ MySQL connected");

    // ✅ VERY IMPORTANT FOR PHONE: listen on all interfaces
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`✅ Server running on http://0.0.0.0:${PORT}`);
      console.log(`✅ API base: http://0.0.0.0:${PORT}/api`);
    });
  })
  .catch((err) => {
    console.error("❌ MySQL error:", err.message);
    process.exit(1);
  });
