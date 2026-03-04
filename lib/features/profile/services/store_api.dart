import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_endpoints.dart';

class StoreApi {
  Future<bool> upgradeToSeller({
    required String namaToko,
    required String telfon,
    required String alamat,
    File? foto,
  }) async {
    final url = Uri.parse(ApiEndpoints.upgradeToSeller);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? userId = prefs.getInt('user_id');
    String? token = prefs.getString('token');

    if (userId == null || token == null) return false;

    try {
      var request = http.MultipartRequest('POST', url)
        ..headers.addAll({'Authorization': 'Bearer $token'});

      request.fields['user_id'] = userId.toString();
      request.fields['namaToko'] = namaToko;
      request.fields['telfon'] = telfon;
      request.fields['alamat'] = alamat;

      if (foto != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', foto.path));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final data = jsonDecode(responseData.body);

        if (data['success'] ?? false) {
          int? idPedagang = data['pedagang']?['id'];
          if (idPedagang != null) await prefs.setInt('id_pedagang', idPedagang);
          return true;
        }
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> getStoreStatus() async {
    try {
      final url = Uri.parse(ApiEndpoints.getStoreStatus);
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isOnline'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStatus(bool isOnline) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    String? token = prefs.getString('token');

    if (userId == null || token == null) return false;

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.updateStatus),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'status': isOnline ? 'online' : 'offline',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'];
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkLocation({required double latitude, required double longitude}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null || token.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.checkLocation),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
