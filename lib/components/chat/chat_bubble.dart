import 'package:flutter/material.dart';

// Dependencies
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Service(s)
import 'package:practice_login/services/chat/chat_service.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String senderId;
  final String senderName;
  final Timestamp messageTimestamp;
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  ChatBubble({super.key, required this.message, required this.senderId, required this.senderName, required this.messageTimestamp});

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: (senderId == _firebaseAuth.currentUser!.uid) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment: (senderId == _firebaseAuth.currentUser!.uid) ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            child: Text('$senderName - ${_chatService.formatMsgTimestamp(messageTimestamp)}')
        ),
        Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: (senderId == _firebaseAuth.currentUser!.uid) ? Colors.blue : Colors.grey
            ),
            child: Text(message, style: const TextStyle(fontSize: 16),)
        ),
      ]
    );
  }
}