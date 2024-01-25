import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // Sign In
  Future<UserCredential> signIn(String email, password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign Up
  Future<UserCredential> signUp(String email, password, firstName, String? lastName, bool? freelancer) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      Map<String, dynamic> newUser = {};

      newUser['uid'] = userCredential.user!.uid;
      newUser['email'] = email;
      newUser['contacts'] = [];
      newUser['chat_room_keys'] = [];
      newUser['archived_chat_rooms'] = [];
      newUser['first_name'] = firstName;
      newUser['last_name'] = lastName;
      newUser['freelancer'] = freelancer ?? false;
      newUser['date_started'] = FieldValue.serverTimestamp();
      if (freelancer == true) {
        newUser['category_name'] = [];
        newUser['rating'] = 0.0;
        newUser['price'] = 0.0;
        /// Price rate type (hourly, daily, per_project)
        newUser['price_rate_type'] = [];
      }

      _fireStore.collection('users').doc(userCredential.user!.uid).set(newUser);
      return userCredential;
    } on FirebaseAuthException catch(e) {
      throw Exception(e.code);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }

}