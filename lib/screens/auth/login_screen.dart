import 'package:flutter/material.dart';
import '../../core/constants.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBlack,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("WELCOME KING", style: TextStyle(color: AppColors.gold, fontSize: 30, fontWeight: FontWeight.bold)),
            TextField(decoration: InputDecoration(labelText: "Email", labelStyle: TextStyle(color: Colors.white70))),
            TextField(obscureText: true, decoration: InputDecoration(labelText: "Password", labelStyle: TextStyle(color: Colors.white70))),
            SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              onPressed: () {}, 
              child: Text("LOGIN", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
