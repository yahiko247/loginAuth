import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/onBoardPage/onboard.dart';
import 'package:practice_login/pages/freelancerprofile.dart';
import 'package:practice_login/pages/userprofile.dart';

import '../pages/freelancerstalkingpage.dart';
import '../pages/userstalkingpage.dart';

class ProfileCondition extends StatefulWidget {
  const ProfileCondition({super.key});

  @override
  State<ProfileCondition> createState() => _ProfileCondition();

}

class _ProfileCondition extends State<ProfileCondition> {


   void freelancerProfilePage(){
     Navigator.push(context, MaterialPageRoute(builder: (context) =>  const FreelancerProfilePage()
        )
     );
   }

   void userProfilePage(){
     Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage()
        )
     );
   }

   Future<void> freelancerIdentifier(BuildContext context) async {
     User? user = FirebaseAuth.instance.currentUser;
     if (user != null) {
       DocumentSnapshot snapshot = await FirebaseFirestore.instance
           .collection('users')
           .doc(user.uid)
           .get();
       bool isFreelancer = snapshot['freelancer'] ?? false;

       if (isFreelancer) {
         freelancerProfilePage();
       } else {
         userProfilePage();
       }
     }
   }

   @override
   Widget build(BuildContext context) {
     return FutureBuilder<void>(
       future: freelancerIdentifier(context),
       builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.done) {
           if (snapshot.hasError) {
             return ErrorWidget('An error occurred.');
           } else {
             return const OnBoard();
           }
         } else {
           return const Center(child: CircularProgressIndicator());
         }
       },
     );
   }
}


