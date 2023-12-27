import 'package:flutter/material.dart';

class PostButton extends StatelessWidget{
  final void Function()? onTap;
  const PostButton ({super.key,required this.onTap});

  @override
  Widget build (BuildContext context){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(left: 10),
        child: const Center(
          child: Icon(
            Icons.done,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}