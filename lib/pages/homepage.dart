import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/Components/my_list_tile.dart';
import 'package:practice_login/Components/my_post_button.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:practice_login/pages/chat_page.dart';
import 'package:practice_login/pages/profile.dart';
import 'package:practice_login/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:practice_login/services/auth_service.dart';
import 'package:practice_login/Components/my_textfield.dart';
import 'package:intl/intl.dart';

class HomePage2 extends StatefulWidget {
  //testing http json placeholder from here =>
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2();
}

// github token Juario
//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
class _HomePage2 extends State<HomePage2> {
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();
  final FirestoreDatabase _firestoreDatabase = FirestoreDatabase();
  late Stream<QuerySnapshot> postsStream;
  @override
  void initState() {
    super.initState();
    postsStream = _firestoreDatabase.getPostsStream();
  }

  void postMessage() {
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      database.addPost(message);
    }

    newPostController.clear();
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    /* final authService = Provider.of<AuthService>(context, listen: false); */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Container(
                  padding: const EdgeInsets.only(top: 10, left: 15),
                  child: Image.asset('images/Avatar1.png', height: 40)),
            ),
          ],
        ),
        actions: const [],
        backgroundColor: const Color.fromARGB(255, 124, 210, 231),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 25, right: 25),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: newPostController,
                      hintText: "Say Something",
                      obscuretext: false,
                    ),
                  ),
                  PostButton(onTap: postMessage)
                ],
              ),
            ),
            StreamBuilder(
                stream: database.getPostsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final posts = snapshot.data!.docs;

                  if (snapshot.data == null || posts.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: Text("No posts... Post Something"),
                      ),
                    );
                  }

                  return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];

                        String message = post['PostMessage'];
                        String userEmail = post['UserEmail'];
                        Timestamp timestamp = post['TimeStamp'];
                        Timestamp postTimeStamp = posts[index]['TimeStamp'];
                        String formattedTimestamp = _firestoreDatabase
                            .formatPostTimeStamp(postTimeStamp);

                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: ListTile(
                            tileColor: Colors.white,
                            isThreeLine: true,
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                trailing: const Text("try"),
                                leading: const CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        AssetImage('images/Avatar1.png')),
                                title: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(userEmail),
                                    Text(
                                      formattedTimestamp,
                                      style: const TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(message),
                                const Divider(thickness: 1),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          print("Tapped Like");
                                        },
                                        child: const Text("Like"),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          print("Tapped Comment");
                                        },
                                        child: const Text("Comment"),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          print("Tapped Share");
                                        },
                                        child: const Text("Share"),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      });
                })
          ],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('About'),
              onTap: () {},
              contentPadding: const EdgeInsets.only(top: 50, left: 70),
            ),
            const ListTile(
              title: Text('Help'),
              contentPadding: EdgeInsets.only(left: 70),
            ),
            const ListTile(
              title: Text('Dark Mode'),
              contentPadding: EdgeInsets.only(left: 70),
            ),
            const ListTile(
              title: Text('Freelancer Mode'),
              contentPadding: EdgeInsets.only(left: 70),
            ),
            const ListTile(
              title: Text('Account Settings'),
              contentPadding: EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Chats'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatPage()));
              },
              contentPadding: const EdgeInsets.only(left: 70),
            ),
            ListTile(
              title: const Text('Log out'),
              onTap: () {
                // Add your logic for logging out
                signUserOut();
              },
              leading: const Icon(Icons.logout),
            ),
          ],
        ),
      ),
    );
  }
}
