import 'package:flutter/material.dart';
import 'package:practice_login/components/tryuserposts.dart';
import 'package:practice_login/database/firestore.dart';
import 'package:file_picker/file_picker.dart';
class NestedTabBar extends StatefulWidget {
  const NestedTabBar(this.outerTab, {super.key});


  final String outerTab;

  @override
  State<NestedTabBar> createState() => _NestedTabBar();
}

class _NestedTabBar extends State<NestedTabBar> with TickerProviderStateMixin {
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
            const Card(
              margin: EdgeInsets.all(16.0),
              child: Text('A B O U T    M E'),
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
