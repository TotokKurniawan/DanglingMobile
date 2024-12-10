import 'package:damping/screen/home/homescreen.dart';
import 'package:damping/screen/message/message.dart';
import 'package:damping/screen/notif/orderScreen.dart';
import 'package:damping/screen/profil/profil.dart';
import 'package:damping/screen/history/historyscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service/sharedProvider.dart';

const Color inActiveIconColor = Color.fromARGB(255, 252, 59, 0);

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  static String routeName = "/navigation";

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Sharedprovider>().loadRole();
    });
  }

  void updateCurrentIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Sharedprovider>(
      builder: (context, sharedProvider, child) {
        return Scaffold(
          body: pages(sharedProvider.isSeller)[
              _selectedIndex], // Menggunakan status seller
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.indigoAccent,
            unselectedItemColor: inActiveIconColor,
            currentIndex: _selectedIndex,
            onTap: updateCurrentIndex,
            items: _navBarItems(
                sharedProvider.isSeller), // Menggunakan status seller
          ),
        );
      },
    );
  }

  List<Widget> pages(bool isSeller) {
    List<Widget> tempPages = [
      const HomeScreen(),
      const Message(),
      const HistoryScreen(),
    ];

    if (isSeller) {
      tempPages.add(const Orderscreen());
    }

    tempPages.add(const ProfileScreen());
    return tempPages;
  }

  List<BottomNavigationBarItem> _navBarItems(bool isSeller) {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline),
        activeIcon: Icon(Icons.chat_bubble),
        label: 'Chat',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.history),
        activeIcon: Icon(Icons.history),
        label: 'History',
      ),
      if (isSeller)
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          activeIcon: Icon(Icons.notifications),
          label: 'Pesanan',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_rounded),
        activeIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ];
    return items;
  }
}
