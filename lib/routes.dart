import 'package:damping/navigation.dart';
import 'package:damping/screen/home/homescreen.dart';
import 'package:damping/screen/message/message.dart';
import 'package:damping/screen/notif/orderScreen.dart';
import 'package:damping/screen/profil/profil.dart';
import 'package:flutter/material.dart';
import 'package:damping/screen/splash/splash_screen.dart';
import 'package:damping/screen/sign_in/sign_in_screen.dart';
import 'package:damping/screen/sign_up/sign_up_screen.dart';
// import 'package:damping/screen/forgot_password/forgot_password_screen.dart';
import 'package:damping/screen/produkAdmin/FormProdukScreen.dart';
// ignore: unused_import

import 'dart:io';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
  // ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  Navigation.routeName: (context) => const Navigation(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  Message.routename: (context) => const Message(),
  Orderscreen.routeName: (context) => const Orderscreen(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  FormProdukScreen.routeName: (context) => FormProdukScreen(),
};

// Optional: Uncomment this if you need to handle dynamic routes
// Route<dynamic>? onGenerateRoute(RouteSettings settings) {
//   // Implement any dynamic routes here if needed
//   return null;
// }
