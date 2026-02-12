import "dotenv/config";
import mysql from "mysql2/promise";

const pool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || "ghoutoub",
  password: process.env.DB_PASSWORD || "mic19048",
  database: process.env.DB_NAME || "med_rdv",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

export async function initializeDatabase() {
  const connection = await pool.getConnection();
  try {
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        role ENUM('patient', 'doctor', 'admin') NOT NULL,
        fullName VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        phone VARCHAR(20) NOT NULL,
        passwordHash VARCHAR(255) NOT NULL,
        specialty VARCHAR(255),
        clinicAddress VARCHAR(255),
        consultationPrice INT,
        doctorPhoto VARCHAR(255),
        isVerifiedDoctor BOOLEAN DEFAULT false,
        -- Nouveaux champs pour les patients
        date_of_birth DATE,
        address VARCHAR(255),
        gender ENUM('male','female','other'),
        profilePhoto VARCHAR(255),
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `);
    console.log("✅ Table users créée ou déjà existante (avec nouveaux champs)");
  } catch (error) {
    console.error("❌ Erreur lors de la création de la table:", error.message);
  } finally {
    connection.release();
  }
}

export default pool;