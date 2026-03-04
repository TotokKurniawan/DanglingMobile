import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../core/network/api_endpoints.dart';

class HomeApi {
  Future<List<Map<String, dynamic>>?> getOnlinePedagang(String token) async {
    final url = Uri.parse(ApiEndpoints.tampilSeluruhPedagang);

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        var position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        double userLatitude = position.latitude;
        double userLongitude = position.longitude;

        return List<Map<String, dynamic>>.from(
          responseData['data'].map((produk) {
            double distance = Geolocator.distanceBetween(
                  userLatitude,
                  userLongitude,
                  produk['latitude'] ?? userLatitude,
                  produk['longitude'] ?? userLongitude,
                ) /
                1000;

            return {
              "id": produk['id'],
              "name": produk['nama_produk'] ?? 'Nama produk tidak tersedia',
              "latitude": produk['latitude'] ?? userLatitude,
              "longitude": produk['longitude'] ?? userLongitude,
              "distance": distance.toStringAsFixed(2),
              "kategori_produk": produk['kategori_produk'] ?? '',
              "fotoProduk": produk['fotoProduk'] ?? '',
              "fotoPedagang": produk['fotoPedagang'] ?? '',
              "id_pedagang": produk['id_pedagang'],
              "hargaProduk": produk['hargaProduk'] ?? 0,
            };
          }),
        );
      } else if (response.statusCode == 404) {
        return [];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
