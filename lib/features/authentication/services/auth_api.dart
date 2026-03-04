import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:damping/core/network/api_client.dart';
import 'package:damping/core/network/api_endpoints.dart';

/// Legacy API class — sebagian besar fungsi sudah dipindahkan ke AuthService.
/// Kelas ini masih dipertahankan untuk kompatibilitas, namun penggunaan
/// AuthService (lib/features/authentication/services/auth_service.dart)
/// lebih disarankan.
class AuthApi {
  final ApiClient _apiClient = ApiClient();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final user = response.data['user'];
        final token = response.data['token'];

        await prefs.setString('email', email);
        await prefs.setString('nama', user['nama'] ?? '');
        await prefs.setString('role', user['role'] ?? '');
        await prefs.setInt('user_id', user['id'] ?? 0);

        if (token != null && token.toString().isNotEmpty) {
          await prefs.setString('token', token.toString());
        }
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Login error: ${e.message}');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {'email': email, 'password': password},
      );

      return (response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true;
    } on DioException catch (e) {
      print('Register error: ${e.message}');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.logout);

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('email');
        await prefs.remove('nama');
        await prefs.remove('role');
        await prefs.remove('user_id');
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Logout error: ${e.message}');
      return false;
    }
  }
}
