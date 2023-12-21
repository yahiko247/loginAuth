import 'package:flutter/material.dart';

class NestedTabBar extends StatefulWidget {
  const NestedTabBar(this.outerTab, {super.key});

  final String outerTab;

  @override
  State<NestedTabBar> createState() => _NestedTabBar();
}

class _NestedTabBar extends State<NestedTabBar> with TickerProviderStateMixin {
  late final TabController _tabController;

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
            Tab(text: 'Profile'),
            Tab(text: 'Post'),
          ]),
      Expanded(
          child: TabBarView(controller: _tabController, children: <Widget>[
        Card(
          margin: const EdgeInsets.all(16.0),
          child: Center(child: Text('${widget.outerTab}: Overviewtab')),
        ),
        Card(
          margin: const EdgeInsets.all(16.0),
          child: Center(child: Text('${widget.outerTab}: Second Tab')),
        ),
      ]))
    ]);
  }
}
