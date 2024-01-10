import 'package:flutter/material.dart';

class OnboardButton extends StatelessWidget {
  final Function()? onTap;
  const OnboardButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 124, 210, 231),
          ),
          child: const Center(
            child: Text(
              'Get Started!',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ));
  }
}
