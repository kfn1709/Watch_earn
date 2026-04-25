import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'tabs/home_tab.dart';
import 'tabs/watch_tab.dart';
import 'tabs/withdraw_tab.dart';
import 'tabs/profile_tab.dart';

class MainShell extends StatefulWidget {
  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;
  final tabs = [HomeTab(), WatchTab(), WithdrawTab(), ProfileTab()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_idx],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.spaceBlack,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: Colors.white30,
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), activeIcon: Icon(Icons.play_circle), label: "Watch"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet_outlined), activeIcon: Icon(Icons.wallet), label: "Earn"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "King"),
        ],
      ),
    );
  }
}
