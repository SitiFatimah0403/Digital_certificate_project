import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        color: Colors.black87,
        fontSize: 16,
      ),
    ),
  );

  static Color getPrimary(BuildContext context) =>
      Theme.of(context).primaryColor;

  static Color getSecondaryBackground(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static TextStyle getBodyMedium(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;
}
