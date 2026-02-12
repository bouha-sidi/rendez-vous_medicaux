import pool from "../config/db.js";

export const getMedicalHistory = async (req, res) => {
    const [rows] = await pool.execute(
        "SELECT * FROM medical_history WHERE patient_id = ?",
        [req.user.id]
    );
    res.json(rows);
};

export const addMedicalHistory = async (req, res) => {
    const { condition_name, description } = req.body;

    await pool.execute(
        `INSERT INTO medical_history (patient_id, condition_name, description)
     VALUES (?, ?, ?)`,
        [req.user.id, condition_name, description]
    );

    res.status(201).json({ message: "Historique ajouté" });
};
