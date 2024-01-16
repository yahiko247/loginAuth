import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/components/my_post_button.dart';
import 'package:practice_login/components/my_textfield.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:practice_login/pages/homepage.dart';
import 'package:file_picker/file_picker.dart';

import '../pages/post/create_post.dart';
class NestedTabBar extends StatefulWidget {
  NestedTabBar(this.outerTab, {super.key});
  final currentUser = FirebaseAuth.instance.currentUser!;

  final String outerTab;

  @override
  State<NestedTabBar> createState() => _NestedTabBar();
}

class _NestedTabBar extends State<NestedTabBar> with TickerProviderStateMixin {
  late final TabController _tabController;
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();
  final FirestoreDatabase _firestoreDatabase = FirestoreDatabase();
  late Stream<QuerySnapshot> postsStream;
  List<PlatformFile>? _pickedFiles;

  @override
  void initState() {
    super.initState();
    postsStream = _firestoreDatabase.getPostsStream();
    _tabController = TabController(length: 2, vsync: this);
  }

  void postMessage() {
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      database.addPost(message);
    }

    newPostController.clear();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Future<void> addImages() async {
    try {
      final files = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['jpg', 'png']
      );
      if (files != null && files.files.isNotEmpty) {
        setState(() {
          _pickedFiles = files.files;
        });
      }
      else {
        _pickedFiles = [];
      }
    } catch (e) {
      throw Exception(e);
    }
    goToCreate();
  }

  void goToCreate() {
    List<PlatformFile> imagesPicked = _pickedFiles!;
    setState(() {
      _pickedFiles = [];
    });
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return CreateNewPost(imagesPicked: imagesPicked);
        })
    );
  }
  @override
  Widget build(BuildContext context) {
    final currentUserEmail = widget.currentUser.email;
    return Column(children: <Widget>[
      TabBar.secondary(
          labelColor: Colors.black,
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'P R O F I L E'),
            Tab(text: 'P O S T'),
          ]),
      Expanded(
          child: TabBarView(controller: _tabController, children: <Widget>[
        Card(
          margin: const EdgeInsets.all(16.0),
          child: Text('A B O U T    M E'),
        ),
        Card(
          child: SingleChildScrollView(
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
                      final userPosts = posts
                          .where(
                              (post) => post['UserEmail'] == currentUserEmail)
                          .toList();

                      if (userPosts.isEmpty) {
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
                          itemCount: userPosts.length,
                          itemBuilder: (context, index) {
                            final post = userPosts[index];

                            String message = post['PostMessage'];
                            String userEmail = post['UserEmail'];
                            Timestamp timestamp = post['TimeStamp'];
                            List<dynamic> mediaReferences = post['MediaReferences'];
                            Timestamp postTimeStamp =
                                userPosts[index]['TimeStamp'];
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
                                        Text(
                                            '${post['UserFirstName']}'
                                            '${post['UserLastName']}'
                                        ),

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
                                    if (message.isNotEmpty)
                                      Text(message, style: const TextStyle(fontSize: 16)),
                                    if (mediaReferences.isNotEmpty)
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            for(String url in mediaReferences)
                                              Container(
                                                height: 300,
                                                width: 300,
                                                child: Image.network(url),
                                              )
                                          ],
                                        ),
                                      ),
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
        ),
      ]))
    ]);
  }
}
