// backend/src/models/User.js
import pool from "../config/db.js";

export class User {
  static async create(userData) {
    const {
      role,
      fullName,
      email,
      phone,
      passwordHash,
      specialty,
      clinicAddress,
      consultationPrice,
      doctorPhoto,
      isVerifiedDoctor,
    } = userData;

    const query = `
      INSERT INTO users
      (role, fullName, email, phone, passwordHash, specialty, clinicAddress, consultationPrice, doctorPhoto, isVerifiedDoctor)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const [result] = await pool.execute(query, [
      role,
      fullName,
      email,
      phone,
      passwordHash,
      specialty || null,
      clinicAddress || null,
      consultationPrice ?? null,
      doctorPhoto || null,
      isVerifiedDoctor === undefined ? false : isVerifiedDoctor,
    ]);

    return { _id: result.insertId, ...userData };
  }

  static async findOne(filter) {
    const { email } = filter;
    const [rows] = await pool.execute(`SELECT * FROM users WHERE email = ?`, [
      email,
    ]);
    return rows.length > 0 ? rows[0] : null;
  }

  static async findById(id) {
    const [rows] = await pool.execute(`SELECT * FROM users WHERE id = ?`, [id]);
    return rows.length > 0 ? rows[0] : null;
  }
}

export default User;
