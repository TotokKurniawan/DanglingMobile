import 'package:damping/core/network/api_client.dart';
import 'package:damping/core/network/api_endpoints.dart';

class HomeApi {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>?> getOnlinePedagang(String token, {double? lat, double? lng}) async {
    try {
      final queryParams = {
         if (lat != null) 'lat': lat,
         if (lng != null) 'lng': lng,
         'radius': 20
      };

      final response = await _apiClient.get(
        ApiEndpoints.tampilSeluruhPedagang,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data['success'] == true) {
        final items = response.data['data']['items'] as List;
        
        List<Map<String, dynamic>> flatList = [];
        for (var seller in items) {
          final products = seller['products'] as List?;

          flatList.add({
            "id": seller['id'],
            "user_id": seller['user_id'] ?? 0,
            "name": seller['store_name'] ?? 'Toko Tidak Bernama', 
            "latitude": seller['latitude'] != null ? double.tryParse(seller['latitude'].toString()) : 0.0,
            "longitude": seller['longitude'] != null ? double.tryParse(seller['longitude'].toString()) : 0.0,
            "distance": seller['distance_km']?.toString() ?? '0.00',
            "fotoPedagang": seller['photo_url'] ?? '',
            "id_pedagang": seller['id'],
            "products": products ?? [],
          });
        }
        return flatList;
      }
      return null;
    } catch (e) {
      print('Error fetching pedagang: $e');
      return null;
    }
  }
}


