import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://38aa-180-248-34-255.ngrok-free.app/api';

  Future<List<Map<String, dynamic>>?> getOnlinePedagang(
      String baseUrl, String token) async {
    final url = Uri.parse('$baseUrl/tampilSeluruhPedagang');

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
        print("Data pedagang online berhasil diambil: ${responseData['data']}");

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
        print("Pesan dari server: ${jsonDecode(response.body)['message']}");
        return [];
      } else {
        print("Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
      return null;
    }
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

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

          // Simpan data pengguna
          await prefs.setString('email', email);
          await prefs.setString('nama', data['user']['nama'] ?? '');
          await prefs.setString('role', data['user']['role'] ?? '');
          await prefs.setInt('user_id', data['user']['id'] ?? 0);

          // Periksa token dan simpan
          if (data.containsKey('token') &&
              data['token'] != null &&
              data['token'].isNotEmpty) {
            await prefs.setString('token', data['token']);
            print("Token berhasil disimpan: ${data['token']}");
          } else {
            print("Token tidak ditemukan di respons");
          }

          print("Login berhasil");
          return true;
        } else {
          print("Login gagal: ${data['error']}");
          return false;
        }
      } else {
        print("Kesalahan server: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/sign_up'));

      // Hanya mengirimkan email dan password
      request.fields['email'] = email;
      request.fields['password'] = password;

      request.headers["Content-Type"] = "multipart/form-data";

      var response = await request.send();

      if (response.statusCode == 201) {
        final responseData = await http.Response.fromStream(response);
        final data = jsonDecode(responseData.body);
        if (data['success']) {
          print("Registration successful");
          return true;
        } else {
          print("Registration failed: ${data['error']}");
          return false;
        }
      } else {
        print("Server error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> logout() async {
    final url = Uri.parse('$baseUrl/logout');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ambil token dari SharedPreferences
    String? token = prefs.getString('token');
    if (token == null) {
      print("Token tidak ditemukan");
      return false;
    }

    try {
      // Mengirimkan permintaan POST dengan token di header
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Logout berhasil, hapus token dari SharedPreferences
        await prefs.remove('token');
        await prefs.remove('email');
        await prefs.remove('nama');
        await prefs.remove('role');
        await prefs.remove('id_user');

        print("Logout berhasil");
        return true;
      } else {
        print("Gagal logout: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> upgradeToSeller({
    required String namaToko,
    required String telfon,
    required String alamat,
    File? foto,
  }) async {
    final url = Uri.parse('$baseUrl/upgradeToSeller');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? userId = prefs.getInt('user_id');
    String? token = prefs.getString('token');

    if (userId == null || token == null) {
      print("No user ID or token found.");
      return false;
    }

    try {
      var request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token', // Menambahkan token di header
        });

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

        // Debugging: Tampilkan data respons
        print("Response data: $data");

        if (data['success'] ?? false) {
          // Simpan id_pedagang ke SharedPreferences jika tersedia
          int? idPedagang = data['pedagang']?['id'];
          if (idPedagang != null) {
            await prefs.setInt('id_pedagang', idPedagang);
            print("id_pedagang berhasil disimpan: $idPedagang");
          } else {
            print("id_pedagang tidak ditemukan dalam respons.");
          }

          return true;
        } else {
          print("Upgrade to seller failed: ${data['message']}");
          return false;
        }
      } else {
        print("Server error: ${response.statusCode}");
        print("Error details: ${await response.stream.bytesToString()}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> getStoreStatus() async {
    try {
      final url = Uri.parse('$baseUrl/getStoreStatus');

      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Menyesuaikan dengan struktur response Laravel
        return data['isOnline'] == true;
      } else {
        print("Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('Gagal mengambil status toko');
    }
  }

  Future<bool> updateStatus(bool isOnline) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    String? token = prefs.getString('token'); // Mengambil token

    if (userId == null || token == null) {
      print("No user ID or token found.");
      return false;
    }

    final url = Uri.parse('$baseUrl/updateStatus');

    try {
      final response = await http.post(
        url,
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
        if (data['success']) {
          print("Store status updated successfully");
          return true;
        } else {
          print("Failed to update status: ${data['message']}");
          return false;
        }
      } else {
        print("Server error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> checkLocation({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$baseUrl/checkLocation');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ambil token dari SharedPreferences
    String? token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      print("Token tidak ditemukan");
      return false;
    }

    try {
      final response = await http.post(
        url,
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
        if (data['success'] == true) {
          print("Lokasi valid: ${data['message']}");
          return true;
        } else {
          print("Lokasi tidak valid: ${data['message']}");
          return false;
        }
      } else {
        print("Gagal mengecek lokasi: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> tambahProduk({
    required String namaProduk,
    required int hargaProduk,
    required String kategoriProduk,
    required File foto,
  }) async {
    final url = Uri.parse('$baseUrl/tambahProduk');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('user_id');
    int? idPedagang = prefs.getInt('id_pedagang');

    if (token == null || token.isEmpty || !token.contains('.')) {
      print("Token dikirim: $token");
      return false;
    }

    if (userId == null) {
      print("User ID tidak ditemukan");
      return false;
    }

    if (!await foto.exists()) {
      print("Foto tidak valid.");
      return false;
    }

    final data = {
      'nama_produk': namaProduk,
      'harga_produk': hargaProduk.toString(),
      'kategori_produk': kategoriProduk,
      'id_pedagang': idPedagang.toString(),
    };

    try {
      var request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
        })
        ..fields.addAll(data);

      var fotoFile = await http.MultipartFile.fromPath('foto', foto.path);
      request.files.add(fotoFile);

      var response = await request.send();

      if (response.statusCode == 201) {
        print("Produk berhasil ditambahkan");
        return true;
      } else {
        print("Gagal menambahkan produk: ${response.statusCode}");

        response.stream.transform(utf8.decoder).listen((value) {
          final responseData = jsonDecode(value);
          print("Pesan error dari server: ${responseData['message']}");
        });

        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<List<dynamic>> orderHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("Token tidak ditemukan, silakan login terlebih dahulu.");
    }

    final String apiUrl = '$baseUrl/orderHistory';

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final role = data['role']; // Mengambil informasi role pengguna
          final historyData = data['data']; // Mengambil data histori pesanan

          // Debugging log
          print("Role pengguna: $role");
          print("Data histori: $historyData");

          return historyData; // Mengembalikan data histori pesanan
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception(
            "Gagal memuat histori pesanan. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Terjadi kesalahan saat memuat histori pesanan.");
    }
  }
}
