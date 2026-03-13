import 'package:flutter/material.dart';
import 'package:streetmarketid/features/authentication/services/auth_service.dart';


class ResetPasswordScreen extends StatefulWidget {
  static String routeName = "/reset_password";

  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  String? email;
  String? token;
  String? password;
  String? passwordConfirmation;
  
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  Future<void> handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() => _isLoading = true);

      final response = await _authService.resetPassword(email!, token!, password!, passwordConfirmation!);

      if (mounted) {
        setState(() => _isLoading = false);

        if (response['success'] == true || response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Password berhasil direset. Silakan login kembali."),
            backgroundColor: Colors.green,
          ));
          Navigator.pushNamedAndRemoveUntil(context, '/sign_in', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response['message'] ?? "Gagal mereset password. Token mungkin tidak valid."),
            backgroundColor: Colors.redAccent,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigoAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    const Text(
                      "Buat Password Baru",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Masukkan email, token dari email Anda, \ndan password baru",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (newValue) => email = newValue,
                      validator: (value) => value == null || value.isEmpty ? "Email tidak boleh kosong" : null,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        hintText: "Masukkan email yang terdaftar",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      onSaved: (newValue) => token = newValue,
                      validator: (value) => value == null || value.isEmpty ? "Token tidak boleh kosong" : null,
                      decoration: const InputDecoration(
                        labelText: "Token Reset",
                        hintText: "Masukkan token dari email",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.vpn_key),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      obscureText: _obscurePass,
                      onChanged: (value) => password = value,
                      onSaved: (newValue) => password = newValue,
                      validator: (value) {
                         if (value == null || value.isEmpty) return "Password baru tidak boleh kosong";
                         if (value.length < 8) return "Password minimal 8 karakter";
                         return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Password Baru",
                        hintText: "Masukkan password baru",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePass ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                       obscureText: _obscureConfirmPass,
                       onSaved: (newValue) => passwordConfirmation = newValue,
                       validator: (value) {
                         if (value == null || value.isEmpty) return "Konfirmasi password baru";
                         if (value != password) return "Password tidak cocok";
                         return null;
                       },
                       decoration: InputDecoration(
                        labelText: "Konfirmasi Password Baru",
                        hintText: "Ketik ulang password baru",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPass ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : handleResetPassword,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.indigoAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Simpan & Login",
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
    );
  }
}
