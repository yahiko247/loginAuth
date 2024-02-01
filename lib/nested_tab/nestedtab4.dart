import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/components/post/post.dart';
import 'package:practice_login/database/firestore.dart';
import '../pages/reviews_page.dart';

class NestedTabBar4 extends StatefulWidget {
  String userEmail;
  NestedTabBar4(this.outerTab, {super.key, required this.userEmail});
  final currentUser = FirebaseAuth.instance.currentUser!;

  final String outerTab;

  @override
  State<NestedTabBar4> createState() => _NestedTabBar4();
}

class _NestedTabBar4 extends State<NestedTabBar4>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();
  final FirestoreDatabase _firestoreDatabase = FirestoreDatabase();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            Tab(text: 'P O S T'),
            Tab(text: 'P R O F I L E'),
            Tab(text: 'R E V I E W S',)
          ]),
      Expanded(
          child: TabBarView(controller: _tabController, children: <Widget>[
            SingleChildScrollView(
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
            const Card(
              margin: EdgeInsets.all(16.0),
              child: Text('A B O U T    M E'),
            ),
            Card(
              child: ReviewsPage(freelancerID:widget.userEmail,),
            )
          ]))
    ]);
  }
}
