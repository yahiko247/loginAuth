import 'package:flutter/material.dart';
import 'package:practice_login/onBoardPage/onboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:practice_login/pages/freelancerprofile.dart';
import 'package:practice_login/pages/userprofile.dart';
import 'package:practice_login/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
      create: (context) => AuthService(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const OnBoard(),
      routes: {
        '/freelancerprofile': (context) => FreelancerProfilePage(),
        '/userprofile': (context) => UserProfilePage(),
      },


      //theme: lightMode,
      //darkTheme: darkMode,
    );
  }
}
