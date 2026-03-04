import 'package:damping/features/home/views/home/component/promo_carousel.dart';
import 'package:flutter/material.dart';
import 'package:damping/features/home/views/home/component/map.dart';
import 'package:damping/features/notifications/views/notif/notification_list_screen.dart';
import 'package:damping/features/notifications/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = '/homescreen';
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService _notificationService = NotificationService();
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (mounted) {
      setState(() => _unreadNotifications = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF536DFE), Colors.white],
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
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.fastfood, color: Color(0xFF536DFE), size: 36),
                ),
              ),
              const Spacer(),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () async {
                      // Reset badge segera saat dibuka
                      setState(() => _unreadNotifications = 0);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationListScreen(),
                        ),
                      );
                      // Refresh count setelah kembali dari halaman notifikasi
                      _loadUnreadCount();
                    },
                  ),
                  if (_unreadNotifications > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Center(
                          child: Text(
                            _unreadNotifications > 99 ? '99+' : '$_unreadNotifications',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
              onMerchantSelected: (merchant) {},
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
