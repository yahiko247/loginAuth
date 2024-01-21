import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/components/if_elseprofilecondition.dart';
import 'package:practice_login/services/user_data_services.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final currentUser = FirebaseAuth.instance.currentUser!;
  final UserDataServices _userDataServices =
      UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return const ProfileCondition();
  }
}
