import 'package:flutter/material.dart';
import '../../core/constants.dart';
class WithdrawTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBlack,
      body: Center(child: Text("CASH OUT", style: TextStyle(color: AppColors.ruby, fontSize: 24))),
    );
  }
}
