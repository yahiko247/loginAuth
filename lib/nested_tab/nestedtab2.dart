import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/components/post/post.dart';

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
    _tabController = TabController(length: 1, vsync: this);
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

                          final filteredPosts = posts
                              .where(
                                  (post) => post['user_email'] == widget.userEmail)
                              .toList();

                          if (snapshot.data == null || posts.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(25),
                                child: Text("No posts... Post Something"),
                              ),
                            );
                          }

                          return Container(
                              padding: const EdgeInsets.only(top: 5),
                              color: const Color.fromARGB(15, 0, 0, 0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: filteredPosts.length,
                                  itemBuilder: (context, index) {
                                    return Post(postData: filteredPosts[index]);
                                  })
                          );
                        })
                  ],
                ),
              ),
            ),
          ]))
    ]);
  }
}
