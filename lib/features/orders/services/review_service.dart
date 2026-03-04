import 'package:damping/core/network/api_client.dart';
import 'package:damping/core/network/api_endpoints.dart';

class ReviewService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> submitReview({
    required int orderId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.submitReview,
        data: {
          'order_id': orderId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );

      return response.statusCode == 201 && response.data['success'] == true;
    } catch (e) {
      print('Error submitting review: $e');
      return false;
    }
  }

  Future<bool> submitComplaint({
    required int orderId,
    required int sellerId,
    required int rating,
    required String description,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.submitComplaint,
        data: {
          'order_id': orderId,
          'seller_id': sellerId,
          'rating': rating,
          'description': description,
        },
      );

      return response.statusCode == 201 && response.data['success'] == true;
    } catch (e) {
      print('Error submitting complaint: $e');
      return false;
    }
  }
}
