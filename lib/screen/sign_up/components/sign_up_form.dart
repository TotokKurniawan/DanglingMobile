import 'package:damping/screen/sign_in/sign_in_screen.dart';
import 'package:damping/service/ApiService.dart';
import 'package:flutter/material.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  final List<String?> errors = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService(); // Inisialisasi ApiService

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
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final success = await _apiService.register(email!, password!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed. Please try again.')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
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
            // Input Email
            TextFormField(
              decoration: InputDecoration(
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
              decoration: InputDecoration(
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
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
