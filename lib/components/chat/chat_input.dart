import 'package:flutter/material.dart';

// Services / API
import 'package:practice_login/services/chat/chat_service.dart';

class MessageInput extends StatefulWidget {
  final String userId;
  final String userEmail;
  const MessageInput({Key? key, required this.userId, required this.userEmail}) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageInputController = TextEditingController();
  final ChatService _chatService = ChatService();
  bool isValid = false;

  void enableSend() {
    setState(() {
      isValid = _messageInputController.text.trim().isNotEmpty;
    });
  }

  void sendMessage() async {
    String message = _messageInputController.text;
    _messageInputController.clear();
    if (message.isNotEmpty) {
      await _chatService.sendMessage(
          widget.userId, widget.userEmail, message.trim());
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
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              minLines: 1,
              controller: _messageInputController,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 13),
                  hintText: 'Enter a message',
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(8.0))),
            ),
          ),
          const SizedBox(width: 13),
          IconButton(
              onPressed: isValid ? sendMessage : null,
              icon: const Icon(Icons.send),
              color: Colors.black,
              iconSize: 25
          )
        ],
      ),
    );
  }

}