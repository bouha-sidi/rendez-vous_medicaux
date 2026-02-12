// backend/src/middleware/auth.js
import jwt from "jsonwebtoken";

export function requireAuth(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7) : null;

  if (!token) return res.status(401).json({ message: "Accès non autorisé" });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || "CHANGE_ME");
    req.user = decoded;
    next();
  } catch (e) {
    return res.status(401).json({ message: "Token invalide" });
  }
}

export function requireRole(role) {
  return (req, res, next) => {
    if (!req.user?.role)
      return res.status(401).json({ message: "Unauthorized" });
    if (req.user.role !== role) {
      return res.status(403).json({ message: "Forbidden: role required" });
    }
    next();
  };
}
