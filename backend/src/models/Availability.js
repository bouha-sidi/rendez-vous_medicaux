import pool from "../config/db.js";

class Availability {
  static async findByDoctor(doctorId) {
    const [rows] = await pool.execute(
      `SELECT * FROM doctor_availabilities
       WHERE doctor_id = ? AND is_booked = false
       ORDER BY available_date, start_time`,
      [doctorId]
    );
    return rows;
  }

  static async markBooked(id) {
    await pool.execute(
      `UPDATE doctor_availabilities SET is_booked = true WHERE id = ?`,
      [id]
    );
  }
}

export default Availability;