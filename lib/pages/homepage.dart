import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/pages/profile.dart';
import 'package:practice_login/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:practice_login/services/auth_service.dart';

class HomePage2 extends StatelessWidget {
  const HomePage2({super.key});

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    /* final authService = Provider.of<AuthService>(context, listen: false); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: Container(
                  padding: EdgeInsets.only(top: 10, left: 15),
                  child: Image.asset('images/Avatar1.png', height: 40)),
            ),
          ],
        ),
        actions: [],
        backgroundColor: Color.fromARGB(255, 124, 210, 231),
      ),
      body: Center(
          child: Text(
        "This is home page",
        style: TextStyle(fontSize: 40),
      )),
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
}
