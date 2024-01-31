import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/services/user_data_services.dart';

class BookingServices extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  Future<void> createBook(Map<String, dynamic> bookingDetails) async {
    if (bookingDetails.isNotEmpty) {
      try {
        await _fireStore.collection('bookings').add(bookingDetails);
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  Stream<QuerySnapshot> getBookingsAsFreelancer() {
    return _fireStore
        .collection('bookings')
        .where('freelancer_user_id', isEqualTo: _firebaseAuth.currentUser!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getBookingAsClient() {
    return _fireStore
        .collection('bookings')
        .where('client_id', isEqualTo: _firebaseAuth.currentUser!.uid)
        .snapshots();
  }

  Future<Map<String, dynamic>> getClientAndFreelancerData(String clientId, String freelancerId) async {
    try {
      var clientSnapshot = await _userDataServices.getUserDataAsFuture(clientId);
      var freelancerSnapshot = await _userDataServices.getUserDataAsFuture(freelancerId);
      if (clientSnapshot.exists && freelancerSnapshot.exists) {
        Map<String, dynamic> clientData = clientSnapshot.data()!;
        Map<String, dynamic> freelancerData = freelancerSnapshot.data()!;
        Map<String, dynamic> merged = {'client':clientData, 'freelancer':freelancerData};
        return merged;
      } else {
        throw Exception('Data does not exist!');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getSingleBooking(String bookId) {
    return _fireStore.collection('bookings').doc(bookId).get();
  }

  Future<void> acceptRequest(String bookId) async {
    DocumentSnapshot<Map<String, dynamic>> bookingSnapshot = await getSingleBooking(bookId);
    if (bookingSnapshot.exists) {
      try {
        await _fireStore.collection('bookings').doc(bookId).set({'status':'ongoing', 'accepted_date' : FieldValue.serverTimestamp()}, SetOptions(merge: true));
        /*await _fireStore.collection('users').doc(_firebaseAuth.currentUser!.uid).set({''}, SetOptions(merge: true));*/
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  Future<void> clearToDoStatus(int itemIndex, String bookId) async {
    DocumentSnapshot<Map<String, dynamic>> bookingSnapshot = await getSingleBooking(bookId);
    if (bookingSnapshot.exists) {
      Map<String, dynamic> bookData = bookingSnapshot.data()!;
      List<dynamic> toDos = bookData['to_dos'];
      if (!toDos[itemIndex].containsKey('cleared')) {
        toDos[itemIndex]['cleared'] = true;
      } else {
        toDos[itemIndex]['cleared'] = !toDos[itemIndex]['cleared'];
      }
      try {
        print('hmm');
        await _fireStore.collection('bookings').doc(bookId).set({'to_dos':toDos}, SetOptions(merge: true));
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  Future<void> completeBook(String bookId) async {
    DocumentSnapshot<Map<String, dynamic>> bookingSnapshot = await getSingleBooking(bookId);
    if (bookingSnapshot.exists) {
      try {
        await _fireStore.collection('bookings').doc(bookId).set({'status':'completed', 'completed_date':FieldValue.serverTimestamp()}, SetOptions(merge: true));
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  Future<void> removeBook(String bookId) async {
    DocumentSnapshot<Map<String, dynamic>> bookingSnapshot = await getSingleBooking(bookId);
    if (bookingSnapshot.exists) {
      try {
        await _fireStore.collection('bookings').doc(bookId).set({'status':'cancelled', 'cancelled_date':FieldValue.serverTimestamp()}, SetOptions(merge: true));
      } catch (e) {
        throw Exception(e);
      }
    }
  }

}