import 'package:flutter/material.dart';
import 'package:practice_login/pages/chat/chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice_login/pages/reviews_page.dart';
import '../pages/feedback_page.dart';

class MyDrawer extends StatelessWidget{
  const MyDrawer ({super.key});

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    /* final authService = Provider.of<AuthService>(context, listen: false); */
  }

  @override
  Widget build(BuildContext context){
    return Drawer(
      child: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('About'),
              onTap: () {},
              contentPadding: const EdgeInsets.only(top: 50, left: 70),
            ),
            const ListTile(
              title: Text('Help'),
              contentPadding: EdgeInsets.only(left: 70),
            ),
            const ListTile(
              title: Text('Dark Mode'),
              contentPadding: EdgeInsets.only(left: 70),
            ),
            const ListTile(
              title: Text('Freelancer Mode'),
              contentPadding: EdgeInsets.only(left: 70),
            ),
            const ListTile(
              title: Text('Account Settings'),
              contentPadding: EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Chats'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ChatPage()));
              },
              contentPadding: const EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Log out'),
              onTap: () {
                // Add your logic for logging out
                signUserOut();
              },
              leading: const Icon(Icons.logout),
            ),
            ListTile(
              title: const Text('Debug/Test Feedback Page'),
              onTap: () {
                // Add your logic for logging out
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Ratings()));
              },
            ),
            ListTile(
              title: const Text('Debug/Test Reviews Page'),
              onTap: () {
                // Add your logic for logging out
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ReviewsPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}