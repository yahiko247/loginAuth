import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice_login/components/tryuserposts.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:practice_login/pages/reviews_page.dart';
class NestedTabBar3 extends StatefulWidget {
  const NestedTabBar3(this.outerTab, {super.key});


  final String outerTab;

  @override
  State<NestedTabBar3> createState() => _NestedTabBar();
}

class _NestedTabBar extends State<NestedTabBar3> with TickerProviderStateMixin {
  late final TabController _tabController;
  final FirestoreDatabase database = FirestoreDatabase();
  final TextEditingController newPostController = TextEditingController();
  final FirestoreDatabase _firestoreDatabase = FirestoreDatabase();
  List<PlatformFile>? _pickedFiles;

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

  Widget freelancerReviewPage(){
    return const ReviewsPage();
  }
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      TabBar.secondary(
          labelColor: Colors.black,
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'P R O F I L E'),
            Tab(text: 'P O S T'),
          ]
      ),
      Expanded(
          child: TabBarView(controller: _tabController, children: <Widget>[
            Card(
              margin: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('A B O U T    M E'),

                  TextButton(
                      onPressed:(){
                        freelancerReviewPage();
                     },
                      child: const Text("Freelancer's Review")
                  ),
                ],
              ),
            ),
            Card(
              child: ForUserPosts(),
            ),
          ]
          )
      )
    ]
    );
  }
}
