import 'package:damping/features/notifications/views/notif/component/orderlist.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:damping/features/orders/views/history/historyscreen.dart';
import 'package:damping/features/notifications/views/notif/notification_list_screen.dart';

class Orderscreen extends StatefulWidget {
  static String routeName = '/Notificationscreen';
  const Orderscreen({Key? key}) : super(key: key);

  @override
  _OrderscreenState createState() => _OrderscreenState();
}

import 'package:damping/features/orders/views/history/historyscreen.dart';

// ... (keep class declaration)

class _OrderscreenState extends State<Orderscreen> {
  int unreadNotifications = 5;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(130), // Increased height for TabBar
          child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
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
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Pesanan',
                  style: GoogleFonts.lobster(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        setState(() {
                          unreadNotifications = 0;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationListScreen(),
                          ),
                        ).then((_) {
                          // TODO: Refresh unread count when returning
                        });
                      },
                    ),
                    if (unreadNotifications > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Center(
                            child: Text(
                              '$unreadNotifications',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            bottom: const TabBar(
              indicatorColor: Colors.indigoAccent,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              tabs: [
                Tab(text: "Masuk"),
                Tab(text: "Riwayat"),
              ],
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: TabBarView(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    OrderList(),
                  ],
                ),
              ),
              const HistoryScreen(role: 'seller', showAppBar: false),
            ],
          ),
        ),
      ),
    );
  }
}
