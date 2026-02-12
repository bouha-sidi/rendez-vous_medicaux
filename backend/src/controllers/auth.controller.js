import User from "../models/User.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

// REGISTER
export const register = async (req, res) => {
  try {
    let {
      name,
      fullName,
      email,
      password,
      phone,
      role,
      specialty,
      clinicAddress,
      consultationPrice,
      date_of_birth,
      address,
      gender
    } = req.body;

    // Supporter les deux formats
    const userFullName = fullName || name;

    if (!userFullName || !email || !password) {
      return res.status(400).json({ message: "Missing required fields: name, email, password" });
    }

    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: "Email déjà utilisé" });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    // Construction de l'objet utilisateur
    const userData = {
      role: role || "patient",
      fullName: userFullName,
      email,
      phone: phone || "",
      passwordHash,
      specialty: role === "doctor" ? specialty : null,
      clinicAddress: role === "doctor" ? clinicAddress : null,
      consultationPrice: role === "doctor" ? consultationPrice : null,
      doctorPhoto: null,
      isVerifiedDoctor: false,
      date_of_birth: role === "patient" ? date_of_birth : null,
      address: role === "patient" ? address : null,
      gender: role === "patient" ? gender : null,
      profilePhoto: null
    };

    const user = await User.create(userData);

    res.status(201).json({
      message: "Utilisateur créé avec succès",
      user: {
        id: user.id,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};

// LOGIN (inchangé)
export const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: "Email et password requis" });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "Email ou mot de passe incorrect" });
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      return res.status(401).json({ message: "Email ou mot de passe incorrect" });
    }

    const token = jwt.sign(
      { id: user.id, role: user.role, email: user.email },
      process.env.JWT_SECRET || "SECRET_KEY",
      { expiresIn: "7d" }
    );

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        fullName: user.fullName
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
};