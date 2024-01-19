import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class PostService extends ChangeNotifier {
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  final CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  final storageRef = FirebaseStorage.instance.ref();
  final timeStamp = FieldValue.serverTimestamp();
  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  Future<List<Map<String, dynamic>>> uploadFiles(List<PlatformFile> files) async {
    String timeStamp = DateTime.now().toString();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, dynamic>> fileRefs = [];


    if (files.isNotEmpty) {
      for (int i = 0; i < files.length; i++) {
        try {
          SettableMetadata metadata = SettableMetadata(contentType: files[i].extension);
          UploadTask uploadTask = storageRef.child('posts/$userId/$timeStamp/$i${files[i].name}').putFile(File(files[i].path!), metadata);

          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            _uploadProgress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;

            notifyListeners();
          });

          await uploadTask;
          Map<String,dynamic> fileRefWithMetaData = {};
          fileRefWithMetaData['media_reference'] = await storageRef.child('posts/$userId/$timeStamp/$i${files[i].name}').getDownloadURL();
          FullMetadata metaData = await storageRef.child('posts/$userId/$timeStamp/$i${files[i].name}').getMetadata();
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

  Future<void> addPost(String message, List<PlatformFile>? postFiles) async {
    List<Map<String, dynamic>>? fileRefs;

    if (postFiles != null) {
      fileRefs = await uploadFiles(postFiles);
    }

    DocumentSnapshot<Map<String, dynamic>> userDataSnapShot = await _userDataServices.getCurrentUserDataAsFuture();
    if (userDataSnapShot.exists) {
      Map<String, dynamic>? userData = userDataSnapShot.data();
      if (userData!.isNotEmpty) {
        try {
          await posts.add({
            'user_email': userData['email'],
            'user_id' : userData['uid'],
            'first_name' : userData['first_name'],
            'last_name' : userData['last_name'],
            'post_message': message,
            'timestamp': Timestamp.now(),
            'media': fileRefs ?? []
          });
        } catch (e) {
          throw Exception(e);
        }
      }
    }
  }

  Stream<QuerySnapshot> getPostsStream() {
    final postsStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return postsStream;
  }

  String formatPostTimeStamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    final timeFormat = DateFormat('yyyy-MM-dd \'at\' hh:mm a');
    String formattedTimestamp = timeFormat.format(dateTime);

    return formattedTimestamp;
  }
}