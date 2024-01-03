import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/model/chat_room.dart';
import 'package:practice_login/model/message.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:intl/intl.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  String generateChatRoomID(List<String> ids) {
    ids.sort();
    String chatRoomId = ids.join("_");
    return chatRoomId;
  }

  Future<void> sendMessage(String receiverId, String receiverEmail, String message) async {
    final String _currentUserId = _firebaseAuth.currentUser!.uid;
    final String _currentUserEmail = _firebaseAuth.currentUser!.email.toString();

    Message newMessage = Message(
        senderId: _currentUserId,
        senderEmail: _currentUserEmail,
        receiverId: receiverId,
        receiverEmail: receiverEmail,
        message: message
    );

    try {
      _userDataServices.handleChatRoomKeys(generateChatRoomID([_currentUserId, receiverId]), receiverId);
      _userDataServices.handleContactList(receiverId);
      await _fireStore.collection('chat_rooms')
          .doc(generateChatRoomID([_currentUserId, receiverId]))
          .collection('messages')
          .add(newMessage.mapMessage());
      await _fireStore.collection('chat_rooms')
          .doc(generateChatRoomID([_currentUserId, receiverId]))
          .set({
        'members' : [_currentUserId, receiverId],
        'latest_message' : newMessage.mapMessage(),
        'latest_message_timestamp' : FieldValue.serverTimestamp(),
      });
    }
    catch (e) {
      print(e);
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    return _fireStore.collection('chat_rooms').doc(generateChatRoomID([userId, otherUserId])).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getChatRoom(String chatRoomID) {
    return FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomID).snapshots();
  }

  Future<void> createChatRoom(String otherUserID, String otherUserEmail, String message) async {
    final String _currentUserId = _firebaseAuth.currentUser!.uid;
    final String _currentUserEmail = _firebaseAuth.currentUser!.email.toString();

    Message newMessage = Message(
        senderId: _currentUserId,
        senderEmail: _currentUserEmail,
        receiverId: otherUserID,
        receiverEmail: otherUserEmail,
        message: message);

    ChatRoom newChatRoom = ChatRoom(latestMessage: newMessage.mapMessage(), members: [_currentUserId, otherUserID]);
    // check if chat_rrom exists
    DocumentSnapshot<Map<String, dynamic>> chatRoomCheck = await _fireStore
        .collection('chat_rooms')
        .doc(generateChatRoomID([_currentUserId, otherUserID]))
        .get();
    if (!chatRoomCheck.exists) {
      try {
        //create chat_room
        await _fireStore.collection('chat_rooms')
            .doc(generateChatRoomID([_currentUserId, otherUserID]))
            .set(newChatRoom.mapChatRoom());
        //add first message
        await _fireStore.collection('chat_rooms')
            .doc(generateChatRoomID([_currentUserId, otherUserID]))
            .collection('messages')
            .add(newMessage.mapMessage());
        //add chat_room_id to user: chat_room_keys
        _userDataServices.handleChatRoomKeys(generateChatRoomID([_currentUserId, otherUserID]), otherUserID);
      } catch (e) {
        print(e);
      }
    }
  }

  String formatMsgTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    final timeFormat = DateFormat('hh:mm a');
    String formattedTimestamp = timeFormat.format(dateTime);

    return formattedTimestamp;
  }

}