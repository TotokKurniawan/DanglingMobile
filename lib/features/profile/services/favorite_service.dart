import 'package:damping/core/network/api_client.dart';
import 'package:damping/core/network/api_endpoints.dart';

class FavoriteService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>?> getFavorites() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.favorites);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['favorites'] as List<dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching favorites: $e');
      return null;
    }
  }

  Future<bool> addToFavorites(int sellerId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.favorites,
        data: {'seller_id': sellerId},
      );
      return response.statusCode == 201 && response.data['success'] == true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(int sellerId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.favorites}/$sellerId',
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }
}
