import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      background: Colors.grey.shade100,
      primary: Colors.grey.shade200,
      secondary: Colors.grey.shade600,
      tertiary: Colors.black,
      onPrimary: Colors.grey.shade100,
    ));
ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      background: Colors.grey.shade900,
      primary: Colors.grey.shade900,
      secondary: Colors.grey.shade500,
      tertiary: Colors.white,
      onPrimary: Colors.grey.shade800,
    ));
