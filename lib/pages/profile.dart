import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/nested_tab/nestedtab.dart';
import 'package:practice_login/pages/chat_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final currentUser = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: AppBar(
            flexibleSpace: Row(
              children: [
                Container(
                    padding: EdgeInsets.only(top: 20, left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset('images/Avatar1.png', height: 120),
                        SizedBox(width: 10),
                        Text(currentUser.email!)
                      ],
                    )),
              ],
            ),
            backgroundColor: Color.fromARGB(255, 124, 210, 231),
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            NestedTabBar('first Page'),
            NestedTabBar('secondTab')
          ],
        ),
        endDrawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 124, 210, 231),
                ),
                child: Text('A B OU T'),
              ),
              const ListTile(
                title: const Text('Help'),
                contentPadding: const EdgeInsets.only(left: 70),
              ),
              const ListTile(
                title: const Text('Dark Mode'),
                contentPadding: const EdgeInsets.only(left: 70),
              ),
              const ListTile(
                title: const Text('Freelancer Mode'),
                contentPadding: const EdgeInsets.only(left: 70),
              ),
              const ListTile(
                title: const Text('Account Settings'),
                contentPadding: const EdgeInsets.only(left: 70),
              ),
              ListTile(
                title: const Text('Chats'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChatPage()));
                },
                contentPadding: const EdgeInsets.only(left: 70),
              ),
              ListTile(
                title: const Text('log out'),
                onTap: () {
                  // Add your logic for logging out
                  signUserOut();
                },
                leading: Icon(Icons.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
