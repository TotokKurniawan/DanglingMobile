import 'package:dio/dio.dart';
import 'package:streetmarketid/core/network/api_client.dart';
import 'package:streetmarketid/core/network/api_endpoints.dart';

class OrderApi {
  final ApiClient _apiClient = ApiClient();

  /// Ambil riwayat pesanan pembeli yang sedang login
  Future<List<dynamic>> orderHistory() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.orderHistory);

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Backend mengembalikan: { data: { role: '...', orders: [...] } }
        return response.data['data']['orders'] as List<dynamic>? ?? [];
      }

      throw Exception(response.data['message'] ?? 'Gagal memuat histori pesanan.');
    } on DioException catch (e) {
      throw Exception('Terjadi kesalahan saat memuat histori pesanan: ${e.message}');
    }
  }

}
