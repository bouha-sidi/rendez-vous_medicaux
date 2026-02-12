import pool from "../config/db.js";

export class User {
  // Créer un utilisateur (patient ou médecin)
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
      date_of_birth,
      address,
      gender,
      profilePhoto
    } = userData;

    const query = `
      INSERT INTO users (
        role, fullName, email, phone, passwordHash,
        specialty, clinicAddress, consultationPrice, doctorPhoto, isVerifiedDoctor,
        date_of_birth, address, gender, profilePhoto
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const [result] = await pool.execute(query, [
      role,
      fullName,
      email,
      phone,
      passwordHash,
      specialty || null,
      clinicAddress || null,
      consultationPrice || null,
      doctorPhoto || null,
      isVerifiedDoctor === undefined ? false : isVerifiedDoctor,
      date_of_birth || null,
      address || null,
      gender || null,
      profilePhoto || null
    ]);

    return { id: result.insertId, ...userData };
  }

  // Trouver un utilisateur par email
  static async findOne(filter) {
    const { email } = filter;
    const [rows] = await pool.execute(`SELECT * FROM users WHERE email = ?`, [email]);
    return rows.length > 0 ? rows[0] : null;
  }

  // Trouver un utilisateur par ID
  static async findById(id) {
    const [rows] = await pool.execute(`SELECT * FROM users WHERE id = ?`, [id]);
    return rows.length > 0 ? rows[0] : null;
  }

  // Mettre à jour un utilisateur
  static async update(id, updateData) {
    const fields = Object.keys(updateData);
    const values = Object.values(updateData);
    values.push(id);

    const setClause = fields.map(f => `${f} = ?`).join(", ");
    const query = `UPDATE users SET ${setClause} WHERE id = ?`;

    const [result] = await pool.execute(query, values);
    return result.affectedRows > 0;
  }

  // Supprimer un utilisateur
  static async delete(id) {
    const [result] = await pool.execute(`DELETE FROM users WHERE id = ?`, [id]);
    return result.affectedRows > 0;
  }

  // Obtenir tous les utilisateurs avec filtre
  static async findAll(filter = {}) {
    let query = `SELECT * FROM users WHERE 1=1`;
    const params = [];

    if (filter.role) {
      query += ` AND role = ?`;
      params.push(filter.role);
    }

    const [rows] = await pool.execute(query, params);
    return rows;
  }

  // Obtenir la liste des médecins vérifiés
  static async findDoctors({ specialty, name }) {
    let query = `
      SELECT
        id,
        fullName,
        email,
        phone,
        specialty,
        clinicAddress,
        consultationPrice,
        doctorPhoto
      FROM users
      WHERE role = 'doctor' AND isVerifiedDoctor = true
    `;
    const params = [];

    if (specialty) {
      query += ` AND specialty LIKE ?`;
      params.push(`%${specialty}%`);
    }
    if (name) {
      query += ` AND fullName LIKE ?`;
      params.push(`%${name}%`);
    }

    query += ` ORDER BY fullName ASC`;
    const [rows] = await pool.execute(query, params);
    return rows;
  }
}

export default User;