import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Services
import 'package:practice_login/services/chat/chat_service.dart';
import 'package:practice_login/services/user_data_services.dart';

import '../../pages/chat/chat_box.dart';

class MessageInput extends StatefulWidget {
  final String userId;
  final String userEmail;
  final bool disableInput;
  final bool? returnToChatPage;
  const MessageInput({super.key, required this.userId, required this.userEmail, required this.disableInput, this.returnToChatPage});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageInputController = TextEditingController();
  final ChatService _chatService = ChatService();
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  bool isValid = false;

  void enableSend() {
    setState(() {
      isValid = _messageInputController.text.trim().isNotEmpty;
    });
  }

  void sendMessage() async {
    if (widget.returnToChatPage ?? false) {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return FutureBuilder(
                future:_userDataServices.getUserDataAsFuture(widget.userId),
                builder: (context, userDataSnapshot) {
                  if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (userDataSnapshot.hasError) {
                    return const Center(child: Text('Error loading user details'));
                  }

                  Map<String, dynamic>? userData = userDataSnapshot.data!.data()!;
                  return ChatBox(
                    userEmail: userData['email'],
                    userId: userData['uid'],
                    userFirstName: userData['first_name'],
                    userLastName: userData['last_name'],
                    origin: 'chat_page',
                  );
                }
            );
          })
      );
    }
    String message = _messageInputController.text;
    _messageInputController.clear();
    if (message.isNotEmpty) {
      await _chatService.sendMessage(widget.userId, widget.userEmail, message.trim());
    }
  }

  @override
  void initState() {
    _messageInputController.addListener(enableSend);
    super.initState();
  }

  @override
  void dispose() {
    _messageInputController.removeListener(enableSend);
    _messageInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              enabled: !widget.disableInput,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              minLines: 1,
              controller: _messageInputController,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 13),
                  hintText: !widget.disableInput ? 'Enter a message' : 'Unarchive to send message',
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(8.0))),
            ),
          ),
          const SizedBox(width: 13),
          IconButton(
              onPressed:isValid ? sendMessage : null,
              icon: const Icon(Icons.send),
              color: Colors.black,
              iconSize: 25
          )
        ],
      ),
    );
  }

}