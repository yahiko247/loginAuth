import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/model/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  List<String> memberList(String user, otherUser) {
    return [user, otherUser,];
  }

  Future<void> sendMessage(String receiverId, String receiverEmail, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();

    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        receiverEmail: receiverEmail,
        message: message
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    try {await _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());}
    catch (e) {print(e);}

    try {await _fireStore.collection('chat_rooms').doc(chatRoomId).set({'members' : memberList(currentUserId, receiverId)});}
    catch (e) {print(e);}
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore.collection("chat_rooms").doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }

  Stream<QuerySnapshot> getChatRoom(String userId) {
    final chatRoomIdList = _fireStore.collection("chat_rooms");

    List<String> ids = [userId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore.collection("chat_rooms").doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }

  Future<List<dynamic>?> getContacts(String documentId) async {
    DocumentReference docRef = _fireStore.collection('users').doc(documentId);

    try {
      DocumentSnapshot docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        // Extract document data and assign it to a variable
        List<dynamic>? specificArray = docSnapshot.get('contacts');
        return specificArray;
      } else {
        print('Document does not exist');
        return null; // Return null or handle the absence of the document
      }
    } catch (e) {
      print('Error getting document: $e');
      return null; // Return null or handle the error
    }
  }

}