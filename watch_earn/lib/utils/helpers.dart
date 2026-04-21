import 'dart:async';
import 'package:intl/intl.dart';

class Helpers {
  // ==================== دوال التنسيق ====================
  
  static String formatPoints(int points) {
    return NumberFormat('#,###').format(points);
  }

  static String formatAmount(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return formatDate(date);
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // ==================== دوال المستوى والنقاط ====================

  static int calculateLevel(int points) {
    return (points / 10000).floor() + 1;
  }

  static double calculateProgress(int points, int level) {
    final nextLevelPoints = level * 10000;
    return (points / nextLevelPoints).clamp(0.0, 1.0);
  }

  static double calculateNetAmount(double amount, double feePercent) {
    final fee = amount * (feePercent / 100);
    return amount - fee;
  }

  // ==================== دوال العمر ====================

  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    return now.difference(birthDate).inDays ~/ 365;
  }

  static bool isAdult(DateTime birthDate) {
    return calculateAge(birthDate) >= 18;
  }

  // ==================== دوال اللاعب ====================

  static String getPlayerId(String? userId) {
    if (userId == null) return 'WATCHER-UNKNOWN';
    return 'WATCHER-${userId.substring(0, 8).toUpperCase()}';
  }

  // ==================== دوال التحكم فـ Async ====================

  /// دالة تأخير
  static Future<void> delay(Duration duration) async {
    await Future.delayed(duration);
  }

  /// دالة إعادة المحاولة (Retry)
  static Future<T> retry<T>({
    required Future<T> Function() action,
    int maxAttempts = 3,
    Duration delayBetween = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    while (attempt < maxAttempts) {
      try {
        return await action();
      } catch (e) {
        attempt++;
        if (attempt >= maxAttempts) rethrow;
        await Future.delayed(delayBetween);
      }
    }
    throw Exception('Max retry attempts exceeded');
  }

  /// دالة مهلة زمنية (Timeout)
  static Future<T> withTimeout<T>({
    required Future<T> Function() action,
    Duration timeout = const Duration(seconds: 30),
    T? defaultValue,
  }) async {
    try {
      return await action().timeout(timeout);
    } on TimeoutException {
      if (defaultValue != null) return defaultValue;
      rethrow;
    }
  }

  /// دالة تنفيذ متعدد فـ نفس الوقت (Parallel)
  static Future<List<T>> parallel<T>({
    required List<Future<T> Function()> actions,
  }) async {
    final futures = actions.map((action) => action()).toList();
    return await Future.wait(futures);
  }
}