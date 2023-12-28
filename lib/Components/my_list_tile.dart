import 'package:flutter/material.dart';

//not called
class MyListTile extends StatelessWidget{
  final String title;
  final Widget subTitle;
  const MyListTile({super.key,required this.title, required this.subTitle});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
      child:  ListTile(
        title: Text(title),
        subtitle: subTitle,
      ),
    );
  }
}