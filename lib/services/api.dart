import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  /// ⚠️ IMPORTANT
  /// Remplace par l’IP de ton PC si tu es sur téléphone
  /// ex: http://192.168.1.20:3000
  static const String baseUrl = "http://10.0.2.2:3000"; // émulateur
  // static const String baseUrl = "http://192.168.1.20:3000"; // téléphone réel

  // ---------------- TOKEN ----------------

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // ---------------- REGISTER PATIENT ----------------

  static Future<void> registerPatient({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "role": "patient",
        "fullName": fullName,
        "email": email,
        "phone": phone,
        "password": password,
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(data["message"] ?? "Register patient failed");
    }
  }

  // ---------------- REGISTER DOCTOR (PHOTO OBLIGATOIRE) ----------------

  static Future<void> registerDoctor({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String specialty,
    required String clinicAddress,
    required double consultationPrice,
    required File doctorPhoto,
  }) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/auth/register"),
    );

    request.fields.addAll({
      "role": "doctor",
      "fullName": fullName,
      "email": email,
      "phone": phone,
      "password": password,
      "specialty": specialty,
      "clinicAddress": clinicAddress,
      "consultationPrice": consultationPrice.toString(),
    });

    final mimeType = lookupMimeType(doctorPhoto.path) ?? "image/jpeg";
    final parts = mimeType.split("/");

    request.files.add(
      await http.MultipartFile.fromPath(
        "doctorPhoto", // ⚠️ même nom que backend
        doctorPhoto.path,
        contentType: MediaType(parts[0], parts[1]),
      ),
    );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    final data = jsonDecode(body);

    if (streamed.statusCode >= 400) {
      throw Exception(data["message"] ?? "Register doctor failed");
    }
  }

  // ---------------- LOGIN ----------------

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

    await saveToken(data["token"]);
    return data;
  }
}
