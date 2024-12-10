import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sharedprovider with ChangeNotifier {
  String? _email;
  String? _nama;
  String? _role;
  String? _password;
  int? _idUser;
  int? _idPedagang; // Menambahkan id_pedagang
  String? _imagePath;
  String? _token;
  bool _showNotificationMenu = false;

  String? get email => _email;
  String? get nama => _nama;
  String? get role => _role;
  String? get password => _password;
  int? get idUser => _idUser;
  int? get idPedagang => _idPedagang;
  String? get imagePath => _imagePath;
  String? get token => _token;
  bool get showNotificationMenu => _showNotificationMenu;

  bool get isSeller => _role == 'pedagang';

  // Memuat profil dan token
  Future<void> loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _email = prefs.getString('email');
    _nama = prefs.getString('nama');
    _role = prefs.getString('role');
    _idUser = prefs.getInt('user_id');
    _idPedagang = prefs.getInt('id_pedagang'); // Periksa apakah nilai ini valid
    _imagePath = prefs.getString('imagePath');
    _token = prefs.getString('token');

    // Debugging
    print("Role: $_role");
    print("Token yang dimuat: $_token");
    print("idPedagang yang dimuat: $_idPedagang"); // Debugging

    _showNotificationMenu = _role == 'pedagang';
    notifyListeners();
  }

  // Menyimpan profil dan token
  Future<void> saveProfile(
    String email,
    String name,
    String role,
    String password,
    int idUser,
    int? idPedagang,
    String imagePath,
    String token,
  ) async {
    if (email.isEmpty || name.isEmpty || role.isEmpty || password.isEmpty) {
      print("Input tidak boleh kosong");
      return;
    }

    print("Menyimpan profil dengan idPedagang: $idPedagang"); // Debugging
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('nama', name);
    await prefs.setString('role', role);
    await prefs.setString('password', password);
    await prefs.setInt('user_id', idUser);
    if (idPedagang != null) {
      await prefs.setInt('id_pedagang', idPedagang);
    }
    await prefs.setString('imagePath', imagePath);
    await prefs.setString('token', token);

    _email = email;
    _nama = name;
    _role = role;
    _password = password;
    _idUser = idUser;
    _idPedagang = idPedagang;
    _imagePath = imagePath;
    _token = token;

    _showNotificationMenu = role == 'pedagang';

    notifyListeners();
  }

  // Menyimpan riwayat
  Future<void> saveHistory(String action) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];

    // Menambahkan aksi terbaru ke riwayat
    history.add(action);

    // Menyimpan kembali riwayat ke SharedPreferences
    await prefs.setStringList('history', history);
    print("Riwayat disimpan: $action");

    notifyListeners();
  }

  // Memuat riwayat
  Future<List<String>> loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    return history;
  }

  // Menghapus riwayat
  Future<void> clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    print("Riwayat dihapus");

    notifyListeners();
  }

  // Menyimpan gambar profil
  Future<void> saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/image.png';

    // Salin file gambar ke direktori aplikasi
    await imageFile.copy(imagePath);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('imagePath', imagePath);

    _imagePath = imagePath;

    print("Gambar berhasil disimpan di $imagePath");

    notifyListeners();
  }

  // Memuat gambar profil
  Future<File?> loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('imagePath');

    if (imagePath != null) {
      File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        return imageFile;
      } else {
        print("Gambar tidak ditemukan pada path $imagePath");
        return null;
      }
    } else {
      return null;
    }
  }

  // Menghapus profil
  Future<void> clearProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _email = null;
    _nama = null;
    _role = null;
    _password = null;
    _idUser = null;
    _idPedagang = null; // Menghapus id_pedagang
    _imagePath = null;
    _token = null;
    _showNotificationMenu = false;

    notifyListeners();
  }

  // Memperbarui peran pengguna
  Future<void> updateRole(String newRole) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', newRole);

    _role = newRole;
    _showNotificationMenu = newRole == 'pedagang';

    notifyListeners();
  }

  // Memuat peran pengguna
  Future<void> loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('role');
    _showNotificationMenu = _role == 'pedagang';
    notifyListeners();
  }

  // Memperbarui token
  Future<void> updateToken(String newToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);

    _token = newToken;

    print("Token diperbarui: $_token");

    notifyListeners();
  }

  // Memuat token
  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    // Debugging
    if (_token != null) {
      print("Token yang dimuat: $_token");
    } else {
      print("Token tidak ditemukan");
    }

    notifyListeners();
  }
}
