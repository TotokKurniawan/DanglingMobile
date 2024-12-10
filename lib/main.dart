import 'package:damping/routes.dart';
import 'package:damping/service/sharedProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:damping/screen/splash/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Sharedprovider()
        ..loadProfile()
        ..loadToken(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return ScreenUtilInit(
      designSize: Size(375, 812), // ukuran desain awal
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'New Project',
          debugShowCheckedModeBanner: false,
          initialRoute: SplashScreen.routeName,
          routes: routes,
          builder: (context, child) {
            return SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade300,
                      Colors.blue.shade200,
                      Colors.cyan.shade100,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: child!, // Tidak perlu FutureBuilder lagi
              ),
            );
          },
        );
      },
    );
  }
}
