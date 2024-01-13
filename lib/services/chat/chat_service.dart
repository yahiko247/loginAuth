import 'package:flutter/material.dart';

// Dependencies
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Services
import 'package:practice_login/services/user_data_services.dart';

// Models
import 'package:practice_login/model/chat_room.dart';
import 'package:practice_login/model/message.dart';


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
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();

    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        receiverEmail: receiverEmail,
        message: message
    );

    // for user copy
    try {
      await _fireStore.collection('users')
          .doc(currentUserId)
          .collection('chat_rooms')
          .doc(generateChatRoomID([currentUserId, receiverId]))
          .collection('messages')
          .add(newMessage.mapMessage());
      await _fireStore.collection('users')
          .doc(currentUserId)
          .collection('chat_rooms')
          .doc(generateChatRoomID([currentUserId, receiverId]))
          .set({
        'read' : true,
        'members' : [currentUserId, receiverId],
        'latest_message' : newMessage.mapMessage(),
        'latest_message_timestamp' : FieldValue.serverTimestamp(),
      });
    }
    catch (e) {
      throw Exception(e);
    }

    //other user copy
    try {
      await _fireStore.collection('users')
          .doc(receiverId)
          .collection('chat_rooms')
          .doc(generateChatRoomID([currentUserId, receiverId]))
          .collection('messages')
          .add(newMessage.mapMessage());
      await _fireStore.collection('users')
          .doc(receiverId)
          .collection('chat_rooms')
          .doc(generateChatRoomID([currentUserId, receiverId]))
          .set({
        'read' : false,
        'members' : [currentUserId, receiverId],
        'latest_message' : newMessage.mapMessage(),
        'latest_message_timestamp' : FieldValue.serverTimestamp(),
      });
    }
    catch (e) {
      throw Exception(e);
    }

    // for chat_rooms collection
    try {
      _userDataServices.handleChatRoomKeys(generateChatRoomID([currentUserId, receiverId]), receiverId);
      _userDataServices.handleContactList(receiverId);
      await _fireStore.collection('chat_rooms')
          .doc(generateChatRoomID([currentUserId, receiverId]))
          .collection('messages')
          .add(newMessage.mapMessage());
      await _fireStore.collection('chat_rooms')
          .doc(generateChatRoomID([currentUserId, receiverId]))
          .set({
        'members' : [currentUserId, receiverId],
        'latest_message' : newMessage.mapMessage(),
        'latest_message_timestamp' : FieldValue.serverTimestamp(),
      });
    }
    catch (e) {
      throw Exception(e);
    }
  }

  Stream<QuerySnapshot> getMyMessages(String userId, String otherUserId) {
    return _fireStore.collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('chat_rooms')
        .doc(generateChatRoomID([userId, otherUserId]))
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {/*
    if(_fireStore.collection('users')
        .doc(_firebaseAuth.currentUser!.uid).collection('chat_rooms')
        .doc(generateChatRoomID([userId, otherUserId])).collection('messa')
    )*/
    
    return _fireStore.collection('chat_rooms').doc(generateChatRoomID([userId, otherUserId])).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getChatRoomAsStream(String chatRoomID) {
    Future<DocumentSnapshot<Map<String, dynamic>>> chatRoom = _fireStore.collection('users').doc(_firebaseAuth.currentUser!.uid).collection('chat_rooms').doc(chatRoomID).get();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('chat_rooms')
        .doc(chatRoomID)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getChatRoomAsFuture(String chatRoomID) {
    return _fireStore.collection('users').doc(_firebaseAuth.currentUser!.uid).collection('chat_rooms').doc(chatRoomID).get();
  }

  Future<void> createChatRoom(String otherUserID, String otherUserEmail, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();

    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: otherUserID,
        receiverEmail: otherUserEmail,
        message: message);

    ChatRoom newChatRoom = ChatRoom(latestMessage: newMessage.mapMessage(), members: [currentUserId, otherUserID]);
    DocumentSnapshot<Map<String, dynamic>> chatRoomCheck = await _fireStore
        .collection('chat_rooms')
        .doc(generateChatRoomID([currentUserId, otherUserID]))
        .get();
    if (!chatRoomCheck.exists) {
      try {
        //create chat_room
        await _fireStore.collection('chat_rooms')
            .doc(generateChatRoomID([currentUserId, otherUserID]))
            .set(newChatRoom.mapChatRoom());
        //add first message
        await _fireStore.collection('chat_rooms')
            .doc(generateChatRoomID([currentUserId, otherUserID]))
            .collection('messages')
            .add(newMessage.mapMessage());
        //add chat_room_id to user: chat_room_keys
        _userDataServices.handleChatRoomKeys(generateChatRoomID([currentUserId, otherUserID]), otherUserID);
      } catch (e) {
        throw Exception(e);
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