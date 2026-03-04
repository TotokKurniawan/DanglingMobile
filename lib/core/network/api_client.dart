import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Tambahkan token otorisasi ke setiap request
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? token = prefs.getString('token');
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Jika mendapat error 401 Unauthorized, mungkin bisa menambahkan logika auto-logout
          if (e.response?.statusCode == 401) {
            // Bisa menambahkan pengiriman event broadcast atau pemanggilan provider logout
            print('Token expired or unauthorized');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // GET request
  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(String url, {dynamic data}) async {
    try {
      final response = await _dio.post(url, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(String url, {dynamic data}) async {
    try {
      final response = await _dio.put(url, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(String url) async {
    try {
      final response = await _dio.delete(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
