import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_endpoints.dart';

class ProductApi {
  Future<bool> tambahProduk({
    required String namaProduk,
    required int hargaProduk,
    required String kategoriProduk,
    required File foto,
  }) async {
    final url = Uri.parse(ApiEndpoints.tambahProduk);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('user_id');
    int? idPedagang = prefs.getInt('id_pedagang');

    if (token == null || token.isEmpty || !token.contains('.')) return false;
    if (userId == null) return false;
    if (!await foto.exists()) return false;

    final data = {
      'nama_produk': namaProduk,
      'harga_produk': hargaProduk.toString(),
      'kategori_produk': kategoriProduk,
      'id_pedagang': idPedagang.toString(),
    };

    try {
      var request = http.MultipartRequest('POST', url)
        ..headers.addAll({'Authorization': 'Bearer $token'})
        ..fields.addAll(data);

      request.files.add(await http.MultipartFile.fromPath('foto', foto.path));

      var response = await request.send();

      if (response.statusCode == 201) {
        return true;
      } else {
        response.stream.transform(utf8.decoder).listen((value) {
          final responseData = jsonDecode(value);
          print("Pesan error dari server: ${responseData['message']}");
        });
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
