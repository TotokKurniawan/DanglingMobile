import 'dart:io';
import 'package:dio/dio.dart';
import 'package:streetmarketid/core/network/api_client.dart';
import 'package:streetmarketid/core/network/api_endpoints.dart';

class ProductApi {
  final ApiClient _apiClient = ApiClient();

  /// Ambil seluruh produk milik seller yang sedang login
  Future<List<dynamic>?> getProducts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getProducts);

      if (response.statusCode == 200) {
        return response.data['data']['products'] as List<dynamic>;
      }
      return null;
    } on DioException catch (e) {
      print('Error getProducts: ${e.message}');
      return null;
    }
  }

  /// Hapus produk berdasarkan ID
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await _apiClient.delete('${ApiEndpoints.deleteProduk}$id');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error deleteProduct: ${e.message}');
      return false;
    }
  }

  /// Tambah produk baru (multipart — foto produk)
  Future<bool> tambahProduk({
    required String namaProduk,
    required String deskripsi,
    required int hargaProduk,
    required String kategoriProduk,
    required File foto,
  }) async {
    if (!await foto.exists()) return false;

    // Map kategori ke category_id
    int categoryId = 1;
    if (kategoriProduk == 'Makanan Ringan') categoryId = 1;
    if (kategoriProduk == 'Makanan Berat') categoryId = 2;
    if (kategoriProduk == 'Jasa') categoryId = 3;

    try {
      final formData = FormData.fromMap({
        'name': namaProduk,
        'description': deskripsi,
        'price': hargaProduk.toString(),
        'stock': '999',
        'category_id': categoryId.toString(),
        'photo': await MultipartFile.fromFile(foto.path, filename: foto.path.split('/').last),
      });

      final response = await _apiClient.post(
        ApiEndpoints.tambahProduk,
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('Error tambahProduk: ${e.message}');
      return false;
    }
  }

  /// Toggle status aktif produk
  Future<bool> toggleActive(int id) async {
    try {
      final response = await _apiClient.patch('${ApiEndpoints.baseUrl}/products/$id/toggle-active');
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error toggleActive: ${e.message}');
      return false;
    }
  }

  /// Update produk existing (mendukung multipart dengan _method spoofing)
  Future<bool> updateProduct({
    required int id,
    required String namaProduk,
    required String deskripsi,
    required int hargaProduk,
    required String kategoriProduk,
    File? foto,
  }) async {
    int categoryId = 1;
    if (kategoriProduk == 'Makanan Ringan') categoryId = 1;
    if (kategoriProduk == 'Makanan Berat') categoryId = 2;
    if (kategoriProduk == 'Jasa') categoryId = 3;

    try {
      final dataMap = {
        'name': namaProduk,
        'description': deskripsi,
        'price': hargaProduk.toString(),
        'category_id': categoryId.toString(),
        '_method': 'PUT', // Laravel method spoofing
      };

      if (foto != null && await foto.exists()) {
        dataMap['photo'] = await MultipartFile.fromFile(foto.path, filename: foto.path.split('/').last);
      }

      final formData = FormData.fromMap(dataMap);

      final response = await _apiClient.post(
        '${ApiEndpoints.baseUrl}/products/$id', // Always POST for spoofing
        data: formData,
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error updateProduct: ${e.message}');
      return false;
    }
  }
}
