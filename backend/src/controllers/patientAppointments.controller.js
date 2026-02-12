import Appointment from "../models/Appointment.js";

// Obtenir les rendez-vous du patient connecté
export const getMyAppointments = async (req, res) => {
  try {
    const data = await Appointment.findByPatient(req.user.id);
    res.json(data);
  } catch (e) {
    res.status(500).json({ message: "Erreur serveur" });
  }
};

// Annuler un rendez-vous (patient)
export const cancelAppointment = async (req, res) => {
  try {
    await Appointment.cancel(req.params.id, req.user.id);
    res.json({ message: "Rendez-vous annulé" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
};

// Confirmer un rendez-vous (médecin ou admin)
export const confirmAppointment = async (req, res) => {
  try {
    await Appointment.confirm(req.params.id);
    res.json({ message: "Rendez-vous confirmé" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
};