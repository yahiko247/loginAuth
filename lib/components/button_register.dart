import 'package:flutter/material.dart';

class MyButtonTwo extends StatelessWidget {
  final Function()? onTap;
  const MyButtonTwo({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 70, 199, 177),
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Center(
          child: Text('Register',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
      ),
    );
  }
}
