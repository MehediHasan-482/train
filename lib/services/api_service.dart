// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_project/models/user-model.dart';

class ApiService {
  static const String baseUrl = 'https://ez-train.vercel.app';

  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(
            request: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            error: true,
            logPrint: (obj) => print('[DIO] $obj'),
          ),
        );

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = UserModel(name: name, email: email, password: password);
      final response = await _dio.post('/auth/register', data: user.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'] ?? "";
        final userData = response.data['user'];
        final userName = userData?['name'] ?? name;

        await saveToken(token);
        await saveUserInfo(userName, email);

        return {
          "success": true,
          "token": token,
          "name": userName,
          "email": email,
        };
      } else {
        return {
          "success": false,
          "message": response.data['message'] ?? 'Registration failed',
        };
      }
    } on DioException catch (e) {
      print("API Error: ${_handleDioError(e)}");
      return {"success": false, "message": _handleDioError(e)};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print("=== LOGIN REQUEST ===");
      print("Email: $email");

      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      print("=== LOGIN RESPONSE ===");
      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String token = response.data['token'] ?? '';
        final Map<String, dynamic> user = response.data['user'] ?? {};
        final String name = user['name'] ?? email.split('@').first;

        print(" Login Successful!");

        await saveToken(token);
        await saveUserInfo(name, email);

        return {"success": true, "token": token, "name": name, "email": email};
      } else {
        return {
          "success": false,
          "message": response.data['message'] ?? 'Invalid credentials',
        };
      }
    } on DioException catch (e) {
      print("DioException Error: ${e.message}");
      return {"success": false, "message": _handleDioError(e)};
    } catch (e) {
      print("Unexpected Error: $e");
      return {"success": false, "message": "Something went wrong: $e"};
    }
  }

  static Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      print("Logout error: $e");
    } finally {
      await clearAllData();
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        return {"success": true, "user": response.data};
      } else {
        return {"success": false, "message": "Failed to get user info"};
      }
    } on DioException catch (e) {
      return {"success": false, "message": _handleDioError(e)};
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('Token saved: $token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    print('Token deleted');
  }

  static Future<void> saveUserInfo(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    print('User info saved: $name, $email');
  }

  static Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
    };
  }

  static Future<void> deleteUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    print('User info deleted');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAllData() async {
    await deleteToken();
    await deleteUserInfo();
    print('All data cleared');
  }

  static String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final msg = e.response?.data?['message'];
        return msg ?? 'Server error (Code: $statusCode)';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'Something went wrong: ${e.message}';
    }
  }
}
