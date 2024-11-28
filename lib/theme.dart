import 'package:flutter/material.dart';

const Color newPrimaryColor = Color.fromARGB(255, 250, 225, 235);
const Color secondaryColor = Color(0xFF572364);
const Color accentColor = Color(0xFF8E5572);
const Color textColor = Colors.black;

ThemeData appTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: newPrimaryColor,
    secondary: secondaryColor,
  ),
  scaffoldBackgroundColor: newPrimaryColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: newPrimaryColor,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyLarge:
        TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
    bodyMedium: TextStyle(fontSize: 14, color: textColor),
    labelLarge: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    margin: const EdgeInsets.all(8),
    color: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  ),
);
