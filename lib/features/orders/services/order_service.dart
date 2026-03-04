import 'package:damping/core/network/api_client.dart';
import 'package:damping/core/network/api_endpoints.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>?> createOrder(Map<String, dynamic> payload) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createOrder,
        data: payload,
      );

      if (response.data['success'] == true) {
        return response.data['data']['order'];
      }
      return null;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  Future<bool> confirmPayment(int orderId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        '_method': 'PUT', // Laravel method spoofing untuk multipart PUT
        'payment_proof': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final endpoint = '${ApiEndpoints.baseUrl}/orders/$orderId/confirm-payment';

      // Kirim sebagai POST dengan _method=PUT (Laravel method spoofing)
      final response = await _apiClient.post(endpoint, data: formData);

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error confirmPayment: $e');
      return false;
    }
  }

  Future<List<dynamic>?> getOrderHistory({String role = 'buyer'}) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.orderHistory}?role=$role');
      if (response.data['success'] == true) {
        // The API returns { "role": "pembeli", "orders": [...] }
        return response.data['data']['orders'] as List<dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching order history: $e');
      return null;
    }
  }

  Future<bool> reorder(int orderId) async {
    try {
      final response = await _apiClient.post('${ApiEndpoints.baseUrl}/orders/$orderId/reorder');
      if (response.statusCode == 201 && response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error reordering: $e');
      return false;
    }
  }

  Future<List<dynamic>?> getPendingOrders() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.pendingOrders);
      if (response.data['success'] == true) {
        return response.data['data']['orders'] as List<dynamic>? ?? [];
      }
      return null;
    } catch (e) {
      print('Error fetching pending orders: $e');
      return null;
    }
  }

  Future<bool> updateOrderStatus(int orderId, String action) async {
    // action: 'accept', 'reject', 'complete', 'cancel'
    try {
      final response = await _apiClient.put('${ApiEndpoints.baseUrl}/orders/$orderId/$action');
      return response.data['success'] == true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
}

