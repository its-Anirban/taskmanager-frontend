import 'package:flutter/material.dart';
import 'package:task_manager_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  Future<void> login(String username, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await AuthService().login(username, password);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await AuthService().register(username, password);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.clearToken();
    notifyListeners(); // UI can react and route to login
  }

  static Future<bool> isLoggedIn() async {
    final token = await AuthService.getToken();
    return token != null && token.isNotEmpty;
  }
}
