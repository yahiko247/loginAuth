import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/pages/chat_box.dart';
import 'package:practice_login/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {

  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: Colors.blue,
      ),
      body: _buildUserList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  //Build User List
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              child: const CircularProgressIndicator(),
            ),
          );
        }

        return FutureBuilder<List<dynamic>?>(
          future: _chatService.getContacts(_auth.currentUser!.uid),
          builder: (context, contactsSnapshot) {
            if (contactsSnapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            if (contactsSnapshot.hasError) {
              return const Text('error fetching contacts');
            }

            List<dynamic>? contacts = contactsSnapshot.data;

            if (!contacts!.isEmpty) {
              return ListView(
                children: snapshot.data!.docs.map<Widget>((doc) => _buildUserListItem(doc, contacts)).toList(),
              );
            } else {
              return Center(
                child: Container(
                  child: Text(
                    'It\'s quiet here, start a conversation by tapping the add button below.',
                    style: TextStyle(fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.all(50),
                )
              );
            }
          },
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document, List<dynamic>? contacts) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (_auth.currentUser!.uid != data['uid'] && contacts != null && contacts.contains(data['uid'])) {
      return ListTile(
        title: Text(data['email']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatBox(userEmail: data['email'], userId: data['uid'])),
          );
        },
      );
    }
    return Container();
  }
}