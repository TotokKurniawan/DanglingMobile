import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:damping/core/network/api_client.dart';
import 'package:damping/core/network/api_endpoints.dart';

class StoreApi {
  final ApiClient _apiClient = ApiClient();

  /// Upgrade akun pembeli menjadi pedagang (multipart — foto toko)
  Future<bool> upgradeToSeller({
    required String namaToko,
    required String telfon,
    required String alamat,
    File? foto,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) return false;

    try {
      final formData = FormData.fromMap({
        'user_id': userId.toString(),
        'namaToko': namaToko,
        'telfon': telfon,
        'alamat': alamat,
        if (foto != null)
          'foto': await MultipartFile.fromFile(foto.path, filename: foto.path.split('/').last),
      });

      final response = await _apiClient.post(
        ApiEndpoints.upgradeToSeller,
        data: formData,
      );

      if (response.statusCode == 200 && (response.data['success'] ?? false)) {
        int? idPedagang = response.data['pedagang']?['id'];
        if (idPedagang != null) await prefs.setInt('id_pedagang', idPedagang);
        return true;
      }
      return false;
    } on DioException catch (e) {
      print('upgradeToSeller error: ${e.message}');
      return false;
    }
  }

  /// Ambil status toko saat ini (online / offline)
  Future<bool> getStoreStatus() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getStoreStatus);

      if (response.statusCode == 200) {
        return response.data['isOnline'] == true;
      }
      return false;
    } on DioException catch (e) {
      print('getStoreStatus error: ${e.message}');
      return false;
    }
  }

  /// Ubah status toko menjadi online atau offline
  Future<bool> updateStatus(bool isOnline) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId == null) return false;

    try {
      final response = await _apiClient.post(
        ApiEndpoints.updateStoreStatus,
        data: {
          'user_id': userId,
          'status': isOnline ? 'online' : 'offline',
        },
      );

      if (response.statusCode == 200) {
        return response.data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      print('updateStatus error: ${e.message}');
      return false;
    }
  }

  /// Kirim koordinat GPS terkini ke backend sebagai lokasi pedagang
  Future<bool> checkLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        return response.data['success'] == true;
      }
      return false;
    } on DioException catch (e) {
      print('checkLocation error: ${e.message}');
      return false;
    }
  }
}
