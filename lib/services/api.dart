import 'package:flutter/foundation.dart'; // Import pour kIsWeb
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  // Détection dynamique de l'URL du backend
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:3000/api";
    } else {
      // Pour mobile (réseau local IP du serveur)
      return "http://172.16.216.35:3000/api";
    }
  }

  // URL de base pour les fichiers/photos (sans le /api)
  static String get baseServerUrl => baseUrl.replaceAll('/api', '');

  // ========== SESSION ==========
  static Future<void> saveSession(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("role", role);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("role");
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ========== AUTH ==========
  static Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? specialty,
    String? clinicAddress,
    int? consultationPrice,
    String? dateOfBirth,
    String? address,
    String? gender,
  }) async {
    final Map<String, dynamic> body = {
      "fullName": name,
      "email": email,
      "password": password,
      "role": role,
      "phone": phone ?? "",
    };
    if (role == "doctor") {
      body["specialty"] = specialty;
      body["clinicAddress"] = clinicAddress;
      body["consultationPrice"] = consultationPrice;
    } else if (role == "patient") {
      body["date_of_birth"] = dateOfBirth;
      body["address"] = address;
      body["gender"] = gender;
    }

    final res = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(data["message"] ?? "Register failed");
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(data["message"] ?? "Login failed");
    }

    await saveSession(data["token"], data["user"]["role"]);
    return data;
  }

  // ========== MÉDECINS ==========
  static Future<List<dynamic>> getDoctors({
    String? specialty,
    String? name,
  }) async {
    final token = await getToken();
    final uri = Uri.parse("$baseUrl/doctors").replace(
      queryParameters: {
        if (specialty != null && specialty.isNotEmpty) "specialty": specialty,
        if (name != null && name.isNotEmpty) "name": name,
      },
    );
    final res = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token"},
    );
    final data = jsonDecode(res.body);
    if (res.statusCode >= 400)
      throw Exception(data["message"] ?? "Erreur chargement médecins");
    return data["doctors"];
  }

  static Future<List<dynamic>> getAvailabilities(int doctorId) async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/availabilities/$doctorId"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  static Future<void> createAppointment({
    required int doctorId,
    required int availabilityId,
  }) async {
    final token = await getToken();
    final res = await http.post(
      Uri.parse("$baseUrl/appointments"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "doctorId": doctorId,
        "availabilityId": availabilityId,
      }),
    );
    if (res.statusCode >= 400)
      throw Exception("Création du rendez-vous échouée");
  }

  // ========== RENDEZ-VOUS PATIENT ==========
  static Future<List<dynamic>> getMyAppointments() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/patient/appointments"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  static Future<void> cancelAppointment(int id) async {
    final token = await getToken();
    await http.put(
      Uri.parse("$baseUrl/patient/appointments/$id/cancel"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  // ========== HISTORIQUE (nouvel endpoint) ==========
  static Future<List<dynamic>> getPatientHistory() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/patient/history"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  // ========== PROFIL ==========
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/patient/me"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  static Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? dateOfBirth,
    String? address,
    String? gender,
  }) async {
    final token = await getToken();
    final body = <String, dynamic>{};
    if (fullName != null) body["fullName"] = fullName;
    if (phone != null) body["phone"] = phone;
    // Correction : toujours envoyer le champ en snake_case
    if (dateOfBirth != null) body["date_of_birth"] = dateOfBirth;
    if (address != null) body["address"] = address;
    if (gender != null) body["gender"] = gender;

    final res = await http.put(
      Uri.parse("$baseUrl/patient/me"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
    if (res.statusCode >= 400) {
      final data = jsonDecode(res.body);
      // Show full backend error message if available
      throw Exception(
        data["error"] ??
            data["message"] ??
            "Erreur modification profil (${res.statusCode})",
      );
    }
  }

  static Future<String> uploadProfilePhoto(XFile image) async {
    final token = await getToken();
    final url = Uri.parse("$baseUrl/patient/me/photo");

    final request = http.MultipartRequest("PUT", url);
    request.headers["Authorization"] = "Bearer $token";

    // Works on both Mobile (path) and Web (bytes)
    final bytes = await image.readAsBytes();
    final multipartFile = http.MultipartFile.fromBytes(
      "photo",
      bytes,
      filename: image.name,
    );
    request.files.add(multipartFile);

    final res = await request.send();
    final responseBody = await res.stream.bytesToString();
    final json = jsonDecode(responseBody);

    if (res.statusCode >= 400) {
      throw Exception(
        json["error"] ?? json["message"] ?? "Upload échoué (${res.statusCode})",
      );
    }
    return json["photo"];
  }

  // ========== GESTION DES RENDEZ-VOUS PAR ID PATIENT (admin / usage interne) ==========
  static Future<List> getPatientAppointments(int patientId) async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse("$baseUrl/appointments/patient/$patientId"),
      headers: {"Authorization": "Bearer $token"},
    );
    return jsonDecode(res.body);
  }

  static Future<void> deleteAppointment(int id) async {
    final token = await getToken();
    await http.delete(
      Uri.parse("$baseUrl/appointments/$id"),
      headers: {"Authorization": "Bearer $token"},
    );
  }
}
