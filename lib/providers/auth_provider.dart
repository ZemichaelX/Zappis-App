import 'package:flutter/material.dart';
import 'package:zappis/models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    // For demo purposes, we'll auto-login
    _currentUser = User.getSampleUser();
    _isLoggedIn = true;
  }

  Future<void> login(String phone, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, we'll always succeed
    _currentUser = User.getSampleUser();
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> register(
      String name, String phone, String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, we'll always succeed
    _currentUser = User(
      id: '1',
      name: name,
      phone: phone,
      email: email,
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? profileImage,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        email: email,
        profileImage: profileImage,
      );
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
