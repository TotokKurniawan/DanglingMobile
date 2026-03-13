import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streetmarketid/core/providers/sharedProvider.dart';
import 'package:streetmarketid/features/profile/services/profile_service.dart';

class UpdateProfileForm extends StatefulWidget {
  @override
  _UpdateProfileFormState createState() => _UpdateProfileFormState();
}

class _UpdateProfileFormState extends State<UpdateProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  
  String? name;
  String? email; // email is usually non-editable or requires complex validation. We'll show it as read-only.
  String? phoneNumber;
  String? alamat;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize form values from SharedProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sharedProvider = Provider.of<Sharedprovider>(context, listen: false);
      setState(() {
        name = sharedProvider.nama;
        email = sharedProvider.email;
        // Assume phone and address are not fully mapped in provider yet or we just let user input them if empty
      });
    });
  }

  // Validasi dan simpan data ketika tombol 'Update' ditekan
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final sharedProvider = Provider.of<Sharedprovider>(context, listen: false);
      // Backend: Buyer::find($id) → id adalah primary key tabel buyers (bukan user_id)
      // idPedagang disimpan saat login (buyer) atau upgrade ke seller (seller)
      final buyerId = sharedProvider.idPedagang;

      if (buyerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data pembeli tidak ditemukan. Coba login ulang.')));
        return;
      }

      setState(() => _isLoading = true);

      final result = await _profileService.updateBuyerProfile(
        buyerId, 
        name ?? '', 
        phoneNumber ?? '', 
        alamat ?? ''
      );

      setState(() => _isLoading = false);

      if (mounted) {
        if (result != null) {
          // Update provider with new name
          sharedProvider.saveProfile(
            email ?? '',
            name ?? '',
            sharedProvider.role ?? 'buyer',
            sharedProvider.password ?? '',
            buyerId,
            sharedProvider.idPedagang,
            sharedProvider.imagePath ?? '',
            sharedProvider.token ?? '',
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui profil.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
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
                      // Input Nama
                      TextFormField(
                        initialValue: name,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          hintText: 'Masukkan nama Anda',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (newValue) => name = newValue,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Input Email (Read Only essentially or just info)
                      TextFormField(
                        initialValue: email,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: const OutlineInputBorder(),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Input Nomor Telepon
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon',
                          hintText: 'Contoh: 081234567890',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        onSaved: (newValue) => phoneNumber = newValue,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor telepon wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Input Alamat
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Alamat Lengkap',
                          hintText: 'Cth: Jl. Merdeka No.1',
                          prefixIcon: Icon(Icons.home),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onSaved: (newValue) => alamat = newValue,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Alamat wajib diisi';
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
                          onPressed: _isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.indigoAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
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
