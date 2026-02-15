import 'package:flutter/material.dart';
import 'package:khdmti_project/views/home/home_screen.dart';
import 'package:khdmti_project/views/message/message_screen.dart';
import 'package:khdmti_project/views/profile/profile_screen.dart';
import 'package:khdmti_project/views/search/search_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> screen = [
      HomeScreen(),
      SearchScreen(),
      MessageScreen(),
      ProfileScreen()
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Directionality(
        textDirection: TextDirection.rtl,
        child: BottomNavigationBar(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          iconSize: 24,
          elevation: 2,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
              fontFamily: "IBMPlexSansArabic",
              color: Color(0xff64748B),
              fontSize: 14,
              fontWeight: FontWeight.w300),
          unselectedItemColor: Color(0xff9CA3AF),
          backgroundColor: Color(0xffFFFFFF),
          selectedItemColor: Color(0xff137FEC),
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                ),
                label: "الرئيسية"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "استكشف"),
            BottomNavigationBarItem(
                icon: Icon(Icons.message), label: "الرسائل"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "حسابي"),
          ],
        ),
      ),
      body: screen[_currentIndex],
    );
  }
}
