import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Watch & Earn Pro';
  static const String appVersion = '3.0.0';
  static const String appEmail = 'withdraw@watchandearn.com';
  
  static const Color primaryColor = Color(0xFF00F0FF);
  static const Color secondaryColor = Color(0xFF6B00FF);
  static const Color accentColor = Color(0xFFFF00E5);
  static const Color backgroundColor = Color(0xFF0A0A1A);
  static const Color surfaceColor = Color(0xFF12122A);
  
  static const int pointsPerAd = 1000;
  static const int minWithdrawPoints = 10000;
  static const double pointsToUsdRate = 1000;
  
  static const List<Map<String, dynamic>> paymentMethods = [
    {'name': 'PayPal', 'fee': 0, 'time': '24-48h', 'icon': Icons.paypal},
    {'name': 'Bank Transfer', 'fee': 1, 'time': '3-5 days', 'icon': Icons.account_balance},
    {'name': 'Crypto (USDT)', 'fee': 0.5, 'time': '1-2h', 'icon': Icons.currency_bitcoin},
    {'name': 'Cash by Bill', 'fee': 2, 'time': '7-14 days', 'icon': Icons.attach_money},
    {'name': 'Barid Bank (CCP)', 'fee': 0, 'time': '48h', 'icon': Icons.local_post_office},
  ];
}