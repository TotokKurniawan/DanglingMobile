import 'package:damping/core/providers/sharedProvider.dart';
import 'package:flutter/material.dart';
import 'package:damping/core/widgets/GradientBackground.dart';
import 'package:damping/features/authentication/views/sign_in/sign_in_screen.dart';
import 'package:damping/features/authentication/services/auth_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'component/helpcenter.dart';
import 'component/myaccount.dart';
import 'component/mystore.dart';
import 'component/profilmenu.dart';
import 'component/tambahpedagang.dart';
import 'package:damping/features/profile/views/profil/wishlist_screen.dart';
import 'package:damping/features/profile/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  static String routeName = "/Menu";

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  bool _isUploadingPhoto = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      if (mounted) {
        setState(() => _isUploadingPhoto = true);
      }

      final result = await _profileService.uploadPhoto(pickedFile.path);

      if (mounted) {
        setState(() => _isUploadingPhoto = false);

        if (result != null && result['photo_path'] != null) {
          final sharedProvider = Provider.of<Sharedprovider>(context, listen: false);
          // Assuming the returned path is full URL or we just save what API gives.
          // In standard, API returns full URL or relative path.
          sharedProvider.saveProfile(
            sharedProvider.email ?? '',
            sharedProvider.nama ?? '',
            sharedProvider.role ?? 'buyer',
            sharedProvider.password ?? '',
            sharedProvider.idUser ?? 0,
            sharedProvider.idPedagang,
            result['photo_path'], // Update the new photo path!
            sharedProvider.token ?? '',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diunggah!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengunggah foto.')),
          );
        }
      }
    }
  }

  void _checkStoreRegistration(BuildContext context, String role) {
    if (role == 'pembeli' || role == '') {
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
    } else if (role == 'pedagang' || role == 'seller') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyStoreScreen()),
      );
    } else {
      print("Role tidak dikenali: $role");
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Coba logout melalui API terlebih dahulu
      await _authService.logout();
    } catch (e) {
      print('Logout API failure: $e');
    }

    // Mengambil instance SharedPreferences untuk menghapus data yang disimpan
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Menghapus semua data yang disimpan di SharedPreferences
    await prefs.clear();

    // Mengosongkan cache yang disimpan menggunakan DefaultCacheManager
    await DefaultCacheManager().emptyCache();

    // Clear provider context as well
    if (mounted) {
      Provider.of<Sharedprovider>(context, listen: false).clearProfile();
      // Setelah logout, ganti halaman ke SignInScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Sharedprovider>(
      builder: (context, sharedProvider, child) {
        // Mendapatkan role dan token dari SharedProvider
        String? role = sharedProvider.role;
        String? token = sharedProvider.token;
        String? name = sharedProvider.nama;
        String? email = sharedProvider.email;

        return Scaffold(
          body: GradientBackground(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isUploadingPhoto ? null : () {
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.indigoAccent[100],
                          backgroundImage: sharedProvider.imagePath != null && sharedProvider.imagePath!.isNotEmpty
                              ? NetworkImage('http://127.0.0.1:8000/storage/${sharedProvider.imagePath}')
                              : null,
                          child: sharedProvider.imagePath == null || sharedProvider.imagePath!.isEmpty
                              ? const Icon(Icons.add_a_photo, color: Colors.white, size: 40)
                              : null,
                        ),
                        if (_isUploadingPhoto)
                          Container(
                            width: 110,
                            height: 110,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black45,
                            ),
                            child: const CircularProgressIndicator(color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name ?? "Pengguna",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    email ?? "Email belum diatur",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
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
                    text: "Toko Favorit",
                    icon: Icons.favorite,
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WishlistScreen()),
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
                                onPressed: () {
                                  Navigator.pop(context);
                                  _logout(context);
                                },
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
