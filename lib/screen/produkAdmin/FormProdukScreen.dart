import 'dart:io';
import 'package:damping/service/sharedProvider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/ApiService.dart';

class FormProdukScreen extends StatefulWidget {
  static String routeName = "/FormProdukScreen";

  @override
  _FormProdukScreenState createState() => _FormProdukScreenState();
}

class _FormProdukScreenState extends State<FormProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _selectedImage; // Only one image will be selected
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  String? _selectedCategory;
  List<String> _categories = [
    'Makanan Ringan',
    'Makanan Berat',
    'Jasa',
  ];

  @override
  void initState() {
    super.initState();
    _loadProductData();
    Provider.of<Sharedprovider>(context, listen: false).loadToken();
  }

  Future<void> _loadProductData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('last_product_name') ?? '';
      _descriptionController.text =
          prefs.getString('last_product_description') ?? '';
      _priceController.text = prefs.getString('last_product_price') ?? '';
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImage != null) {
      print('[INFO] Hanya satu gambar yang dapat dipilih.');
      _showSnackbar('Anda hanya bisa memilih satu gambar');
      return;
    }

    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      print('[INFO] Gambar berhasil dipilih: ${pickedFile.path}');
    } else {
      print('[WARN] Pengguna membatalkan pemilihan gambar.');
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      print('[WARN] Form belum valid atau kategori belum dipilih.');
      _showSnackbar("Pastikan semua data dan kategori produk telah diisi.");
      return;
    }

    final name = _nameController.text;
    final description = _descriptionController.text;
    final price = _priceController.text;

    setState(() {
      isLoading = true;
    });

    try {
      String? token = Provider.of<Sharedprovider>(context, listen: false).token;
      if (token == null || token.isEmpty) {
        print('[ERROR] Token tidak ditemukan.');
        _showSnackbar('Token tidak ditemukan. Harap login ulang.');
        return;
      }

      print('[INFO] Mengirim produk ke server dengan data: '
          'Nama: $name, Harga: $price, Kategori: $_selectedCategory');
      bool success = await _apiService.tambahProduk(
        namaProduk: name,
        hargaProduk: int.parse(price),
        kategoriProduk: _selectedCategory!,
        foto: _selectedImage != null ? _selectedImage! : File(''),
      );

      if (success) {
        print('[SUCCESS] Produk $name berhasil ditambahkan.');
        _saveProductDataToSharedPreferences(name, description, price);
        _showSnackbar('Produk $name berhasil ditambahkan!');
        _clearForm();
      } else {
        print('[ERROR] Gagal menambahkan produk.');
        _showSnackbar(
            'Gagal menambahkan produk. Coba periksa koneksi atau ulangi.');
      }
    } catch (e) {
      print('[ERROR] Terjadi kesalahan saat mengirim produk: $e');
      _showSnackbar('Terjadi kesalahan. Silakan coba lagi nanti.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveProductDataToSharedPreferences(
      String name, String description, String price) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_product_name', name);
    await prefs.setString('last_product_description', description);
    await prefs.setString('last_product_price', price);
    print('[INFO] Data produk disimpan ke SharedPreferences.');
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _selectedImage = null;
      _selectedCategory = null;
    });
    print('[INFO] Form berhasil direset.');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Produk"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(83, 109, 254, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                _buildTextFormField(
                  controller: _nameController,
                  labelText: "Nama Produk",
                  icon: Icons.store,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nama produk tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextFormField(
                  controller: _descriptionController,
                  labelText: "Deskripsi Produk",
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Deskripsi produk tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _buildTextFormField(
                  controller: _priceController,
                  labelText: "Harga Produk",
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Harga produk tidak boleh kosong";
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return "Harga produk harus berupa angka yang lebih besar dari 0";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Kategori Produk",
                    icon: Icon(Icons.category),
                  ),
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Kategori produk tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library),
                      label: Text('Galeri'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.camera_alt),
                      label: Text('Kamera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Simpan Produk"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int? maxLines,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        icon: Icon(icon),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
