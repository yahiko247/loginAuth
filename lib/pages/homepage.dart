import 'package:flutter/material.dart';
import 'package:practice_login/components/tryforposts.dart';
import 'package:practice_login/components/appbar.dart';
class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2();
}

// github token Juario
//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
class _HomePage2 extends State<HomePage2> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const AppBarComponent(),
      body: const ForPosts(),
    );
  }
}
