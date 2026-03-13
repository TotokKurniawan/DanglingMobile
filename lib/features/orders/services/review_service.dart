import 'package:streetmarketid/core/network/api_client.dart';
import 'package:streetmarketid/core/network/api_endpoints.dart';

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

  Future<List<dynamic>?> getStoreReviews(int sellerId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.baseUrl}/sellers/$sellerId/reviews');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['reviews'] as List<dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting store reviews: $e');
      return null;
    }
  }

  Future<bool> replyToReview(int reviewId, String reply) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.baseUrl}/reviews/$reviewId/reply',
        data: {'seller_reply': reply},
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error replying to review: $e');
      return false;
    }
  }
}
