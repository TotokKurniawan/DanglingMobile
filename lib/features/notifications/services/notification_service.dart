import 'package:streetmarketid/core/network/api_client.dart';
import 'package:streetmarketid/core/network/api_endpoints.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>?> getNotifications() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.notifications);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['notifications'] as List<dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching notifications: $e');
      return null;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.unreadNotificationsCount);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['unread_count'] as int;
      }
      return 0;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiClient.put('${ApiEndpoints.notifications}/$notificationId/read');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
}
