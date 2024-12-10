import 'package:damping/screen/home/component/promo_carousel.dart';
import 'package:flutter/material.dart';
import 'package:damping/screen/home/component/map.dart';

// import 'package:damping/screen/home/component/merchant_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = '/homescreen';
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int unreadNotifications = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false, // Menghilangkan tombol back
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF536DFE),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Row(
            children: [
              // Bagian ini bisa dihilangkan jika tidak diperlukan
              // Expanded(
              //   child: Container(
              //     height: 40,
              //     decoration: BoxDecoration(
              //       gradient: LinearGradient(
              //         colors: [
              //           const Color.fromRGBO(169, 169, 169, 1),
              //           Colors.white,
              //         ],
              //         begin: Alignment.topCenter,
              //         end: Alignment.bottomCenter,
              //       ),
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //   ),
              // ),
              // Gunakan Align untuk menempatkan notifikasi di pojok kanan
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            PromoCarousel(),
            const SizedBox(height: 10),
            MapSection(
              onMerchantSelected: (merchant) {
                // showMerchantBottomSheet(context, merchant);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
