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
        title: const Text("GigGabay"),
        actions: [],
        backgroundColor: const Color.fromARGB(255, 70, 199, 177),
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
      endDrawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('About'),
              onTap: () {},
              contentPadding: const EdgeInsets.only(top: 50, left: 70),
            ),
            ListTile(
              title: const Text('Help'),
              contentPadding: const EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Dark Mode'),
              contentPadding: const EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Freelancer Mode'),
              contentPadding: const EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Account Settings'),
              contentPadding: const EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Log out'),
              onTap: () {
                // Add your logic for logging out
                signUserOut();
              },
              leading: Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
}
