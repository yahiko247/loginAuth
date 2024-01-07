import 'package:flutter/material.dart';

// Dependencies
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Services / API
import 'package:practice_login/services/chat/chat_service.dart';

// Components
import 'package:practice_login/components/chat/chat_bubble.dart';
import 'package:practice_login/components/chat/chat_input.dart';

class ChatBox extends StatefulWidget {
  final String userEmail;
  final String userId;
  final String userFirstName;
  final String userLastName;

  const ChatBox(
      {Key? key,
      required this.userEmail,
      required this.userId,
      required this.userFirstName,
      required this.userLastName})
      : super(key: key);

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: const Row(
              children: [Icon(Icons.menu)],
            ),
          )
        ],
        title: Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.userFirstName} ${widget.userLastName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.userEmail,
                  style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300),
                ),
              )
            ],
          ),
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          MessageInput(userId: widget.userId, userEmail: widget.userEmail),
        ],
      )
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.userId, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          cacheExtent: 50,
          reverse: true,
          children: snapshot.data!.docs.reversed
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var currentUser = _firebaseAuth.currentUser!;
    var alignment = (data['senderId'] == currentUser.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
        padding: const EdgeInsets.all(15),
        alignment: alignment,
        child: Column(
          children: [
            ChatBubble(
                message: data['message'],
                sender: data['senderEmail'],
                msgtimestamp: (data['timestamp']) ?? Timestamp.now()),
          ],
        ));
  }

}