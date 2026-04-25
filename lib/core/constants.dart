import 'package:flutter/material.dart';
class AppColors {
  static const Color gold = Color(0xFFFFD700);
  static const Color emerald = Color(0xFF00FF8C);
  static const Color ruby = Color(0xFFFF0033);
  static const Color spaceBlack = Color(0xFF050505);
  static LinearGradient holoGradient = LinearGradient(
    colors: [gold, emerald, ruby],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
}
