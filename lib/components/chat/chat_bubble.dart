import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:practice_login/services/chat/chat_service.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String sender;
  final Timestamp msgtimestamp;
  static ChatService _chatService = ChatService();

  static FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  const ChatBubble({super.key, required this.message, required this.sender, required this.msgtimestamp});

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: (sender == _firebaseAuth.currentUser!.email) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment: (sender == _firebaseAuth.currentUser!.email) ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            child: Text('${!(sender == _firebaseAuth.currentUser!.email) ? sender : 'You'} - ${_chatService.formatMsgTimestamp(msgtimestamp)}')
        ),
        Container(
            constraints: BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: (_firebaseAuth.currentUser!.email == sender) ? Colors.blue : Colors.grey
            ),
            child: Text(message, style: TextStyle(fontSize: 16),)
        ),
      ],
    );
  }
}