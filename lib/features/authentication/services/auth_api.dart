import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_endpoints.dart';

class AuthApi {
  Future<bool> login(String email, String password) async {
    final url = Uri.parse(ApiEndpoints.login);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString('email', email);
          await prefs.setString('nama', data['user']['nama'] ?? '');
          await prefs.setString('role', data['user']['role'] ?? '');
          await prefs.setInt('user_id', data['user']['id'] ?? 0);

          if (data.containsKey('token') &&
              data['token'] != null &&
              data['token'].isNotEmpty) {
            await prefs.setString('token', data['token']);
          }
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiEndpoints.register));
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.headers["Content-Type"] = "multipart/form-data";

      var response = await request.send();

      if (response.statusCode == 201) {
        final responseData = await http.Response.fromStream(response);
        final data = jsonDecode(responseData.body);
        return data['success'];
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logout() async {
    final url = Uri.parse(ApiEndpoints.logout);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');
    if (token == null) return false;

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('email');
        await prefs.remove('nama');
        await prefs.remove('role');
        await prefs.remove('id_user');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
