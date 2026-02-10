import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const _tokenKey = 'token';
  static const _userKey = 'user';

  static Future<void> saveAuth(String token, Map<String, dynamic> user) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_tokenKey, token);
    await sp.setString(_userKey, jsonEncode(user));
  }

  static Future<String?> getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_tokenKey);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_tokenKey);
    await sp.remove(_userKey);
  }
}
