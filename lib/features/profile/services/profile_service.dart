import 'package:dio/dio.dart';
import 'package:streetmarketid/core/network/api_client.dart';
import 'package:streetmarketid/core/network/api_endpoints.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  /// Upload foto profil
  Future<Map<String, dynamic>?> uploadPhoto(String imagePath) async {
    try {
      FormData formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(imagePath),
      });

      final response = await _apiClient.post(
        ApiEndpoints.uploadProfilePhoto,
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error uploading profile photo: $e');
      return null;
    }
  }

  /// Update data pembeli
  Future<Map<String, dynamic>?> updateBuyerProfile(int buyerId, String name, String phone, String address) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.updateBuyerProfile}/$buyerId',
        data: {
          '_method': 'PUT', // Laravel method spoofing for multipart if needed, though here using app/json works too based on route
          'name': name,
          'phone': phone,
          'address': address,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error updating buyer profile: $e');
      return null;
    }
  }

  /// Update data penjual (Toko)
  Future<Map<String, dynamic>?> updateSellerProfile(
      int sellerId, String storeName, String phone, String address, {String? imagePath}) async {
    try {
      final mapData = <String, dynamic>{
        '_method': 'PUT', // Route PUT di-spoofing via POST
        'store_name': storeName,
        'phone': phone,
        'address': address,
      };

      if (imagePath != null && imagePath.isNotEmpty) {
        mapData['photo'] = await MultipartFile.fromFile(imagePath);
      }

      FormData formData = FormData.fromMap(mapData);

      final response = await _apiClient.post(
        '${ApiEndpoints.updateSellerProfile}/$sellerId',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Error updating seller profile: $e');
      return null;
    }
  }

  /// Change Password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          // Backend validation: 'new_password|confirmed' requires this field
          'new_password_confirmation': newPassword,
        },
      );
      
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  /// Delete Account
  Future<bool> deleteAccount() async {
    try {
      final response = await _apiClient.delete(ApiEndpoints.deleteAccount);
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error deleting account: $e');
      return false;
    }
  }

  /// Ambil profil penjual
  Future<Map<String, dynamic>?> getSellerProfile(int sellerId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.baseUrl}/sellers/$sellerId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['seller'];
      }
      return null;
    } catch (e) {
      print('Error fetching seller profile: $e');
      return null;
    }
  }
}
