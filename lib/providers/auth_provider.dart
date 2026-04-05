// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:test_project/models/user-model.dart';
import '../services/api_service.dart';

enum AuthStatus { initial, loading, success, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  String? _successMessage;
  String _userName = '';
  String _userEmail = '';
  String _token = '';

  UserModel? _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get token => _token;
  bool get isLoading => _status == AuthStatus.loading;
  UserModel? get currentUser => _currentUser;

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _status = AuthStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading();

    try {
      final result = await ApiService.login(email: email, password: password);

      if (result['success'] == true) {
        if ((result['token'] ?? '').isNotEmpty) {
          await ApiService.saveToken(result['token']);
        }

        final name = result['name'] ?? email.split('@').first;
        await ApiService.saveUserInfo(name, email);

        _userName = name;
        _userEmail = email;
        _token = result['token'] ?? '';

        _currentUser = UserModel(name: name, email: email, password: password);

        _status = AuthStatus.success;
        _successMessage = 'Welcome back! $_userName';
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Something went wrong: $e');
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();

    try {
      final result = await ApiService.register(
        name: name,
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        if ((result['token'] ?? '').isNotEmpty) {
          await ApiService.saveToken(result['token']);
        }

        await ApiService.saveUserInfo(name, email);

        _userName = name;
        _userEmail = email;
        _token = result['token'] ?? '';

        _currentUser = UserModel(name: name, email: email, password: password);

        _status = AuthStatus.success;
        _successMessage = 'Registration successful! Welcome, $name 🎉';
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.logout();
    } catch (e) {
      print('Logout error: $e');
    }

    _userName = '';
    _userEmail = '';
    _token = '';
    _currentUser = null;
    _status = AuthStatus.initial;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> checkSession() async {
    try {
      final isLoggedIn = await ApiService.isLoggedIn();

      if (isLoggedIn) {
        final info = await ApiService.getUserInfo();
        _userName = info['name'] ?? '';
        _userEmail = info['email'] ?? '';
        _token = await ApiService.getToken() ?? '';
        _status = AuthStatus.success;

        if (_userName.isNotEmpty) {
          _currentUser = UserModel(
            name: _userName,
            email: _userEmail,
            password: '',
          );
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Check session error: $e');
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> updateUserInfo({String? name, String? email}) async {
    if (name != null) {
      _userName = name;
      if (_currentUser != null) {
        _currentUser = UserModel(
          name: name,
          email: _currentUser!.email,
          password: _currentUser!.password,
        );
      }
      await ApiService.saveUserInfo(_userName, _userEmail);
    }

    if (email != null) {
      _userEmail = email;
      if (_currentUser != null) {
        _currentUser = UserModel(
          name: _currentUser!.name,
          email: email,
          password: _currentUser!.password,
        );
      }
      await ApiService.saveUserInfo(_userName, _userEmail);
    }

    notifyListeners();
  }
}
