import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/services/chat/chat_service.dart';

class UserDataServices extends ChangeNotifier {
  final String userID;

  UserDataServices({required this.userID});

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  String generateChatRoomID(List<String> ids) {
    ids.sort();
    String chatRoomId = ids.join("_");
    return chatRoomId;
  }

  // Current User Data as Stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserDataAsStream() {
    return _fireStore.collection('users').doc(userID).snapshots();
  }

  // Current User Data as Future
  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserDataAsFuture() {
    return _fireStore.collection('users').doc(userID).get();
  }

  // User Data as Stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataAsStream(String uid) {
    return _fireStore.collection('users').doc(uid).snapshots();
  }

  // User Data as Future
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDataAsFuture(String uid) {
    return _fireStore.collection('users').doc(uid).get();
  }

  // User Data Using Email
  Future<QuerySnapshot<Map<String, dynamic>>> getUserDataThroughEmail(String email) {
    return _fireStore.collection('users').where('email', isEqualTo: email).limit(1).get();
  }

  // Used for handling the 'contacts' field of each user
  Future<void> handleContactList(String newContactId) async {
    DocumentSnapshot<Map<String, dynamic>> userDataSnapshot = await getCurrentUserDataAsFuture();

    if(userDataSnapshot.exists && userDataSnapshot.data()!.containsKey('contacts')) {
      try {
        List<dynamic> userContactList = userDataSnapshot.data()!['contacts'];
        if (userContactList.isNotEmpty) {
          if (userContactList.contains(newContactId)) {
            userContactList.remove(newContactId);
            userContactList.insert(0, newContactId);
          } else if (!userContactList.contains(newContactId)) {
            userContactList.insert(0, newContactId);
          }
          await _fireStore.collection('users')
              .doc(_firebaseAuth.currentUser!.uid)
              .update({'contacts': userContactList});
        } else if (userContactList.isEmpty) {
          userContactList.insert(0, newContactId);
          await _fireStore.collection('users')
              .doc(_firebaseAuth.currentUser!.uid)
              .set({'contacts': userContactList}, SetOptions(merge: true));
        }
      } catch (e) {
        print(e);
      }
    } else {
      try {
        List<dynamic> userContactList = [newContactId];
        userContactList.insert(0, newContactId);
        await _fireStore.collection('users')
            .doc(_firebaseAuth.currentUser!.uid)
            .set({'contacts': userContactList}, SetOptions(merge: true));
      } catch (e) {print(e);}
    }
  }

  // Used for handling the 'chat_room_keys' field of each user
  Future<void> handleChatRoomKeys(String chatRoomID, String receiverID) async {
    DocumentSnapshot<Map<String, dynamic>> userDataSnapshot = await getCurrentUserDataAsFuture();
    DocumentSnapshot<Map<String, dynamic>> otherUserDataSnapshot = await getUserDataAsFuture(receiverID);
    if (userDataSnapshot.exists && userDataSnapshot.data()!.containsKey('chat_room_keys')) {
      try {
        List<dynamic> userChatRoomKeys = userDataSnapshot.data()!['chat_room_keys'];
        if (userChatRoomKeys.isNotEmpty) {
          if (userChatRoomKeys.contains(chatRoomID)) {
            userChatRoomKeys.remove(chatRoomID);
            userChatRoomKeys.insert(0, chatRoomID);
          } else {
            userChatRoomKeys.insert(0, chatRoomID);
          }
          await _fireStore.collection('users').doc(_firebaseAuth.currentUser!.uid).update({'chat_room_keys': userChatRoomKeys});
        } else {
          userChatRoomKeys.insert(0, chatRoomID);
          await _fireStore.collection('users').doc(_firebaseAuth.currentUser!.uid).set({'chat_room_keys': userChatRoomKeys}, SetOptions(merge: true));
        }
      } catch(e) {print(e);}
    } else {
      try {
        List<dynamic> userChatRoomKeys = [chatRoomID];
        await _fireStore.collection('users').doc(_firebaseAuth.currentUser!.uid).set({'chat_room_keys': userChatRoomKeys}, SetOptions(merge: true));
      } catch (e) {print(e);}
    }
    if (userDataSnapshot.exists && userDataSnapshot.data()!.containsKey('chat_room_keys')) {
      try {
        List<dynamic> userChatRoomKeys = otherUserDataSnapshot.data()!['chat_room_keys'];
        if (userChatRoomKeys.isNotEmpty) {
          if (userChatRoomKeys.contains(chatRoomID)) {
            userChatRoomKeys.remove(chatRoomID);
            userChatRoomKeys.insert(0, chatRoomID);
          } else {
            userChatRoomKeys.insert(0, chatRoomID);
          }
          await _fireStore.collection('users').doc(receiverID).update({'chat_room_keys': userChatRoomKeys});
        } else {
          userChatRoomKeys.insert(0, chatRoomID);
          await _fireStore.collection('users').doc(receiverID).set({'chat_room_keys': userChatRoomKeys}, SetOptions(merge: true));
        }
      } catch(e) {print(e);}
    } else {
      try {
        List<dynamic> userChatRoomKeys = [chatRoomID];
        await _fireStore.collection('users').doc(receiverID).set({'chat_room_keys': userChatRoomKeys}, SetOptions(merge: true));
      } catch (e) {print(e);}
    }
  }

  Future<void> deleteChatRoomKey(String userId, String otherUserId) async {
    DocumentSnapshot<Map<String, dynamic>> userDataSnapshot = await getCurrentUserDataAsFuture();

    if (userDataSnapshot.exists) {
      List<dynamic> chatRoomKeys = userDataSnapshot.data()!['chat_room_keys'];
      if (chatRoomKeys.contains(generateChatRoomID([userId, otherUserId]))) {
        chatRoomKeys.remove(generateChatRoomID([userId, otherUserId]));
        try {
          await _fireStore.collection('users')
              .doc(_firebaseAuth.currentUser!.uid)
              .set({'chat_room_keys': chatRoomKeys}, SetOptions(merge: true));
        } catch (e) {
          throw Exception(e);
        }
      }
    }
  }

  Future<void> archiveChatRoom(String userId, String otherUserId) async {
    DocumentSnapshot<Map<String, dynamic>> userDataSnapshot = await getCurrentUserDataAsFuture();

    if (userDataSnapshot.exists) {
      List<dynamic> chatRoomKeys = userDataSnapshot.data()!['chat_room_keys'];
      if (userDataSnapshot.data()!.containsKey('archived_chat_rooms')) {
        List<dynamic> archivedChatRooms = userDataSnapshot.data()!['archived_chat_rooms'];
        if (chatRoomKeys.contains(generateChatRoomID([userId, otherUserId]))) {
          chatRoomKeys.remove(generateChatRoomID([userId, otherUserId]));
          archivedChatRooms.insert(0, generateChatRoomID([userId, otherUserId]));
          try {
            await _fireStore.collection('users')
                .doc(_firebaseAuth.currentUser!.uid)
                .set({'chat_room_keys': chatRoomKeys}, SetOptions(merge: true));
            await _fireStore.collection('users')
                .doc(_firebaseAuth.currentUser!.uid)
                .set({'archived_chat_rooms': archivedChatRooms}, SetOptions(merge: true));
          } catch (e) {
            throw Exception(e);
          }
        } else {
          List<dynamic> archivedChatRooms = [];
          chatRoomKeys.remove(generateChatRoomID([userId, otherUserId]));
          archivedChatRooms.insert(0, generateChatRoomID([userId, otherUserId]));
          try {
            await _fireStore.collection('users')
                .doc(_firebaseAuth.currentUser!.uid)
                .set({'chat_room_keys': chatRoomKeys}, SetOptions(merge: true));
            await _fireStore.collection('users')
                .doc(_firebaseAuth.currentUser!.uid)
                .set({'archived_chat_rooms': archivedChatRooms}, SetOptions(merge: true));
          } catch (e) {
            throw Exception(e);
          }
        }
      }
    }
  }

  Future<void> restoreFromArchive(String userId, String otherUserId) async {
    DocumentSnapshot<Map<String, dynamic>> userDataSnapshot = await getCurrentUserDataAsFuture();
    if(userDataSnapshot.exists) {
      List<dynamic> chatRoomKeys = userDataSnapshot.data()!['chat_room_keys'];
      List<dynamic> archivedChatRooms = userDataSnapshot.data()!['archived_chat_rooms'];
      if (archivedChatRooms.contains(generateChatRoomID([userId, otherUserId]))) {
        archivedChatRooms.remove(generateChatRoomID([userId, otherUserId]));
        chatRoomKeys.insert(0, generateChatRoomID([userId, otherUserId]));
        try {
          await _fireStore.collection('users')
              .doc(_firebaseAuth.currentUser!.uid)
              .set({'archived_chat_rooms': archivedChatRooms}, SetOptions(merge: true));
          await _fireStore.collection('users')
              .doc(_firebaseAuth.currentUser!.uid)
              .set({'chat_room_keys': chatRoomKeys}, SetOptions(merge: true));
        } catch (e) {
          throw Exception(e);
        }
      }
    }
  }

}