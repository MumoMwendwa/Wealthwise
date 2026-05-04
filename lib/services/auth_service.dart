import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/app_user.dart';

class AuthService {
  static const _kToken = 'auth_token';
  static const _kUserJson = 'auth_user';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _decode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(data['message']?.toString() ?? 'Login failed');
    }
    return _persistAuth(data);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    final data = _decode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(data['message']?.toString() ?? 'Sign-up failed');
    }
    return _persistAuth(data);
  }

  Future<Map<String, dynamic>?> getPersistedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kToken);
    final rawUser = prefs.getString(_kUserJson);
    if (token == null || rawUser == null) return null;
    final user = AppUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
    return {'token': token, 'user': user};
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUserJson);
  }

  Future<Map<String, dynamic>> _persistAuth(Map<String, dynamic> data) async {
    final token = data['token']?.toString() ?? '';
    final userMap = data['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kUserJson, jsonEncode(userMap));
    return {'token': token, 'user': AppUser.fromJson(userMap)};
  }

  Map<String, dynamic> _decode(String raw) {
    if (raw.trim().isEmpty) return {'message': 'Empty server response'};
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return {'message': 'Unexpected server response'};
  }
}
