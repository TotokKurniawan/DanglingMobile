import 'package:streetmarketid/core/network/api_client.dart';
import 'package:streetmarketid/core/network/api_endpoints.dart';

class HomeApi {
  final ApiClient _apiClient = ApiClient();

  /// Ambil daftar pedagang online di sekitar lokasi user.
  ///
  /// [lat] & [lng] — koordinat GPS user (opsional, jika null server pakai lokasi default).
  /// [radiusKm]    — radius pencarian dalam kilometer (default 20 km).
  Future<List<Map<String, dynamic>>?> getOnlinePedagang({
    double? lat,
    double? lng,
    int radiusKm = 20,
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'radius': radiusKm,
        if (category != null && category != 'All') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiClient.get(
        ApiEndpoints.tampilSeluruhPedagang,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data['success'] == true) {
        final items = response.data['data']['items'] as List;

        return items.map<Map<String, dynamic>>((seller) {
          final products = seller['products'] as List?;
          return {
            'id': seller['id'],
            'user_id': seller['user_id'] ?? 0,
            'name': seller['store_name'] ?? 'Toko Tidak Bernama',
            'latitude': seller['latitude'] != null
                ? double.tryParse(seller['latitude'].toString())
                : 0.0,
            'longitude': seller['longitude'] != null
                ? double.tryParse(seller['longitude'].toString())
                : 0.0,
            'distance': seller['distance_km']?.toString() ?? '0.00',
            'fotoPedagang': seller['photo_url'] ?? '',
            'id_pedagang': seller['id'],
            'products': products ?? [],
          };
        }).toList();
      }
      return null;
    } catch (e) {
      print('Error fetching pedagang: $e');
      return null;
    }
  }
}
