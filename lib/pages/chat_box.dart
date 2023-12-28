import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/Components/chat_bubble.dart';
import 'package:practice_login/Components/my_textfield.dart';
import 'package:practice_login/services/chat/chat_service.dart';

class ChatBox extends StatefulWidget {
  final String userEmail;
  final String userId;
  final String userFirstName;
  final String userLastName;

  const ChatBox({Key? key,
    required this.userEmail,
    required this.userId,
    required this.userFirstName,
    required this.userLastName
  }) : super(key: key);

  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final TextEditingController _messageInputController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageInputController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.userId, widget.userEmail, _messageInputController.text);
      _messageInputController.clear();
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Row(
              children: [
                Icon(Icons.menu)
              ],
            ),
          )
        ],
        title: Container(
          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Column(
            children: [
              Align(child: Text('${widget.userFirstName} ${widget.userLastName}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),), alignment: Alignment.centerLeft),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.userEmail,
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w300),
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
          _buildMessageInput(),
        ],
      )
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.userId, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.black));
        }

        return ListView(
          reverse: true,
          children: snapshot.data!.docs.reversed.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var currentUser = _firebaseAuth.currentUser!;
    var alignment = (data['senderId'] == currentUser.uid) ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      padding: EdgeInsets.all(15),
      alignment: alignment,
      child: Column(
        children: [
          ChatBubble(message: data['message'], sender: data['senderEmail'], msgtimestamp: (data['timestamp']) ?? Timestamp.now()),
        ],
      )
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _messageInputController,
              decoration: InputDecoration(
                  hintText: 'Enter a message',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(8.0)
                  )
              ),
            ),
          ),
          SizedBox(width: 15),
          IconButton(onPressed: sendMessage, icon: Icon(Icons.send), color: Colors.black,)
        ],
      ),
    );
  }
}