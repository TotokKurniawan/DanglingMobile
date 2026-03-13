import 'package:streetmarketid/core/network/api_client.dart';
import 'package:streetmarketid/core/network/api_endpoints.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  // 1. Dapatkan semua daftar percakapan
  Future<List<dynamic>?> getConversations() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.chat);
      if (response.data['success'] == true) {
        return response.data['data']['conversations'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching conversations: $e');
      return null;
    }
  }

  // 2. Dapatkan detail pesan dalam satu percakapan
  Future<List<dynamic>?> getMessages(int conversationId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.chat}/$conversationId');
      if (response.data['success'] == true) {
        // Respons memiliki 'conversation_id' dan 'messages'
        return response.data['data']['messages'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching messages: $e');
      return null;
    }
  }

  // 3. Mulai chat baru berdasarkan ID user
  Future<int?> createConversation(int partnerUserId) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.chat,
        data: {'partner_user_id': partnerUserId},
      );
      if (response.statusCode == 201 && response.data['success'] == true) {
        return response.data['data']['conversation_id'] as int;
      }
      return null;
    } catch (e) {
      print('Error creating conversation: $e');
      return null;
    }
  }

  // 4. Kirim pesan ke percakapan tertentu
  Future<bool> sendMessage(int conversationId, String messageText) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.chat}/$conversationId',
        data: {'message': messageText},
      );
      if (response.statusCode == 201 && response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }
}
