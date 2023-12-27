import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      background: Colors.white,
      primary: Colors.white70,
    ),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor:Colors.grey[300],
      displayColor: Colors.white,
    )

);