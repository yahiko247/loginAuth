import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/Components/chat/empty_view.dart';
import 'package:practice_login/components/chat/warning_dialog.dart';
import 'package:practice_login/pages/chat/add_chat.dart';
import 'package:practice_login/pages/chat/chat_box.dart';
import 'package:practice_login/services/chat/chat_service.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ChatArchives extends StatefulWidget {
  const ChatArchives({Key? key}) : super(key: key);

  @override
  State<ChatArchives> createState() => _ChatArchivesState();
}

class _ChatArchivesState extends State<ChatArchives> {
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
          title: const Text('Archived Chats'),
          centerTitle: true,
          actions: const []
      ),
      body: Column(
          children: [
            Expanded(child: _buildChatPage())
          ]
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
      endDrawer: Drawer(
        width: 275,
        child: ListView(
          children: [
            FutureBuilder(
                future: _userDataServices.getCurrentUserDataAsFuture(),
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
                    title: Text('${userData['first_name']} ${userData['last_name']}'),
                    subtitle: Text('${userData['email']}'),
                    onTap: () {},
                    trailing: IconButton(icon: const Icon(Icons.settings), onPressed: () {},),
                    contentPadding: const EdgeInsets.only(left: 35, right: 20),
                  );
                }
            ),
            const Divider(thickness: 1),
            ListTile(
              title: const Text('Clear Archives'),
              onTap: () {
                Navigator.pop(context);
              },
              leading: const Icon(Icons.cleaning_services_rounded),
              contentPadding: const EdgeInsets.only(left: 35),
            ),
          ],
        ),
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
          List<dynamic> checkList = currentUserData!['archived_chat_rooms'];
          if (checkList.isEmpty) {
            return Container(
                padding: const EdgeInsets.fromLTRB(60, 0, 60, 60),
                child: const Center(
                    child: EmptyView(
                      message: 'You have no archived chats.',
                      displayIcon: true,
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

    List<dynamic> chatKeysList = currentUserData!['archived_chat_rooms'];

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
                      contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
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
                      contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
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

                  return Slidable(
                      key: UniqueKey(),
                      endActionPane: ActionPane(
                        extentRatio: 0.35,
                        motion: StretchMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {

                              },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                          ),
                          SlidableAction(
                            onPressed: (context) {
                              _userDataServices.restoreFromArchive(_auth.currentUser!.uid, userData['uid']);
                              },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.unarchive,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
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
                        onLongPress: () {},
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
                      )
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
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
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
