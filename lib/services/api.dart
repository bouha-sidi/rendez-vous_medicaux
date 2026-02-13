// lib/services/api.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  // ✅ Web/Windows: localhost
  // ✅ Android emulator: 10.0.2.2
  static const String baseUrl = "http://localhost:3000/api";
  // static const String baseUrl = "http://10.0.2.2:3000/api"; // emulator

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

  static Future<Map<String, String>> _authHeadersJson() async {
    final token = await getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
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
      throw Exception(_messageOf(data) ?? "Register patient failed");
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
      throw Exception(_messageOf(data) ?? "Register doctor failed");
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
      throw Exception(_messageOf(data) ?? "Login failed");
    }

    // نتأكد أن الرد Map
    if (data is! Map<String, dynamic>) {
      throw Exception("Invalid login response from server");
    }

    await saveSession(data["token"], data["user"]["role"]);
    return data;
  }

  // ================= ADMIN =================

  /// GET /api/admin/pending-doctors
  static Future<List<dynamic>> getPendingDoctors() async {
    final headers = await _authHeadersJson();
    final res = await http.get(
      Uri.parse("$baseUrl/admin/pending-doctors"),
      headers: headers,
    );

    final decoded = _safeJson(res.body);

    if (res.statusCode >= 400) {
      throw Exception(_messageOf(decoded) ?? "Failed to load pending doctors");
    }

    // backend يرجّع List مباشرة
    if (decoded is List) return decoded;

    // في حال رجع Map فيه data
    if (decoded is Map && decoded["data"] is List) {
      return (decoded["data"] as List).cast<dynamic>();
    }

    throw Exception("Invalid response from server");
  }

  /// PATCH /api/admin/doctors/:id/verify
  static Future<void> verifyDoctor(int id) async {
    final headers = await _authHeadersJson();
    final res = await http.patch(
      Uri.parse("$baseUrl/admin/doctors/$id/verify"),
      headers: headers,
    );

    final data = _safeJson(res.body);
    if (res.statusCode >= 400) {
      throw Exception(_messageOf(data) ?? "Verify failed");
    }
  }

  /// DELETE /api/admin/doctors/:id/reject
  static Future<void> rejectDoctor(int id) async {
    final headers = await _authHeadersJson();
    final res = await http.delete(
      Uri.parse("$baseUrl/admin/doctors/$id/reject"),
      headers: headers,
    );

    final data = _safeJson(res.body);
    if (res.statusCode >= 400) {
      throw Exception(_messageOf(data) ?? "Reject failed");
    }
  }

  // ✅ Doctor photo url helper
  static String doctorPhotoUrl(String? filename) {
    if (filename == null || filename.trim().isEmpty) return "";
    return "http://localhost:3000/uploads/doctors/$filename";
  }
  // ================= GENERIC AUTH REQUESTS =================

  /// GET with Bearer token (JSON)
  static Future<dynamic> getAuth(String path) async {
    final headers = await _authHeadersJson();
    final res = await http.get(
      Uri.parse("$baseUrl$path"),
      headers: headers,
    );

    final data = _safeJson(res.body);
    if (res.statusCode >= 400) {
      throw Exception(_messageOf(data) ?? "GET $path failed");
    }
    return data;
  }

  /// PUT with Bearer token (JSON)
  static Future<dynamic> putAuth(String path, Map<String, dynamic> body) async {
    final headers = await _authHeadersJson();
    final res = await http.put(
      Uri.parse("$baseUrl$path"),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = _safeJson(res.body);
    if (res.statusCode >= 400) {
      throw Exception(_messageOf(data) ?? "PUT $path failed");
    }
    return data;
  }

  // ================= UTIL =================
  static dynamic _safeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return {"message": body};
    }
  }

  static String? _messageOf(dynamic decoded) {
    if (decoded is Map && decoded["message"] != null) {
      return decoded["message"].toString();
    }
    return null;
  }
}
