import multer from "multer";
import path from "path";

const storage = multer.diskStorage({
  destination: "uploads/profile",
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `patient_${req.user.id}_${Date.now()}${ext}`);
  },
});

export const uploadProfilePhoto = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB for mobile photos
}).single("photo");

export const uploadDocument = multer({
  storage: multer.diskStorage({
    destination: "uploads/documents",
    filename: (req, file, cb) => {
      cb(null, `doc_${req.user.id}_${Date.now()}_${file.originalname}`);
    },
  }),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
}).single("document");
