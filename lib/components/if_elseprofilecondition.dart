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

   Widget freelancerProfilePage(){

     return FreelancerProfilePage();
     /*Navigator.push(context, MaterialPageRoute(builder: (context) =>  const FreelancerProfilePage()
        )
     );*/
   }

   Widget userProfilePage(){
     return UserProfilePage();
     /*Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfilePage()
        )
     );*/
   }

   Future<DocumentSnapshot<Object?>> freelancerIdentifier2() async {
     DocumentSnapshot snapshot = await FirebaseFirestore.instance
         .collection('users')
         .doc(FirebaseAuth.instance.currentUser!.uid)
         .get();

     return snapshot;
   }

   @override
   Widget build(BuildContext context) {
     return FutureBuilder(
       future: freelancerIdentifier2(),
       builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
           return Center(child: CircularProgressIndicator());
         }
         if (snapshot.hasError) {
           return ErrorWidget('An error occurred.');
         } else {
           Object? userData = snapshot.data!.data();
           if ((userData as Map<String, dynamic>).containsKey('freelancer')) {
             bool? isFreelancer = userData['freelancer'];
             if (isFreelancer == true) {
               return freelancerProfilePage();
             } else {
               return userProfilePage();
             }
           } else {
             return userProfilePage();
           }
         }
       },
     );
   }
}

class AccountSettingsCondition extends StatefulWidget {
  const AccountSettingsCondition({super.key});

  @override
  State<AccountSettingsCondition> createState() => _AccountSettingsCondition();
}
class _AccountSettingsCondition extends State<AccountSettingsCondition>{

    void freelancerAccountSettings(){
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
        freelancerAccountSettings();
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


