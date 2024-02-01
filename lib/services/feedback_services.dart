import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FeedbackService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  final CollectionReference feedback = FirebaseFirestore.instance.collection('feedback');
  final storageRef = FirebaseStorage.instance.ref();
  final timeStamp = FieldValue.serverTimestamp();
  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  Future<List<Map<String, dynamic>>> uploadFiles(List<PlatformFile> files,String freelancerID) async {
    String timeStamp = DateTime.now().toString();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, dynamic>> fileRefs = [];


    if (files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        try {
          SettableMetadata metadata = SettableMetadata(contentType: files[i].extension);
          UploadTask uploadTask = storageRef.child('feedback/$freelancerID/$userId/$timeStamp/$i${files[i].name}').putFile(File(files[i].path!), metadata);

          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            _uploadProgress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;

            notifyListeners();
          });

          await uploadTask;
          Map<String,dynamic> fileRefWithMetaData = {};
          fileRefWithMetaData['media_reference'] = await storageRef.child('feedback/$freelancerID/$userId/$timeStamp/$i${files[i].name}').getDownloadURL();
          FullMetadata metaData = await storageRef.child('posts/$freelancerID/$userId/$timeStamp/$i${files[i].name}').getMetadata();
          fileRefWithMetaData['media_type'] = metaData.contentType;
          fileRefWithMetaData['media_title'] = metaData.name;
          fileRefWithMetaData['media_size'] = metaData.size;
          fileRefs.add(fileRefWithMetaData);
        } catch (e) {
          throw Exception(e);
        }
      }
    }
    return fileRefs;
  }

  Future<void> addFeedback(String message, List<PlatformFile>? postFiles, String freelancerID,double ratingValue) async {
    List<Map<String, dynamic>>? fileRefs;

    if (postFiles != null) {
      fileRefs = await uploadFiles(postFiles,freelancerID);
    }

    DocumentSnapshot<Map<String, dynamic>> userDataSnapShot = await _userDataServices.getCurrentUserDataAsFuture();
    if (userDataSnapShot.exists) {
      Map<String, dynamic>? userData = userDataSnapShot.data();
      if (userData!.isNotEmpty) {
        try {
          await feedback.doc(freelancerID).collection('feedback').add({
            'rating_value': ratingValue,
            'client_email': userData['email'],
            'client_id' : userData['uid'],
            'client_first_name' : userData['first_name'],
            'client_last_name' : userData['last_name'],
            'feedback_message': message,
            'timestamp': Timestamp.now(),
            'media': fileRefs ?? []
          });
        } catch (e) {
          throw Exception(e);
        }
      }
    }
  }

  Stream<QuerySnapshot> getFeedbackStream(String freelancerID) {
    final feedbackStream = FirebaseFirestore.instance
        .collection('feedback').doc(freelancerID).collection('feedback')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return feedbackStream;
  }

  String formatFeedbackTimeStamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    final timeFormat = DateFormat('yyyy-MM-dd \'at\' hh:mm a');
    String formattedTimestamp = timeFormat.format(dateTime);

    return formattedTimestamp;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getPost(String postId) async {
    DocumentSnapshot<Map<String, dynamic>> post = await _firestore.collection('posts').doc(postId).get();
    return post;
  }

  Stream<QuerySnapshot> getFeedbacks(String freelancerID){
    return _firestore.collection('feedback')
        .doc(freelancerID)
        .collection('feedback')
        .orderBy('timestamp',descending: false)
        .snapshots();
  }
  
  
}

