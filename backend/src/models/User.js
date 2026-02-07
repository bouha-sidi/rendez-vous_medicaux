import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    role: {
      type: String,
      enum: ["patient", "doctor", "admin"],
      required: true,
    },
    fullName: { type: String, required: true, trim: true },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    phone: { type: String, required: true, trim: true },
    passwordHash: { type: String, required: true },

    // Doctor only
    specialty: { type: String, trim: true },
    clinicAddress: { type: String, trim: true },
    consultationPrice: { type: Number },

    // ✅ Photo obligatoire seulement pour doctor
    doctorPhoto: {
      type: String,
      required: function () {
        return this.role === "doctor";
      },
    },

    isVerifiedDoctor: { type: Boolean, default: false },
  },
  { timestamps: true },
);

export default mongoose.model("User", userSchema);
