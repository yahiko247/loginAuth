import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/model/message.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:intl/intl.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

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
    handleChatRoomKeys(chatRoomId, receiverId);

    try {
      await _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());
      await _fireStore.collection('chat_rooms').doc(chatRoomId).set({
        'members' : [currentUserId, receiverId],
        'latest_message' : newMessage.toMap(),
        'latest_message_timestamp' : FieldValue.serverTimestamp(),
      });
    }
    catch (e) {
      print(e);
    }
  }

  Future<void> handleChatRoomKeys(String chatRoomID, String receiverID) async {
    DocumentSnapshot<Map<String, dynamic>> userDataSnapshot = await _userDataServices.getCurrentUserDataAsFuture();
    DocumentSnapshot<Map<String, dynamic>> otherUserDataSnapshot = await _userDataServices.getUserDataAsFuture(receiverID);
    if (userDataSnapshot.exists) {
      List<dynamic> userChatRoomKeys = userDataSnapshot['chat_room_keys'];
      if (userDataSnapshot.data()!.containsKey('chat_room_keys') && userChatRoomKeys.contains(chatRoomID)) {
        userChatRoomKeys.remove(chatRoomID);
        userChatRoomKeys.insert(0, chatRoomID);
        await _fireStore.collection('users').doc(_firebaseAuth.currentUser!.uid).update({'chat_room_keys': userChatRoomKeys});
      } else if (otherUserDataSnapshot.data()!.containsKey('chat_room_keys') && !userChatRoomKeys.contains(chatRoomID)) {
        userChatRoomKeys.insert(0, chatRoomID);
        await _fireStore.collection('users').doc(_firebaseAuth.currentUser!.uid).update({'chat_room_keys': userChatRoomKeys});
      } else {
        userChatRoomKeys.insert(0, chatRoomID);
        await _fireStore.collection('users').doc(_firebaseAuth.currentUser!.uid).set({'chat_room_keys': userChatRoomKeys}, SetOptions(merge: true));
      }
    }
    if (otherUserDataSnapshot.exists) {
      List<dynamic> userChatRoomKeys = otherUserDataSnapshot['chat_room_keys'];
      if (otherUserDataSnapshot.data()!.containsKey('chat_room_keys') && userChatRoomKeys.contains(chatRoomID)) {
        userChatRoomKeys.remove(chatRoomID);
        userChatRoomKeys.insert(0, chatRoomID);
        await _fireStore.collection('users').doc(receiverID).update({'chat_room_keys': userChatRoomKeys});
      } else if (otherUserDataSnapshot.data()!.containsKey('chat_room_keys') && !userChatRoomKeys.contains(chatRoomID)) {
        userChatRoomKeys.insert(0, chatRoomID);
        await _fireStore.collection('users').doc(receiverID).update({'chat_room_keys': userChatRoomKeys});
      } else {
        userChatRoomKeys.insert(0, chatRoomID);
        await _fireStore.collection('users').doc(receiverID).set({'chat_room_keys': userChatRoomKeys}, SetOptions(merge: true));
      }
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore.collection("chat_rooms").doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getChatRoom(String chatRoomID) {
    return FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomID).snapshots();
  }

  String formatMsgTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    final timeFormat = DateFormat('hh:mm a');
    String formattedTimestamp = timeFormat.format(dateTime);

    return formattedTimestamp;
  }

}