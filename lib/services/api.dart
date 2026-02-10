// lib/services/api.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  // ✅ Web/Windows: 127.0.0.1
  // ✅ Android emulator: 10.0.2.2
  static const String baseUrl = "http://127.0.0.1:3000/api";

  // ================= TOKEN =================
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

  // ================= REGISTER PATIENT (JSON) =================
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

    final data = _safeJson(res.body);
    if (res.statusCode >= 400) {
      throw Exception(data["message"] ?? "Register patient failed");
    }
  }

  // ================= REGISTER DOCTOR (MULTIPART + PHOTO) =================
  static Future<void> registerDoctor({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String specialty,
    required String clinicAddress,
    required int consultationPrice,
    required XFile doctorPhoto,
  }) async {
    final uri = Uri.parse("$baseUrl/auth/register");
    final request = http.MultipartRequest("POST", uri);

    request.fields["role"] = "doctor";
    request.fields["fullName"] = fullName;
    request.fields["email"] = email;
    request.fields["phone"] = phone;
    request.fields["password"] = password;
    request.fields["specialty"] = specialty;
    request.fields["clinicAddress"] = clinicAddress;
    request.fields["consultationPrice"] = consultationPrice.toString();

    final bytes = await doctorPhoto.readAsBytes();
    final mimeType =
        lookupMimeType(doctorPhoto.name, headerBytes: bytes) ?? "image/jpeg";
    final parts = mimeType.split("/");

    request.files.add(
      http.MultipartFile.fromBytes(
        "doctorPhoto",
        bytes,
        filename: doctorPhoto.name,
        contentType: MediaType(parts[0], parts[1]),
      ),
    );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    final data = _safeJson(body);

    if (streamed.statusCode >= 400) {
      throw Exception(data["message"] ?? "Register doctor failed");
    }
  }

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = _safeJson(res.body);

    if (res.statusCode >= 400) {
      throw Exception(data["message"] ?? "Login failed");
    }

    await saveSession(data["token"], data["user"]["role"]);
    return data;
  }

  static Map<String, dynamic> _safeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {"message": body};
    } catch (_) {
      return {"message": body};
    }
  }
}
