import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/models/auth_response.dart';
import 'package:task_manager_app/utils/constants.dart';

class AuthService {
  AuthService({this.baseUrl = Constants.baseUrl});
  final String baseUrl;

  Future<LoginResponse> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final lr = LoginResponse.fromMap(data);
      // persist token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.tokenKey, lr.token);
      return lr;
    } else {
      // try to parse server message
      final msg = res.body.isNotEmpty ? res.body : 'Login failed';
      throw Exception('Login failed: ${res.statusCode} - $msg');
    }
  }

  Future<void> register(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/register');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Registration failed: ${res.statusCode} - ${res.body}');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
  }
}
