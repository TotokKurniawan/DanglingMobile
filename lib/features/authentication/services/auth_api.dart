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

      // Backend mengembalikan: { success, data: { user: { id, name, email, roles[] }, token } }
      if (response.statusCode == 200 && response.data['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final user = response.data['data']['user'] as Map<String, dynamic>;
        final token = response.data['data']['token'] as String?;

        // Backend menggunakan 'name' (bukan 'nama') dan 'roles' array (bukan 'role')
        await prefs.setString('email', email);
        await prefs.setString('nama', user['name'] as String? ?? '');
        await prefs.setInt('user_id', user['id'] as int? ?? 0);

        final roles = user['roles'] as List?;
        final role = (roles != null && roles.isNotEmpty) ? roles[0] as String : 'buyer';
        await prefs.setString('role', role);

        if (token != null && token.isNotEmpty) {
          await prefs.setString('token', token);
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
        await prefs.clear(); // Hapus semua data sesi
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('Logout error: ${e.message}');
      return false;
    }
  }
}
