import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FirestoreDatabase {
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference posts = FirebaseFirestore.instance.collection('Posts');

  Stream<QuerySnapshot> getPostsStream() {
    final postsStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true,)
        .snapshots();

    return postsStream;
  }

  String formatPostTimeStamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    final timeFormat = DateFormat('yyyy-MM-dd \'at\' hh:mm a');
    String formattedTimestamp = timeFormat.format(dateTime);

    return formattedTimestamp;
  }

  String formatDateTime(DateTime date) {

    final timeFormat = DateFormat('yyyy-MM-dd \'at\' hh:mm a');
    String formattedTimestamp = timeFormat.format(date);

    return formattedTimestamp;
  }
}