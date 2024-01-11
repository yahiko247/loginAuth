import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Listed Book'),
        backgroundColor: const Color.fromARGB(255, 124, 210, 231),
      ),
    );
  }
}
