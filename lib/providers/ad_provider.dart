import 'package:flutter/material.dart';

class AdProvider with ChangeNotifier {
  int _points = 0;
  int _totalWatched = 0;
  
  int get points => _points;
  int get level => (_totalWatched ~/ 50) + 1; // كل 50 فيديو كيطلع ليفل

  void addReward() {
    int pointsPerVideo = 10 + (level - 1); // كتزاد نقطة مع كل ليفل
    _points += pointsPerVideo;
    _totalWatched += 1;
    notifyListeners();
  }
}
