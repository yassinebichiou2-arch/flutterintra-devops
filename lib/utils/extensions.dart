import 'package:flutter/material.dart';

/// String extensions
extension StringExt on String {
  String get initials {
    final parts = trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isValidEmail {
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$');
    return regex.hasMatch(trim());
  }
}

/// DateTime extensions
extension DateTimeExt on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String get smartFormat {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return '$day/${month.toString().padLeft(2, '0')}/$year';
  }
}

/// BuildContext extensions
extension ContextExt on BuildContext {
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
