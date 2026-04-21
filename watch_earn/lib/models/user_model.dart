class UserModel {
  final String? playerId;
  final String? email;
  final String? name;
  final String? photoUrl;
  final String? gender;
  final String? birthDate;
  final int points;
  final int level;
  final int xp;
  final DateTime? createdAt;
  final bool isVerified;
  final bool isWithdrawVerified;
  final String? fullName;
  final String? phone;
  final String? address;
  final String? paymentMethod;
  final String? paymentDetail;

  UserModel({
    this.playerId,
    this.email,
    this.name,
    this.photoUrl,
    this.gender,
    this.birthDate,
    required this.points,
    required this.level,
    required this.xp,
    this.createdAt,
    required this.isVerified,
    required this.isWithdrawVerified,
    this.fullName,
    this.phone,
    this.address,
    this.paymentMethod,
    this.paymentDetail,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      playerId: json['playerId'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      gender: json['gender'],
      birthDate: json['birthDate'],
      points: json['points'] ?? 0,
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      createdAt: json['createdAt']?.toDate(),
      isVerified: json['isVerified'] ?? false,
      isWithdrawVerified: json['isWithdrawVerified'] ?? false,
      fullName: json['fullName'],
      phone: json['phone'],
      address: json['address'],
      paymentMethod: json['paymentMethod'],
      paymentDetail: json['paymentDetail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'gender': gender,
      'birthDate': birthDate,
      'points': points,
      'level': level,
      'xp': xp,
      'createdAt': createdAt,
      'isVerified': isVerified,
      'isWithdrawVerified': isWithdrawVerified,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'paymentMethod': paymentMethod,
      'paymentDetail': paymentDetail,
    };
  }

  UserModel copyWith({
    int? points,
    int? level,
    int? xp,
    bool? isWithdrawVerified,
    String? fullName,
    String? phone,
    String? address,
    String? paymentMethod,
    String? paymentDetail,
  }) {
    return UserModel(
      playerId: playerId,
      email: email,
      name: name,
      photoUrl: photoUrl,
      gender: gender,
      birthDate: birthDate,
      points: points ?? this.points,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      createdAt: createdAt,
      isVerified: isVerified,
      isWithdrawVerified: isWithdrawVerified ?? this.isWithdrawVerified,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDetail: paymentDetail ?? this.paymentDetail,
    );
  }
}