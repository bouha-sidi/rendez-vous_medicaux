import User from "../models/User.js";
import pool from "../config/db.js";

// Récupérer le profil complet du patient connecté
export const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: "Utilisateur non trouvé" });

    // Ne pas renvoyer le mot de passe
    delete user.passwordHash;
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Mettre à jour le profil (nom, téléphone, date de naissance, adresse, genre)
export const updateProfile = async (req, res) => {
  try {
    // Accepter date_of_birth (snake_case) du frontend
    const { fullName, phone, date_of_birth, address, gender } = req.body;
    const updateData = {};
    if (fullName !== undefined) updateData.fullName = fullName;
    if (phone !== undefined) updateData.phone = phone;
    if (date_of_birth !== undefined) updateData.date_of_birth = date_of_birth;
    if (address !== undefined) updateData.address = address;
    if (gender !== undefined) updateData.gender = gender;

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({ message: "Aucune donnée à mettre à jour" });
    }

    await User.update(req.user.id, updateData);
    res.json({ message: "Profil mis à jour avec succès" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Upload de la photo de profil
export const uploadProfilePhoto = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: "Aucune image envoyée" });
    }

    const photoPath = `/uploads/profile/${req.file.filename}`;
    await User.update(req.user.id, { profilePhoto: photoPath });

    res.json({
      message: "Photo de profil mise à jour",
      photo: photoPath
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Upload de document médical (inchangé)
export const uploadMedicalDocument = async (req, res) => {
  try {
    const { title } = req.body;
    await pool.execute(
      `INSERT INTO medical_documents (patient_id, title, filePath) VALUES (?, ?, ?)`,
      [req.user.id, title, `/uploads/documents/${req.file.filename}`]
    );
    res.status(201).json({ message: "Document ajouté" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Historique des rendez-vous passés (nouveau endpoint)
export const getPatientHistory = async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT 
        a.id,
        a.status,
        da.available_date,
        da.start_time,
        da.end_time,
        u.fullName AS doctor_name
      FROM appointments a
      JOIN doctor_availabilities da ON da.id = a.availability_id
      JOIN users u ON u.id = a.doctor_id
      WHERE a.patient_id = ?
        AND da.available_date < CURDATE()
      ORDER BY da.available_date DESC`,
      [req.user.id]
    );
    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
};