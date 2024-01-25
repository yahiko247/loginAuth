import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookingServices extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> createBook(Map<String, dynamic> bookingDetails) async {
    if (bookingDetails.isNotEmpty) {
      try {
        _fireStore.collection('ongoing_books').add(bookingDetails);
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  Future<Map<String,dynamic>> getOngoing() async {
    try {
      /// Get booking where i am client
      QuerySnapshot<Map<String, dynamic>> asClientBooks = await _fireStore.collection('ongoing_books').where('client_id', isEqualTo: _firebaseAuth.currentUser!.uid).get();
      /// Get booking where i am freelancer
      QuerySnapshot<Map<String, dynamic>> asFreelancerBooks = await _fireStore.collection('ongoing_books').where('freelancer_user_id', isEqualTo: _firebaseAuth.currentUser!.uid).get();
      Map<String, dynamic> onGoingBooks = {};
      onGoingBooks['as_client'] = asClientBooks.docs.toList();
      onGoingBooks['as_freelancer'] = asFreelancerBooks.docs.toList();
      return onGoingBooks;
    } catch (e) {
      throw Exception(e);
    }
  }
}