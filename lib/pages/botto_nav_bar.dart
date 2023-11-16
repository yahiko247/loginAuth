import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/pages/favorite.dart';
import 'package:practice_login/pages/home_page.dart';
import 'package:practice_login/pages/homepage.dart';
import 'package:practice_login/pages/profile.dart';
import 'package:practice_login/pages/setting.dart';

class MyButtomNavBar extends StatefulWidget {
  const MyButtomNavBar({Key? key}) : super(key: key);

  @override
  State<MyButtomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyButtomNavBar> {
  int myCurrentIndex = 0;
  List<Widget> pages = const [
    HomePage2(),
    FavoritePage(),
    SettingPage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My App"),
        actions: [IconButton(onPressed: signUserOut, icon: Icon(Icons.logout))],
        backgroundColor: Colors.grey[300],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 25,
                offset: const Offset(8, 20)),
          ],
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.redAccent,
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
                  icon: Icon(Icons.favorite),
                  label: "Favorite",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "Setting",
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
