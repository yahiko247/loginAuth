import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/pages/add_chat.dart';
import 'package:practice_login/pages/chat_box.dart';
import 'package:practice_login/services/chat/chat_service.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:practice_login/theme/dark_mode.dart';
import 'package:practice_login/theme/light_mode.dart';

class ChatPage extends StatefulWidget {

  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatService _chatService = ChatService();
  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        titleSpacing: 0,
        centerTitle: true,
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(15),
              child: Icon(Icons.menu),
            ),
          )
        ],
      ),
      body: Column(children: [
        _chatSearchBar(), Expanded(child: _buildChatPage())
      ],),

      floatingActionButton: FloatingActionButton(
        onPressed: () {Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {return AddChat();},
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(.900, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );},
          transitionDuration: Duration(milliseconds: 300),
        ),);},
        child: Icon(Icons.edit),
        backgroundColor: Color.fromARGB(255, 124, 210, 231),
      ),
    );
  }

  //Build User List

  Widget _buildChatPage() {

    return StreamBuilder(
        stream: _userDataServices.getCurrentUserDataAsStream(),
        builder: (context, currentUserDataSnapshot) {

          if (currentUserDataSnapshot.hasError) {
            return Text('Error Loading Chat Page');
          } else if (currentUserDataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic>? currentUserData = currentUserDataSnapshot.data!.data();
          List<dynamic> checkList = currentUserData!['chat_room_keys'];
          if (checkList.isEmpty) {
            return Container(
                padding: EdgeInsets.all(60),
                child: const Center(
                    child: Text(
                        'It\'s quiet here, tap the button below to start a conversation. '
                            '\n\nNOTE (FOR DEBUG): Use test@gmail.com para naay mu tunga nga messages',
                        textAlign: TextAlign.center
                    )
                )
            );
          }

          return ListView(
            children: _buildChatPageItems(currentUserData),
          );
        }
    );

  }

  List<Widget> _buildChatPageItems(Map<String, dynamic>? _currentUserData) {

    List<dynamic> chatKeysList = _currentUserData!['chat_room_keys'];

    List<Widget> chats = chatKeysList.map((key) {
      return StreamBuilder(
          stream: _chatService.getChatRoom(key),
          builder: (context, chatRoomSnapshot) {
            if (chatRoomSnapshot.hasError) {
              return Text('Error loading messages');
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
                      contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                      title: Text('Error Loading Chat'),
                      leading: Container(
                        child: Icon(Icons.person, size: 35),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.red),
                      ),
                      subtitle: Text(' '),
                    );
                  } else if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                      title: Text('User'),
                      leading: Container(
                        child: Icon(Icons.person, size: 35),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.red),
                      ),
                      subtitle: Text(' '),
                    );
                  }

                  Map<String, dynamic>? userData = userDataSnapshot.data!.data();
                  String userFullName = '${userData!['first_name']} ${userData['last_name']}';

                  return ListTile(
                    contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                    title: Text(userFullName),
                    leading: Container(
                      child: Icon(Icons.person, size: 35),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.red),
                    ),
                    subtitle: Text(
                        '${(chatRoomData['latest_message']['senderId'] == _auth.currentUser!.uid) ? 'You' : userData['first_name']}'
                            ': ${chatRoomData['latest_message']['message']} · ${_chatService.formatMsgTimestamp(chatRoomData['latest_message_timestamp'] ?? Timestamp.now())}'
                    ),
                    onLongPress: () {
                      showDialog(context: context, builder: (context) => Center(child: CircularProgressIndicator(

                      )));
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
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              onTap: () {print('wow');},
              controller: _searchController,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black), borderRadius: BorderRadius.circular(8.0)),
                  hintText: 'Search',
                  prefixIcon: Container(child: Icon(Icons.search, color: Colors.grey[600],), padding: EdgeInsets.fromLTRB(5, 0, 0, 0),),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 13)
              ),
            ),
          )
        ],
      ),
    );
  }
}
