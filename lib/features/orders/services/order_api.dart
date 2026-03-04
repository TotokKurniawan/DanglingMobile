import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_endpoints.dart';

class OrderApi {
  Future<List<dynamic>> orderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login terlebih dahulu.");
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(ApiEndpoints.orderHistory), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          return data['data']; // Mengembalikan data histori pesanan
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception("Gagal memuat histori pesanan. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat memuat histori pesanan.");
    }
  }
}
