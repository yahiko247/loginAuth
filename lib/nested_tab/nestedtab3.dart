import 'package:flutter/material.dart';
import 'package:practice_login/components/tryuserposts.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:practice_login/pages/reviews_page.dart';
class NestedTabBar3 extends StatefulWidget {
  final String freelancerID;
  const NestedTabBar3(this.outerTab, {super.key,required this.freelancerID});


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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget freelancerReviewPage(){
    return ReviewsPage(freelancerID: widget.freelancerID,);
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
            Tab(text: 'R E V I E W S',)
          ]
      ),
      Expanded(
          child: TabBarView(controller: _tabController, children: <Widget>[
            const Card(
              margin: EdgeInsets.all(16.0),
              child: Text('A B O U T    M E'),
            ),
            Card(
              child: ForUserPosts(),
            ),
            Card(
              child: ReviewsPage(freelancerID: widget.freelancerID,),
            )
          ]
          )
      )
    ]
    );
  }
}
