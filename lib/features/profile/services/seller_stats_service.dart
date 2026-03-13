import 'package:streetmarketid/core/network/api_client.dart';
import 'package:streetmarketid/core/network/api_endpoints.dart';

class SellerStatsService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> getSellerStats() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getSellerStats);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['stats'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching seller stats: $e');
      return null;
    }
  }
}
