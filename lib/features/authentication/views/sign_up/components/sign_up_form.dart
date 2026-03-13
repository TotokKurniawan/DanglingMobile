import 'package:streetmarketid/features/authentication/views/sign_in/sign_in_screen.dart';
import 'package:streetmarketid/features/authentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../../components/form_error.dart';
import 'package:streetmarketid/core/utils/constants.dart';


class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? phone;
  String? email;
  String? password;
  final List<String?> errors = [];
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.register(name!, email!, phone!, password!);
      if (response['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      } else {
        addError(error: response['message'] ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      addError(error: 'Server Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Name
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Nama Lengkap",
                hintText: "Masukkan nama",
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              onSaved: (newValue) => name = newValue,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Nama tidak boleh kosong";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Input Phone
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Nomor Telepon",
                hintText: "Masukkan nomor telepon",
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              keyboardType: TextInputType.phone,
              onSaved: (newValue) => phone = newValue,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Nomor telepon tidak boleh kosong";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Input Email
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "Masukkan email",
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              keyboardType: TextInputType.emailAddress,
              onSaved: (newValue) => email = newValue,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  addError(error: "Email tidak boleh kosong");
                  return "";
                }
                removeError(error: "Email tidak boleh kosong");
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Input Password
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Password",
                hintText: "Masukkan password",
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              obscureText: true,
              onSaved: (newValue) => password = newValue,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  addError(error: "Password tidak boleh kosong");
                  return "";
                }
                removeError(error: "Password tidak boleh kosong");
                return null;
              },
            ),
            const SizedBox(height: 20),

            FormError(errors: errors),
            const SizedBox(height: 20),

            // Tombol Sign Up
            Center(
              child: ElevatedButton(
                onPressed: !_isLoading ? registerUser : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 40.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: !_isLoading
                    ? const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 18),
                      )
                    : const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
