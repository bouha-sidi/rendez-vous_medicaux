import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  /// ⚠️ émulateur Android
  static const String baseUrl = "http://127.0.0.1:3000/api";
  // téléphone réel : http://192.168.x.x:5000/api

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

  // ================= REGISTER =================

  static Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = "patient",
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(data["message"] ?? "Register failed");
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

    final data = jsonDecode(res.body);

    if (res.statusCode >= 400) {
      throw Exception(data["message"] ?? "Login failed");
    }

    await saveSession(data["token"], data["user"]["role"]);
    return data;
  }
}
