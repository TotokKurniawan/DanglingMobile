// import 'package:flutter/material.dart';
// import '../../../components/custom_surfix_icon.dart';
// import '../../../components/form_error.dart';
// import '../../../components/no_account_text.dart';
// import '../../../constants.dart';
// import '../../../service/ApiService.dart';

// class ForgotPassForm extends StatefulWidget {
//   const ForgotPassForm({super.key});

//   @override
//   _ForgotPassFormState createState() => _ForgotPassFormState();
// }

// class _ForgotPassFormState extends State<ForgotPassForm> {
//   final _formKey = GlobalKey<FormState>();
//   List<String> errors = [];
//   String? email;

//   Future<void> handleForgotPassword() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       // Panggil API forgot password
//       bool success = await ApiService().forgotPassword(email!);

//       if (success) {
//         // Tampilkan pesan sukses
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text("Password reset link has been sent to your email."),
//         ));
//       } else {
//         // Tampilkan pesan error jika gagal
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text("Failed to send reset link. Please try again."),
//         ));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           TextFormField(
//             keyboardType: TextInputType.emailAddress,
//             onSaved: (newValue) => email = newValue,
//             onChanged: (value) {
//               if (value.isNotEmpty && errors.contains(kEmailNullError)) {
//                 setState(() {
//                   errors.remove(kEmailNullError);
//                 });
//               } else if (emailValidatorRegExp.hasMatch(value) &&
//                   errors.contains(kInvalidEmailError)) {
//                 setState(() {
//                   errors.remove(kInvalidEmailError);
//                 });
//               }
//             },
//             validator: (value) {
//               if (value!.isEmpty && !errors.contains(kEmailNullError)) {
//                 setState(() {
//                   errors.add(kEmailNullError);
//                 });
//               } else if (!emailValidatorRegExp.hasMatch(value) &&
//                   !errors.contains(kInvalidEmailError)) {
//                 setState(() {
//                   errors.add(kInvalidEmailError);
//                 });
//               }
//               return null;
//             },
//             decoration: const InputDecoration(
//               labelText: "Email",
//               hintText: "Enter your email",
//               floatingLabelBehavior: FloatingLabelBehavior.always,
//               suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
//             ),
//           ),
//           const SizedBox(height: 8),
//           FormError(errors: errors),
//           const SizedBox(height: 8),
//           // Tombol "Continue" dengan style yang lebih modern
//           ElevatedButton(
//             onPressed: () {
//               if (_formKey.currentState!.validate()) {
//                 // Proses lanjutan saat tombol diklik
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: kPrimaryColor, // Warna teks di tombol
//               padding: const EdgeInsets.symmetric(
//                 vertical: 16.0, // Padding atas-bawah
//                 horizontal: 32.0, // Padding kanan-kiri
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(
//                     30.0), // Membuat sudut tombol melengkung
//               ),
//             ),
//             child: const Text(
//               "Continue",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16), const SizedBox(height: 16),
//           const NoAccountText(),
//         ],
//       ),
//     );
//   }
// }
