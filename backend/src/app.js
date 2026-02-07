import express from "express";
import cors from "cors";
import path from "path";

const app = express();

app.use(cors());
app.use(express.json());

// ✅ servir les images (photos médecins)
app.use("/uploads", express.static(path.resolve("uploads")));

app.get("/", (req, res) => {
  res.json({ ok: true, msg: "MED-RDV API running" });
});

export default app;
