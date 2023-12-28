import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/model/message.dart';

// USE THIS DART FILE TO HANDLE USER DATA MANIPULATION AND HANDLING (GET, UPDATE, DELETE)

class UserDataServices extends ChangeNotifier {
  final String userID;

  UserDataServices({required this.userID});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserDataAsStream() {
    return _fireStore.collection('users').doc(userID).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserDataAsFuture() {
    return _fireStore.collection('users').doc(userID).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataAsStream(String uid) {
    return _fireStore.collection('users').doc(uid).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDataAsFuture(String uid) {
    return _fireStore.collection('users').doc(uid).get();
  }
}