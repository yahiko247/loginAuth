import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/pages/botto_nav_bar.dart';
import 'package:practice_login/services/login_register.dart';

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
            return const MyButtomNavBar();
          }

          //user is not log in
          else {
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}
