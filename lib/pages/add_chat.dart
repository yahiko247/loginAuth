import 'package:flutter/material.dart';

class AddChat extends StatefulWidget {
  const AddChat ({Key? key}) : super(key:key);

  State<AddChat> createState() => _AddChatState();
}

class _AddChatState extends State<AddChat> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find a user'),
      ),
    );
  }
}