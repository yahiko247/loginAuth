import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    background: Colors.grey,
    primary: Colors.white24,
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor:Colors.grey[800],
    displayColor: Colors.black,
  )

);