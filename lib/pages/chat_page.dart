import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/pages/chat_box.dart';

class ChatPage extends StatefulWidget {

  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.blue,
      ),
      body: _buildUserList()
    );
  }

  //Build User List
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return const Text('error');
        }
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading');
        }

        return ListView(children: snapshot.data!.docs.map<Widget>((doc) => _buildUserListItem(doc)).toList()
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        title: Text(data['email']),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatBox(userEmail: data['email'], userId: data['uid']),),);
        }
      );
    }
    return Container();
  }
}