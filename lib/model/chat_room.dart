import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoom {
  final Map<String, dynamic> latestMessage;
  final List<String> members;

  ChatRoom({required this.latestMessage, required this.members});

  Map<String, dynamic> mapChatRoom() {
    return {
      'latest_message' : latestMessage,
      'latest_message_timestamp' : FieldValue.serverTimestamp(),
      'members' : members
    };
  }
}