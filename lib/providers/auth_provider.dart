import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  AppUser? _user;
  String _token = '';
  bool _isLoading = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null && _token.isNotEmpty;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> hydrate() async {
    final data = await _service.getPersistedAuth();
    if (data == null) return;
    _token = data['token'] as String;
    _user = data['user'] as AppUser;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.login(email: email, password: password);
      _token = data['token'] as String;
      _user = data['user'] as AppUser;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.register(name: name, email: email, password: password);
      _token = data['token'] as String;
      _user = data['user'] as AppUser;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _token = '';
    _user = null;
    notifyListeners();
  }
}
