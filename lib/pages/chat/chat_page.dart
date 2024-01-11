import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/Components/chat/empty_view.dart';
import 'package:practice_login/components/chat/warning_dialog.dart';
import 'package:practice_login/pages/chat/add_chat.dart';
import 'package:practice_login/pages/chat/archived_chats.dart';
import 'package:practice_login/pages/chat/chat_box.dart';
import 'package:practice_login/services/chat/chat_service.dart';
import 'package:practice_login/services/user_data_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

  @override void dispose() {
    super.dispose();
    _searchController.dispose();
  }

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
        surfaceTintColor: Colors.transparent,
        title: const Text('Chats'),
        centerTitle: true,
        actions: const [],
      ),
      body: Column(
          children: [
            _chatSearchBar(),
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
              title: const Text('Archived Chats'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatArchives()
                    )
                );
              },
              leading: const Icon(Icons.archive),
              contentPadding: const EdgeInsets.only(left: 35),
            ),
            ListTile(
              title: const Text('Contacts'),
              onTap: () {
                Navigator.pop(context);
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
                    )
                );
              },
              leading: const Icon(Icons.contacts),
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
          List<dynamic> checkList = currentUserData!['chat_room_keys'];
          if (checkList.isEmpty) {
            return Container(
                padding: const EdgeInsets.fromLTRB(60, 0, 60, 60),
                child: const Center(
                    child: EmptyView(
                      message: 'It\'s quiet here, tap the button below to start a conversation.',
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
                      contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      title: const Text('Error Loading Chat'),
                      leading: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                        child: Image.asset('images/Avatar1.png', height: 50),
                      ),
                      subtitle: const Text(''),
                    );
                  } else if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                      title: const Text('User'),
                      leading: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                        child: Image.asset('images/Avatar1.png', height: 50),
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
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WarningDialog(
                                        title: 'Delete Chat?',
                                        message: 'Are you sure you want to delete this conversation? (Only your copy of the conversation will be deleted)',
                                        confirmButtonText: 'Delete',
                                        confirmAction: () {
                                          Navigator.pop(context);
                                          _userDataServices.deleteChatRoomKey(_auth.currentUser!.uid, userData['uid']);
                                        }
                                    );
                                  }
                              );
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                          ),
                          SlidableAction(
                            onPressed: (context) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return WarningDialog(
                                        title: 'Archive conversation?',
                                        message: 'Are you sure you want to archive this conversation? (You will still be able to unarchive this conversation in the future)',
                                        confirmButtonText: 'Archive',
                                        confirmAction: () {
                                          Navigator.pop(context);
                                          _userDataServices.archiveChatRoom(_auth.currentUser!.uid, userData['uid']);
                                        }
                                    );
                                  }
                              );
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.archive,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                        title: Text(userFullName),
                        leading: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                          child: Image.asset('images/Avatar1.png', height: 50),
                        ),
                        subtitle: Text(
                            '${(chatRoomData['latest_message']['senderId'] == _auth.currentUser!.uid) ? 'You' : userData['first_name']}'
                                ': ${formatPreviewMessage(chatRoomData['latest_message']['message'])} · ${_chatService.formatMsgTimestamp(chatRoomData['latest_message_timestamp'] ?? Timestamp.now())}'
                        ),
                        onLongPress: () {
                          showModalBottomSheet(
                            showDragHandle: true,
                            context: context,
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: 240,
                                child: ListView(
                                  children: [
                                    ListTile(
                                      contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return WarningDialog(
                                                  title: 'Delete Chat?',
                                                  message: 'Are you sure you want to delete this conversation? (Only your copy of the conversation will be deleted)',
                                                  confirmButtonText: 'Delete',
                                                  confirmAction: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    _userDataServices.deleteChatRoomKey(_auth.currentUser!.uid, userData['uid']);
                                                  }
                                              );
                                            }
                                        );
                                      },
                                      leading: const Icon(Icons.delete),
                                      title: const Text('Delete this conversation'),
                                    ),
                                    ListTile(
                                      contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return WarningDialog(
                                                  title: 'Archive conversation',
                                                  message: 'Are you sure you want to archive this conversation? You will still be able to open this conversation in the future.',
                                                  confirmButtonText: 'Archive',
                                                  confirmAction: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                    _userDataServices.archiveChatRoom(_auth.currentUser!.uid, userData['uid']);
                                                  }
                                              );
                                            }
                                        );
                                      },
                                      leading: const Icon(Icons.archive),
                                      title: const Text('Archive'),
                                    ),
                                    ListTile(
                                      contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      leading: const Icon(Icons.check_box),
                                      title: const Text('Mark as read / unread'),
                                    ),
                                    ListTile(
                                      contentPadding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return WarningDialog(
                                                  title: 'Mute Chat?',
                                                  message: 'You will still be able to change this in the future.',
                                                  confirmButtonText: 'Mute',
                                                  confirmAction: () {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  }
                                              );
                                            }
                                        );
                                      },
                                      leading: const Icon(Icons.notifications_off),
                                      title: const Text('Mute conversation'),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
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
