// backend/src/config/db.js
import "dotenv/config";
import mysql from "mysql2/promise";

const pool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "med_rdv",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

export async function initializeDatabase() {
  const connection = await pool.getConnection();

  try {
    await connection.execute(`SET NAMES utf8mb4`);
    await connection.execute(`SET time_zone = '+00:00'`);

    // ==================================================
    // USERS TABLE
    // ==================================================
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,

        role ENUM('patient', 'doctor', 'admin') NOT NULL,
        fullName VARCHAR(191) NOT NULL,
        email VARCHAR(191) NOT NULL UNIQUE,
        phone VARCHAR(30) NOT NULL,
        passwordHash VARCHAR(255) NOT NULL,

        specialty VARCHAR(191) NULL,
        clinicAddress VARCHAR(255) NULL,
        consultationPrice INT NULL,
        doctorPhoto VARCHAR(255) NULL,

        isVerifiedDoctor TINYINT(1) NOT NULL DEFAULT 0,

        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      ) ENGINE=InnoDB 
      DEFAULT CHARSET=utf8mb4 
      COLLATE=utf8mb4_unicode_ci;
    `);

    // ==================================================
    // APPOINTMENTS TABLE
    // ==================================================
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS appointments (
        id INT AUTO_INCREMENT PRIMARY KEY,

        patientId INT NOT NULL,
        doctorId INT NOT NULL,

        appointmentDate DATETIME NOT NULL,

        status ENUM('pending','accepted','rejected')
          NOT NULL DEFAULT 'pending',

        note VARCHAR(255) NULL,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

        INDEX idx_doctor (doctorId),
        INDEX idx_patient (patientId),

        FOREIGN KEY (patientId)
          REFERENCES users(id)
          ON DELETE CASCADE,

        FOREIGN KEY (doctorId)
          REFERENCES users(id)
          ON DELETE CASCADE
      ) ENGINE=InnoDB 
      DEFAULT CHARSET=utf8mb4 
      COLLATE=utf8mb4_unicode_ci;
    `);

    // ==================================================
    // UPDATE ENUM IF TABLE EXISTS (SAFE MIGRATION)
    // ==================================================
    await connection.execute(`
      ALTER TABLE appointments
      MODIFY status ENUM('pending','accepted','rejected')
      NOT NULL DEFAULT 'pending'
    `);

    console.log("✅ DB OK: users + appointments ready");
  } catch (error) {
    console.error("❌ DB init error:", error.message);
    throw error;
  } finally {
    connection.release();
  }
}

export default pool;
