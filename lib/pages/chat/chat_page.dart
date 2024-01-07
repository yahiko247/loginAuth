import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/pages/chat/add_chat.dart';
import 'package:practice_login/pages/chat/chat_box.dart';
import 'package:practice_login/services/chat/chat_service.dart';
import 'package:practice_login/services/user_data_services.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  final TextEditingController _searchController = TextEditingController();

  String formatPreviewMessage(String message) {
    String formattedMessage = '';
    if(message.contains('\n')) {
      formattedMessage = message.split(RegExp(r'\r?\n'))[0];
      if (formattedMessage.length > 20) {
        formattedMessage = '${formattedMessage.substring(0, 20)}...';
      } else {
        formattedMessage = '$formattedMessage...';
      }
    } else if (message.length > 20) {
      formattedMessage = '${message.substring(0, 20)}...';
    } else {
      formattedMessage = message;
    }
    return formattedMessage;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              // Logic here
            },
            child: Container(
                padding: const EdgeInsets.all(15),
                child: const Icon(Icons.menu)
            ),
          )
        ]
      ),
      body: Container(
          padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Column(
              children: [
                _chatSearchBar(),
                Expanded(child: _buildChatPage())
              ]
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {return const AddChat();},
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                var begin = const Offset(.900, 0.0);
                var end = Offset.zero;
                var curve = Curves.ease;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child);
                },
              transitionDuration: const Duration(milliseconds: 300),
            ));
          },
          backgroundColor: const Color.fromARGB(255, 124, 210, 231),
          child: const Icon(Icons.edit)
      ),
    );
  }

  Widget _buildChatPage() {
    return StreamBuilder(
        stream: _userDataServices.getCurrentUserDataAsStream(),
        builder: (context, currentUserDataSnapshot) {

          if (currentUserDataSnapshot.hasError) {
            return const Text('Error Loading Chat Page');
          } else if (currentUserDataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic>? currentUserData = currentUserDataSnapshot.data!.data();
          List<dynamic> checkList = currentUserData!['chat_room_keys'];
          if (checkList.isEmpty) {
            return Container(
                padding: const EdgeInsets.all(60),
                child: const Center(
                    child: Text(
                        'It\'s quiet here, tap the button below to start a conversation.',
                        textAlign: TextAlign.center
                    )
                )
            );
          }
          return ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            cacheExtent: 100,
            children: _buildChatPageItems(currentUserData),
          );
        }
    );

  }

  List<Widget> _buildChatPageItems(Map<String, dynamic>? currentUserData) {

    List<dynamic> chatKeysList = currentUserData!['chat_room_keys'];

    List<Widget> chats = chatKeysList.map((key) {
      return StreamBuilder(
          stream: _chatService.getChatRoom(key),
          builder: (context, chatRoomSnapshot) {
            if (chatRoomSnapshot.hasError) {
              return const Text('Error loading messages');
            } else if (chatRoomSnapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }

            Map<String, dynamic>? chatRoomData = chatRoomSnapshot.data!.data();
            List<dynamic> chatMembers = chatRoomData!['members'];
            if (chatMembers.contains(_auth.currentUser!.uid)) {
              chatMembers.remove(_auth.currentUser!.uid);
            }

            return StreamBuilder(
                stream: _userDataServices.getUserDataAsStream(chatMembers[0]),
                builder: (context, userDataSnapshot) {
                  if (userDataSnapshot.hasError) {
                    return ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      title: const Text('Error Loading Chat'),
                      leading: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.red),
                        child: const Icon(Icons.person, size: 35),
                      ),
                      subtitle: const Text(''),
                    );
                  } else if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      title: const Text('User'),
                      leading: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.red),
                        child: const Icon(Icons.person, size: 35),
                      ),
                      subtitle: const Text(''),
                    );
                  }

                  Map<String, dynamic>? userData = userDataSnapshot.data!.data();
                  String userFullName = '${userData!['first_name']} ${userData['last_name']}';

                  return ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(userFullName),
                    leading: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.red),
                      child: const Icon(Icons.person, size: 35),
                    ),
                    subtitle: Text(
                        '${(chatRoomData['latest_message']['senderId'] == _auth.currentUser!.uid) ? 'You' : userData['first_name']}'
                            ': ${formatPreviewMessage(chatRoomData['latest_message']['message'])} · ${_chatService.formatMsgTimestamp(chatRoomData['latest_message_timestamp'] ?? Timestamp.now())}'
                    ),
                    onLongPress: () {
                      showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
                    },
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              ChatBox(
                                  userEmail: userData['email'],
                                  userId: userData['uid'],
                                  userFirstName: userData['first_name'],
                                  userLastName: userData['last_name']
                              )
                          )
                      );
                    },
                  );
                }
            );
          }
      );
    }).toList();
    return chats;
  }

  Widget _chatSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              autofocus: false,
              onTap: () {
              },
              controller: _searchController,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                  hintText: 'Search',
                  prefixIcon: Container(padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), child: Icon(Icons.contacts, color: Colors.grey[600],),),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 13)
              ),
            ),
          )
        ],
      ),
    );
  }
}
