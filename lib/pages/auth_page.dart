import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/pages/botto_nav_bar.dart';
import 'package:practice_login/pages/home_page.dart';
import 'package:practice_login/pages/homepage.dart';
import 'package:practice_login/pages/login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //user is login
          if (snapshot.hasData) {
            return MyButtomNavBar();
          }

          //user is not log in
          else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
