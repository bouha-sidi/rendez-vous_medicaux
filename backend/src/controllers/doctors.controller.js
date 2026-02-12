import User from "../models/User.js";

// GET /api/doctors
export const getDoctors = async (req, res) => {
    try {
        const { specialty, name } = req.query;

        const doctors = await User.findDoctors({
            specialty,
            name,
        });

        res.json({
            count: doctors.length,
            doctors,
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur serveur" });
    }
};
