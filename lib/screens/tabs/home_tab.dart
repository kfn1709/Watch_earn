import 'package:flutter/material.dart';
import '../../core/constants.dart';
class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBlack,
      body: Center(child: Text("KING'S HOME", style: TextStyle(color: AppColors.gold, fontSize: 24))),
    );
  }
}
