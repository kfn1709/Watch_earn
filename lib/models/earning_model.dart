class EarningModel {
  final int points;
  final DateTime timestamp;

  EarningModel({
    required this.points,
    required this.timestamp,
  });

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      points: json['points'],
      timestamp: json['timestamp'].toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'timestamp': timestamp,
    };
  }
}