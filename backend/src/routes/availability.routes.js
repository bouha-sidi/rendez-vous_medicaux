import express from "express";
import Availability from "../models/Availability.js";
import auth from "../middleware/auth.js";

const router = express.Router();

// GET /api/doctors/:id/availabilities
router.get("/:doctorId", auth, async (req, res) => {
  const data = await Availability.findByDoctor(req.params.doctorId);
  res.json(data);
});

export default router;
