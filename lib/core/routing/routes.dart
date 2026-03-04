import 'package:damping/core/routing/navigation.dart';
import 'package:damping/features/home/views/home/homescreen.dart';
import 'package:damping/features/chats/views/message/message.dart';
import 'package:damping/features/notifications/views/notif/orderScreen.dart';
import 'package:damping/features/profile/views/profil/profil.dart';
import 'package:flutter/material.dart';
import 'package:damping/features/splash/views/splash/splash_screen.dart';
import 'package:damping/features/authentication/views/sign_in/sign_in_screen.dart';
import 'package:damping/features/authentication/views/sign_up/sign_up_screen.dart';
// import 'package:damping/features/authentication/views/forgot_password/forgot_password_screen.dart';
import 'package:damping/features/products/views/produkAdmin/FormProdukScreen.dart';
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
