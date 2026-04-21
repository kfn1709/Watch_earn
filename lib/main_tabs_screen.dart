import 'package:flutter/material.dart';
import 'tabs/home_tab.dart';
import 'tabs/guide_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/profile_tab.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    GuideTab(),
    HistoryTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Color(0xFF1A1A3A), Color(0xFF0A0A1A)],
              ),
            ),
          ),
          ...List.generate(30, (index) {
            return Positioned(
              left: (index * 73) % MediaQuery.of(context).size.width,
              top: (index * 47) % MediaQuery.of(context).size.height,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFF00F0FF).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          _tabs[_currentIndex],
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF12122A).withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF00F0FF), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F0FF).withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: const Color(0xFF00F0FF),
            unselectedItemColor: const Color(0xFF6B6B8A),
            selectedFontSize: 12,
            unselectedFontSize: 11,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'HOME'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'GUIDE'),
              BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'HISTORY'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'PROFILE'),
            ],
          ),
        ),
      ),
    );
  }
}