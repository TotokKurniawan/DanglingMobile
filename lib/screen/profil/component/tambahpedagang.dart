import 'dart:io';
import 'package:damping/navigation.dart';
import 'package:damping/service/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahPedagang extends StatefulWidget {
  const TambahPedagang({Key? key}) : super(key: key);

  @override
  _TambahPedagangState createState() => _TambahPedagangState();
}

class _TambahPedagangState extends State<TambahPedagang> {
  bool isSeller = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storePhoneController = TextEditingController();
  final TextEditingController _storeAddressController = TextEditingController();
  String? _imagePath;

  // Fungsi untuk mengambil gambar toko dari galeri atau kamera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _checkUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    setState(() {
      isSeller = role == 'pedagang';
    });
  }

  void _upgradeToSeller() async {
    final apiService = ApiService();

    try {
      bool success = await apiService.upgradeToSeller(
        namaToko: _storeNameController.text,
        telfon: _storePhoneController.text,
        alamat: _storeAddressController.text,
        foto: _imagePath != null && _imagePath!.isNotEmpty
            ? File(_imagePath!)
            : null,
      );

      if (success) {
        // Update SharedPreferences setelah upgrade berhasil
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', 'pedagang'); // Menyimpan role 'pedagang'

        // Update tampilan UI
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Navigation()),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan, silakan coba lagi.')),
      );
    }
  }

  // Fungsi untuk menampilkan form validasi
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _upgradeToSeller();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Akun Pedagang"),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
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
                  child: Center(
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: _imagePath != null
                          ? FileImage(File(_imagePath!))
                          : null,
                      backgroundColor: Colors.indigoAccent[100],
                      child: _imagePath == null
                          ? const Icon(Icons.add_a_photo,
                              color: Colors.white, size: 40)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextFormField(
                  controller: _storeNameController,
                  labelText: "Nama Toko",
                  icon: Icons.store,
                  validator: (value) =>
                      value!.isEmpty ? 'Silakan masukkan nama toko' : null,
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: _storePhoneController,
                  labelText: "No Telepon",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Silakan masukkan nomor telepon' : null,
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: _storeAddressController,
                  labelText: "Alamat",
                  icon: Icons.location_on,
                  validator: (value) => value!.isEmpty
                      ? 'Silakan masukkan alamat dengan benar!'
                      : null,
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: const Text("Submit", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk membuat input form yang lebih terstruktur
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.indigoAccent),
        filled: true,
        fillColor: Colors.indigoAccent.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.indigoAccent),
        ),
      ),
      validator: validator,
    );
  }
}
