import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:practice_login/database/firestore.dart';

class NestedTabBar2 extends StatefulWidget {
  String userEmail;
  NestedTabBar2(this.outerTab, {super.key, required this.userEmail});
  final currentUser = FirebaseAuth.instance.currentUser!;

  final String outerTab;

  @override
  State<NestedTabBar2> createState() => _NestedTabBar2();
}

class _NestedTabBar2 extends State<NestedTabBar2>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();
  final FirestoreDatabase _firestoreDatabase = FirestoreDatabase();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            const Card(
              margin: EdgeInsets.all(16.0),
              child: Text('A B O U T    M E'),
            ),
            Card(
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                                child: Text('Theres Nothing here without you'),
                              ),
                            );
                          }
                          final filteredPosts = posts
                              .where(
                                  (post) => post['UserEmail'] == widget.userEmail)
                              .toList(); // Use the specified userEmail

                          if (filteredPosts.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(25),
                                child: Text("No posts from this user"),
                              ),
                            );
                          }

                          return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredPosts.length,
                              itemBuilder: (context, index) {
                                final post = filteredPosts[index];

                                String message = post['PostMessage'];
                                String userEmail = post['UserEmail'];
                                Timestamp postTimeStamp = post['TimeStamp'];
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
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
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
