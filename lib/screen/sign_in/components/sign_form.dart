import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:damping/service/ApiService.dart';
import 'package:damping/service/sharedProvider.dart';
import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';
import '../../../helper/keyboard.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool remember = false;
  final List<String?> errors = [];
  final ApiService apiService = ApiService();

  // Method to add error
  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  // Method to remove error
  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  // Method to handle login
  Future<void> handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      KeyboardUtil.hideKeyboard(context);

      bool success = await apiService.login(email!, password!);
      if (success) {
        // Call loadProfile in Sharedprovider after successful login
        Provider.of<Sharedprovider>(context, listen: false).loadProfile();

        // Navigate to main page
        Navigator.pushReplacementNamed(context, '/navigation');
      } else {
        addError(error: "Login failed. Please check your credentials.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Input Field
          buildEmailField(),

          const SizedBox(height: 20),

          // Password Input Field
          buildPasswordField(),

          const SizedBox(height: 20),

          // Remember Me and Forgot Password Section
          buildRememberMeAndForgotPassword(),

          // Error Messages
          FormError(errors: errors),

          const SizedBox(height: 16),

          // Login Button
          Center(
            child: ElevatedButton(
              onPressed: handleLogin,
              child: const Text("Login"),
            ),
          ),
        ],
      ),
    );
  }

  // Build email input field
  Widget buildEmailField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Email",
        hintText: "Enter your email",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }

  // Build password input field
  Widget buildPasswordField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  // Build remember me and forgot password section
  Widget buildRememberMeAndForgotPassword() {
    return Row(
      children: [
        Checkbox(
          value: remember,
          activeColor: kPrimaryColor,
          onChanged: (value) {
            setState(() {
              remember = value ?? false;
            });
          },
        ),
        const Text("Remember me"),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/forgot_password'),
          child: const Text("Forgot Password?",
              style: TextStyle(decoration: TextDecoration.underline)),
        ),
      ],
    );
  }
}
