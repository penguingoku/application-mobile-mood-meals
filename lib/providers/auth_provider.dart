import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/hive_service.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _isAuthenticated = false;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoggedIn => _isAuthenticated;

  Future<bool> login(String username, String password) async {
    final user = HiveService.getUser(username);

    if (user != null && user.password == password) {
      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(UserProfile user) async {
    if (HiveService.getUser(user.name) != null) {
      return false;
    }

    await HiveService.addUser(user);
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile user) async {
    await HiveService.addUser(user);
    _currentUser = user;
    notifyListeners();
  }
}