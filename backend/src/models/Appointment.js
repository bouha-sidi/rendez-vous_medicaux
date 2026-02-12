import pool from "../config/db.js";

class Appointment {
  // Créer un rendez-vous (avec vérification atomique)
  static async create({ patientId, doctorId, availabilityId }) {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();

      // Vérifier que le créneau est toujours libre
      const [avail] = await connection.execute(
        `SELECT is_booked FROM doctor_availabilities WHERE id = ? FOR UPDATE`,
        [availabilityId]
      );
      if (avail.length === 0 || avail[0].is_booked) {
        throw new Error("Créneau déjà réservé ou inexistant");
      }

      // Créer le rendez-vous
      const [result] = await connection.execute(
        `INSERT INTO appointments (patient_id, doctor_id, availability_id, status)
         VALUES (?, ?, ?, 'PENDING')`,
        [patientId, doctorId, availabilityId]
      );

      // Marquer le créneau comme réservé
      await connection.execute(
        `UPDATE doctor_availabilities SET is_booked = true WHERE id = ?`,
        [availabilityId]
      );

      await connection.commit();
      return result.insertId;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  // Récupérer les rendez-vous d'un patient
  static async findByPatient(patientId) {
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
       ORDER BY da.available_date DESC`,
      [patientId]
    );
    return rows;
  }

  // Annuler un rendez-vous (patient)
  static async cancel(id, patientId) {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();

      // Récupérer l'ID du créneau
      const [appt] = await connection.execute(
        `SELECT availability_id FROM appointments WHERE id = ? AND patient_id = ?`,
        [id, patientId]
      );
      if (appt.length === 0) throw new Error("Rendez-vous non trouvé");

      const availabilityId = appt[0].availability_id;

      // Mettre à jour le statut du rendez-vous
      await connection.execute(
        `UPDATE appointments SET status = 'CANCELLED' WHERE id = ? AND patient_id = ?`,
        [id, patientId]
      );

      // Libérer le créneau
      await connection.execute(
        `UPDATE doctor_availabilities SET is_booked = false WHERE id = ?`,
        [availabilityId]
      );

      await connection.commit();
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  // Confirmer un rendez-vous (médecin/admin)
  static async confirm(id) {
    await pool.execute(
      `UPDATE appointments SET status = 'CONFIRMED' WHERE id = ?`,
      [id]
    );
  }

  // Supprimer un rendez-vous (admin)
  static async delete(id) {
    const [result] = await pool.execute(`DELETE FROM appointments WHERE id = ?`, [id]);
    return result.affectedRows > 0;
  }
}

export default Appointment;