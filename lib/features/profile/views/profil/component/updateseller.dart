import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:streetmarketid/core/providers/sharedProvider.dart';
import 'package:streetmarketid/features/profile/services/profile_service.dart';

class UpdateSellerForm extends StatefulWidget {
  @override
  _UpdateSellerFormState createState() => _UpdateSellerFormState();
}

class _UpdateSellerFormState extends State<UpdateSellerForm> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();

  String? storeName;
  String? phoneNumber;
  String? address;
  String? currentPhotoUrl;
  File? _newImage;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSellerProfile();
  }

  Future<void> _loadCurrentSellerProfile() async {
    final sharedProvider = Provider.of<Sharedprovider>(context, listen: false);
    final sellerId = sharedProvider.idPedagang;

    if (sellerId != null) {
      final data = await _profileService.getSellerProfile(sellerId);
      if (data != null && mounted) {
        setState(() {
          storeName = data['store_name'];
          phoneNumber = data['phone'];
          address = data['address'];
          currentPhotoUrl = data['photo_url'];
          _isLoading = false;
        });
        return;
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat profil toko. Coba lagi.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateSellerProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final sharedProvider = Provider.of<Sharedprovider>(context, listen: false);
      final sellerId = sharedProvider.idPedagang;

      if (sellerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data penjual tidak valid!')));
        return;
      }

      setState(() => _isSaving = true);

      final result = await _profileService.updateSellerProfile(
        sellerId,
        storeName ?? '',
        phoneNumber ?? '',
        address ?? '',
        imagePath: _newImage?.path,
      );

      setState(() => _isSaving = false);

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil Toko berhasil diperbarui!')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui profil toko.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil Toko",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigoAccent, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Foto Profil Toko
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey.shade300,
                                    backgroundImage: _newImage != null
                                        ? FileImage(_newImage!)
                                        : (currentPhotoUrl != null
                                                ? NetworkImage(currentPhotoUrl!)
                                                : null)
                                            as ImageProvider?,
                                    child: (_newImage == null && currentPhotoUrl == null)
                                        ? const Icon(Icons.store,
                                            size: 50, color: Colors.white)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.indigoAccent,
                                      child: const Icon(Icons.camera_alt,
                                          size: 18, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('Ketuk foto untuk ganti',
                                style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 24),

                            // Input Nama Toko
                            TextFormField(
                              initialValue: storeName,
                              decoration: const InputDecoration(
                                labelText: 'Nama Toko',
                                hintText: 'Masukkan nama toko Anda',
                                prefixIcon: Icon(Icons.storefront),
                                border: OutlineInputBorder(),
                              ),
                              onSaved: (newValue) => storeName = newValue,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama toko tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Input Nomor Telepon
                            TextFormField(
                              initialValue: phoneNumber,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Telepon / WhatsApp',
                                hintText: 'Contoh: 08123456789',
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(),
                              ),
                              onSaved: (newValue) => phoneNumber = newValue,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nomor telepon tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Input Alamat
                            TextFormField(
                              initialValue: address,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Alamat Toko',
                                hintText: 'Masukkan detail alamat toko',
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(bottom: 30),
                                  child: Icon(Icons.location_on),
                                ),
                                border: OutlineInputBorder(),
                              ),
                              onSaved: (newValue) => address = newValue,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Alamat tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Tombol Update
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigoAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isSaving ? null : _updateSellerProfile,
                                child: _isSaving
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'Simpan Perubahan',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
