import 'package:flutter/material.dart';

// Dependencies
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practice_login/Components/chat/empty_view.dart';
import 'package:practice_login/components/chat/chat_drawers.dart';

// Service(s)
import 'package:practice_login/services/chat/chat_service.dart';

// Components
import 'package:practice_login/components/chat/chat_bubble.dart';
import 'package:practice_login/components/chat/chat_input.dart';
import 'package:practice_login/services/user_data_services.dart';

class ChatBox extends StatefulWidget {
  final String userEmail;
  final String userId;
  final String userFirstName;
  final String userLastName;
  final bool? disableInput;
  final String origin;

  const ChatBox({
    Key? key,
    required this.userEmail,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    this.disableInput,
    required this.origin
  }) : super(key: key);

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
        backgroundColor: Color.fromARGB(255, 124, 210, 231),
        surfaceTintColor: const Color.fromARGB(255, 124, 210, 231),
        actions: [],
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
        endDrawer: widget.origin == 'chat_page' ? ChatPageDrawer(userId: widget.userId)
            : widget.origin == 'archived_chats' ? ArchivedPageDrawer(userId: widget.userId)
            : ContactPageDrawer(userId: widget.userId),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          MessageInput(userId: widget.userId, userEmail: widget.userEmail, disableInput: widget.disableInput ?? false, returnToChatPage: widget.origin == 'add_chat' ? true : false),
        ],
      )
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMyMessages(_firebaseAuth.currentUser!.uid, widget.userId),
      builder: (context, messagesSnapshot) {
        if (messagesSnapshot.hasError) {
          return Text('Error ${messagesSnapshot.error}');
        }

        if (messagesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (messagesSnapshot.data!.docs.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Text('Say hello!', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),

              SizedBox(height: 15),
              Icon(Icons.waving_hand_outlined, size: 50)
            ],
          );
        }

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          cacheExtent: 25,
          reverse: true,
          children: messagesSnapshot.data!.docs.reversed
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
        child: ChatBubble(
            message: data['message'],
            senderId: data['senderId'],
            senderName: data['senderId'] == _firebaseAuth.currentUser!.uid ? 'You' : widget.userFirstName,
            messageTimestamp: (data['timestamp']) ?? Timestamp.now()
        )
    );
  }

}