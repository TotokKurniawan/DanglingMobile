import 'package:damping/service/sharedProvider.dart';
import 'package:flutter/material.dart';
import 'package:damping/GradientBackground.dart';
import 'package:damping/screen/sign_in/sign_in_screen.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'component/helpcenter.dart';
import 'component/myaccount.dart';
import 'component/mystore.dart';
import 'component/profilmenu.dart';
import 'component/tambahpedagang.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/Menu";

  const ProfileScreen({Key? key}) : super(key: key);

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      // Melakukan sesuatu dengan gambar yang dipilih
    }
  }

  void _checkStoreRegistration(BuildContext context, String role) {
    if (role == 'pembeli') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Akun Pedagang"),
            content: const Text(
                "Anda belum mempunyai akun pedagang. Apakah Anda ingin membuatnya?"),
            actions: <Widget>[
              TextButton(
                child: const Text("Tidak"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text("Ya"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TambahPedagang()),
                  );
                },
              ),
            ],
          );
        },
      );
    } else if (role == 'pedagang') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyStoreScreen()),
      );
    } else {
      print("Role tidak dikenali: $role");
    }
  }

  Future<void> _logout(BuildContext context) async {
    // Mengambil instance SharedPreferences untuk menghapus data yang disimpan
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Menghapus semua data yang disimpan di SharedPreferences
    await prefs.clear();

    // Mengosongkan cache yang disimpan menggunakan DefaultCacheManager
    await DefaultCacheManager().emptyCache();

    // Setelah logout, ganti halaman ke SignInScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Consumer<Sharedprovider>(
      builder: (context, sharedProvider, child) {
        // Mendapatkan role dan token dari SharedProvider
        String? role = sharedProvider.role;
        String? token = sharedProvider.token; // Pastikan ada getter untuk token

        return Scaffold(
          body: GradientBackground(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        builder: (BuildContext context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(Icons.photo_library,
                                      color: Colors.indigoAccent),
                                  title: const Text('Pilih dari galeri'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.gallery);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.camera_alt,
                                      color: Colors.indigoAccent),
                                  title: const Text('Ambil foto'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage(ImageSource.camera);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.indigoAccent[100],
                      child: const Icon(Icons.add_a_photo,
                          color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ProfileMenu(
                    text: "Akun Saya",
                    icon: Icons.account_circle,
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyAccountScreen()),
                      );
                    },
                  ),
                  ProfileMenu(
                    text: "Toko Saya",
                    icon: Icons.store,
                    press: () => _checkStoreRegistration(context, role ?? ''),
                  ),
                  ProfileMenu(
                    text: "Pusat Bantuan",
                    icon: Icons.help,
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HelpCenterScreen()),
                      );
                    },
                  ),
                  ProfileMenu(
                    text: "Token Saya",
                    icon: Icons.lock,
                    press: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Token Anda'),
                            content: Text(token ?? 'Token tidak ditemukan'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Tutup'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  ProfileMenu(
                    text: "Keluar",
                    icon: Icons.logout,
                    press: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              'Keluar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content:
                                const Text('Apakah Anda yakin ingin keluar?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _logout(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                ),
                                child: const Text('Keluar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
