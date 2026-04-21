import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  runApp(const WatchAndEarnApp());
}

class WatchAndEarnApp extends StatelessWidget {
  const WatchAndEarnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WATCH & EARN | CYBER EDITION',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: NotificationService.messengerKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00F0FF),
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        fontFamily: GoogleFonts.orbitron().fontFamily,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F0FF),
          secondary: Color(0xFF6B00FF),
          tertiary: Color(0xFFFF00E5),
          surface: Color(0xFF12122A),
          background: Color(0xFF0A0A1A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Color(0xFF00F0FF),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF12122A),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF00F0FF), width: 0.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 8,
            shadowColor: const Color(0xFF00F0FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}