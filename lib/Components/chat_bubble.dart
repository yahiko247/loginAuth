import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String sender;
  final Timestamp msgtimestamp;

  String formatMsgTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    final timeFormat = DateFormat('hh:mm a');
    String formattedTimestamp = timeFormat.format(dateTime);

    return formattedTimestamp;
  }

  static FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static String? currentUser = _firebaseAuth.currentUser!.email;

  const ChatBubble({super.key, required this.message, required this.sender, required this.msgtimestamp});

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: (sender == currentUser) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment: (sender == currentUser) ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(child: Text('${sender} - ${formatMsgTimestamp(msgtimestamp)}'), padding: EdgeInsets.fromLTRB(5, 0, 5, 5)),
        Container(
            constraints: BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: (currentUser == sender) ? Colors.blue : Colors.grey
            ),
            child: Text(message, style: TextStyle(fontSize: 16),)
        ),
      ],
    );
  }
}