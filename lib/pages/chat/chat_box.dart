import 'package:flutter/material.dart';

// Dependencies
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  const ChatBox({
    Key? key,
    required this.userEmail,
    required this.userId,
    required this.userFirstName,
    required this.userLastName
  }) : super(key: key);

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final ChatService _chatService = ChatService();
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
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
        endDrawer: Drawer(
          width: 275,
          child: ListView(
            children: [
              FutureBuilder(
                  future: _userDataServices.getUserDataAsFuture(widget.userId),
                  builder: (BuildContext context, userDataSnapshot) {
                    if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        title: const Text(''),
                        subtitle: const Text(''),
                        onTap: () {},
                        trailing: IconButton(icon: const Icon(Icons.settings), onPressed: () {},),
                        contentPadding: const EdgeInsets.only(left: 35, right: 20),
                      );
                    }
                    if (userDataSnapshot.hasError) {
                      return ListTile(
                        title: const Text('Error Loading Data'),
                        subtitle: const Text('Err'),
                        onTap: () {},
                        trailing: IconButton(icon: const Icon(Icons.settings), onPressed: () {},),
                        contentPadding: const EdgeInsets.only(left: 35, right: 20),
                      );
                    }

                    Map<String, dynamic>? userData = userDataSnapshot.data!.data()!;

                    return ListTile(
                      leading: Image.asset('images/Avatar1.png', height: 45),
                      title: Text('${userData['first_name']} ${userData['last_name']}'),
                      subtitle: Text('${userData['email']}'),
                      onTap: () {},
                      contentPadding: const EdgeInsets.only(left: 30, right: 20),
                    );
                  }
              ),
              const Divider(thickness: 1),
              ListTile(
                title: const Text('Mute Conversation'),
                onTap: () {
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.notifications_off),
                contentPadding: const EdgeInsets.only(left: 30),
              ),
              ListTile(
                title: const Text('Delete Conversation'),
                onTap: () {
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.delete),
                contentPadding: const EdgeInsets.only(left: 30),
              ),
              ListTile(
                title: const Text('Archive Conversation'),
                onTap: () {
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.archive),
                contentPadding: const EdgeInsets.only(left: 30),
              ),
              ListTile(
                title: const Text('Block this user'),
                onTap: () {
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.block),
                contentPadding: const EdgeInsets.only(left: 30),
              ),
            ],
          ),
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
      stream: _chatService.getMessages(_firebaseAuth.currentUser!.uid, widget.userId),
      builder: (context, messagesSnapshot) {
        if (messagesSnapshot.hasError) {
          return Text('Error ${messagesSnapshot.error}');
        }

        if (messagesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
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