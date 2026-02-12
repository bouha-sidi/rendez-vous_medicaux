import pool from "../config/db.js";

export class Appointment {
  static async create({ patientId, doctorId, dateTime, reason }) {
    const [r] = await pool.execute(
      `INSERT INTO appointments (patientId, doctorId, dateTime, reason)
       VALUES (?, ?, ?, ?)`,
      [patientId, doctorId, dateTime, reason || null],
    );
    return {
      id: r.insertId,
      patientId,
      doctorId,
      dateTime,
      reason,
      status: "pending",
    };
  }

  static async findByDoctor(doctorId) {
    const [rows] = await pool.execute(
      `SELECT a.*, u.fullName as patientName
       FROM appointments a
       JOIN users u ON u.id = a.patientId
       WHERE a.doctorId = ?
       ORDER BY a.createdAt DESC`,
      [doctorId],
    );
    return rows;
  }

  static async updateStatus(id, doctorId, status) {
    const [r] = await pool.execute(
      `UPDATE appointments SET status = ? WHERE id = ? AND doctorId = ?`,
      [status, id, doctorId],
    );
    return r.affectedRows > 0;
  }
}

export default Appointment;
