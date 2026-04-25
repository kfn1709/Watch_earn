import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/ad_service.dart';
import '../../core/firebase_service.dart';

class WatchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.spaceBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_fill, size: 80, color: AppColors.emerald),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                AdService.showReward(() async {
                  await FirebaseService.addGold(10); // زيادة 10 نقط
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("👑 +10 Gold Added to Your Kingdom!")),
                  );
                });
              },
              child: Text("WATCH TO EARN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
