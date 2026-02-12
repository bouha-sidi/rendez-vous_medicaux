import Availability from "../models/Availability.js";

export const getDoctorAvailabilities = async (req, res) => {
  try {
    const availabilities = await Availability.findByDoctor(req.params.doctorId);
    res.json(availabilities);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
};