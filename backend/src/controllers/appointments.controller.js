import Availability from "../models/Availability.js";
import Appointment from "../models/Appointment.js";

export const createAppointment = async (req, res) => {
    try {
        const patientId = req.user.id;
        const { doctorId, availabilityId } = req.body;

        if (!doctorId || !availabilityId) {
            return res.status(400).json({ message: "Données manquantes" });
        }

        await Appointment.create({
            patientId,
            doctorId,
            availabilityId,
        });

        await Availability.markBooked(availabilityId);

        res.status(201).json({ message: "Rendez-vous créé avec succès" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Erreur serveur" });
    }
};

export const getAppointmentsByPatient = async (req, res) => {
    try {
        const { id } = req.params;
        const data = await Appointment.findByPatient(id);
        res.json(data);
    } catch {
        res.status(500).json({ message: "Erreur serveur" });
    }
};

export const deleteAppointment = async (req, res) => {
    try {
        const success = await Appointment.delete(
            req.params.id,
            req.user.id
        );
        if (!success)
            return res.status(404).json({ message: "RDV introuvable" });

        res.json({ message: "Rendez-vous annulé" });
    } catch {
        res.status(500).json({ message: "Erreur serveur" });
    }
};
