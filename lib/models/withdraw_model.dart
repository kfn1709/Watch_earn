class WithdrawalModel {
  final String amount;
  final int points;
  final String status;
  final DateTime requestDate;
  final String paymentMethod;

  WithdrawalModel({
    required this.amount,
    required this.points,
    required this.status,
    required this.requestDate,
    required this.paymentMethod,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      amount: json['amount'],
      points: json['points'],
      status: json['status'],
      requestDate: json['requestDate'].toDate(),
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'points': points,
      'status': status,
      'requestDate': requestDate,
      'paymentMethod': paymentMethod,
    };
  }
}