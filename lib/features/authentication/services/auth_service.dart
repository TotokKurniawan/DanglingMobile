import 'package:dio/dio.dart';
import 'package:damping/core/network/api_client.dart';
import 'package:damping/core/network/api_endpoints.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data; // Biasanya backend membalikkan {"success": false, "message": "...", ...}
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // Register
  Future<Map<String, dynamic>> register(String name, String email, String phone, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.logout);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword(String email, String token, String password, String passwordConfirmation) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
