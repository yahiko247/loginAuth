import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice_login/components/chat/warning_dialog.dart';


// Service(s)

// Components
import 'package:practice_login/services/user_data_services.dart';

import '../../pages/chat/chat_box.dart';
import '../../pages/freelancerstalkingpage.dart';
import '../../pages/profile.dart';
import '../../pages/userstalkingpage.dart';

class ChatPageDrawer extends StatefulWidget{
  final String userId;
  const ChatPageDrawer({super.key,required this.userId});

  @override
  State<ChatPageDrawer> createState() => _ChatPageDrawer(userId: userId);
}

class _ChatPageDrawer extends State<ChatPageDrawer> {
  final String userId;
  _ChatPageDrawer({required this.userId});

  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void userNavigator(String userEmail,) {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => UserStalkPage(userEmail: userEmail)
        )
    );
  }

  void freelancerNavigator(String userEmail,) {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context) => FreelancerStalkPage(userEmail: userEmail)
        )
    );
  }

  void userProfileNavigator() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ProfilePage()
        )
    );
  }
/*
  Future<void> freelancerIdentifier2(String email, BuildContext context) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_postData['user_id'])
        .get();
    Map <String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;

    if(_postData['user_id']==FirebaseAuth.instance.currentUser!.uid) {
      userProfileNavigator();
    }else if (userData!.containsKey('freelancer')) {
      bool? isFreelancer = snapshot['freelancer'];
      if (isFreelancer == true) {
        freelancerNavigator(_postData['user_email']);
      } else {
        userNavigator(_postData['user_email']);
      }
    } else {
      userNavigator(_postData['user_email']);
    }
  }*/
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 275,
      child: ListView(
        children: [
          FutureBuilder(
              future: _userDataServices.getUserDataAsFuture(userId),
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
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {return UserStalkPage(userEmail: userData['email']);})
                    );
                  },
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
                          Navigator.pop(context);
                          _userDataServices.deleteConversation(_auth.currentUser!.uid, userId);
                        }
                    );
                  }
              );
            },
            leading: const Icon(Icons.delete),
            contentPadding: const EdgeInsets.only(left: 30),
          ),
          ListTile(
            title: const Text('Archive Conversation'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return WarningDialog(
                        title: 'Archive conversation?',
                        message: 'Are you sure you want to archive this conversation? (You will still be able to unarchive this conversation in the future)',
                        confirmButtonText: 'Archive',
                        confirmAction: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          _userDataServices.archiveChatRoom(_auth.currentUser!.uid, userId);
                        }
                    );
                  }
              );
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
    );
  }
}

class ArchivedPageDrawer extends StatelessWidget {
  final String userId;

  ArchivedPageDrawer({super.key, required this.userId});

  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 275,
      child: ListView(
        children: [
          FutureBuilder(
              future: _userDataServices.getUserDataAsFuture(userId),
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
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {return UserStalkPage(userEmail: userData['email']);})
                    );
                  },
                  contentPadding: const EdgeInsets.only(left: 30, right: 20),
                );
              }
          ),
          const Divider(thickness: 1),
          ListTile(
            title: const Text('Unarchive Conversation'),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return WarningDialog(
                        title: 'Restore conversation?',
                        message: 'You are about to restore a conversation',
                        confirmButtonText: 'Unarchive',
                        confirmAction: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          _userDataServices.restoreFromArchive(_auth.currentUser!.uid, userId);
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  FutureBuilder(
                                      future: _userDataServices.getUserDataAsFuture(userId),
                                      builder: (context, userSnapShot) {
                                        if (userSnapShot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        }
                                        Map<String, dynamic>? userData = userSnapShot.data!.data()!;
                                        return ChatBox(
                                          userEmail: userData['email'],
                                          userId: userData['uid'],
                                          userFirstName: userData['first_name'],
                                          userLastName: userData['last_name'],
                                          origin: 'chat_page',
                                        );
                                      }
                                  )
                              )
                          );
                        }
                    );
                  }
              );
            },
            leading: const Icon(Icons.archive),
            contentPadding: const EdgeInsets.only(left: 30),
          ),
          ListTile(
            title: const Text('Delete Conversation'),
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
                          _userDataServices.deleteConversation(_auth.currentUser!.uid, userId);
                        }
                    );
                  }
              );
            },
            leading: const Icon(Icons.delete),
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
    );
  }
}

class ContactPageDrawer extends StatelessWidget {
  final String userId;

  ContactPageDrawer({super.key, required this.userId});

  final UserDataServices _userDataServices = UserDataServices(userID: FirebaseAuth.instance.currentUser!.uid);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 275,
      child: ListView(
        children: [
          FutureBuilder(
              future: _userDataServices.getUserDataAsFuture(userId),
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
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {return UserStalkPage(userEmail: userData['email']);})
                    );
                  },
                  contentPadding: const EdgeInsets.only(left: 30, right: 20),
                );
              }
          ),
          const Divider(thickness: 1),
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
    );
  }
}