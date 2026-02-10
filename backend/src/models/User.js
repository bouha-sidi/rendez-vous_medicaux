import pool from "../config/db.js";

export class User {
  // Créer un nouvel utilisateur
  static async create(userData) {
    const { role, fullName, email, phone, passwordHash, specialty, clinicAddress, consultationPrice, doctorPhoto, isVerifiedDoctor } = userData;
    
    const query = `
      INSERT INTO users (role, fullName, email, phone, passwordHash, specialty, clinicAddress, consultationPrice, doctorPhoto, isVerifiedDoctor)
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
      consultationPrice || null,
      doctorPhoto || null,
      isVerifiedDoctor === undefined ? false : isVerifiedDoctor
    ]);
    
    return { _id: result.insertId, ...userData };
  }

  // Trouver un utilisateur par email
  static async findOne(filter) {
    const { email } = filter;
    
    const query = `SELECT * FROM users WHERE email = ?`;
    const [rows] = await pool.execute(query, [email]);
    
    return rows.length > 0 ? rows[0] : null;
  }

  // Trouver un utilisateur par ID
  static async findById(id) {
    const query = `SELECT * FROM users WHERE id = ?`;
    const [rows] = await pool.execute(query, [id]);
    
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
    const query = `DELETE FROM users WHERE id = ?`;
    const [result] = await pool.execute(query, [id]);
    return result.affectedRows > 0;
  }

  // Obtenir tous les utilisateurs
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
}

export default User;
