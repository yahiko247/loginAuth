import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/pages/chat_page.dart';
import 'package:practice_login/pages/favorite.dart';
import 'package:practice_login/pages/home_page.dart';
import 'package:practice_login/pages/homepage.dart';
import 'package:practice_login/pages/profile.dart';
import 'package:practice_login/pages/search.dart';
import 'package:practice_login/pages/setting.dart';

class MyButtomNavBar extends StatefulWidget {
  const MyButtomNavBar({Key? key}) : super(key: key);

  @override
  State<MyButtomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyButtomNavBar> {
  int myCurrentIndex = 0;
  List<Widget> pages = [
    HomePage2(),
    FavoritePage(),
    SearchPage(),
    SettingPage(),
    ProfilePage(),
    ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 25,
                offset: const Offset(8, 20)),
          ],
        ),
        child: ClipRRect(
            child: BottomNavigationBar(
          backgroundColor: Color.fromARGB(255, 13, 14, 13),
          selectedItemColor: Color.fromARGB(255, 46, 126, 112),
          unselectedItemColor: Colors.black,
          currentIndex: myCurrentIndex,
          onTap: (index) {
            setState(() {
              myCurrentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: "Listed Book",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Notifications",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        )),
      ),
      body: pages[myCurrentIndex],
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
}
