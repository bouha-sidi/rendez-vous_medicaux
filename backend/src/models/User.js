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
      isVerifiedDoctor === undefined ? 0 : Number(isVerifiedDoctor), // ✅ 0/1
    ]);

    return { id: result.insertId, ...userData };
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

  // ✅ NEW: findAll (ex: role doctor)
  static async findAll(filter = {}) {
    const { role } = filter;

    if (role) {
      const [rows] = await pool.execute(`SELECT * FROM users WHERE role = ?`, [
        role,
      ]);
      return rows;
    }

    const [rows] = await pool.execute(`SELECT * FROM users`);
    return rows;
  }

  // ✅ NEW: update fields
  static async update(id, fields) {
    const keys = Object.keys(fields || {});
    if (keys.length === 0) return false;

    const setSql = keys.map((k) => `${k} = ?`).join(", ");
    const values = keys.map((k) => fields[k]);

    const [result] = await pool.execute(
      `UPDATE users SET ${setSql} WHERE id = ?`,
      [...values, id],
    );

    return result.affectedRows > 0;
  }

  // ✅ NEW: delete user
  static async delete(id) {
    const [result] = await pool.execute(`DELETE FROM users WHERE id = ?`, [id]);
    return result.affectedRows > 0;
  }
}

export default User;
