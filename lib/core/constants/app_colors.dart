import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accent Colors (Fintech Neo-Bank)
  static const Color primary = Color(0xFF10B981); // Emerald Green
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF34D399);
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color accentPurple = Color(0xFF8B5CF6);

  // Backgrounds & Surfaces (Dark Mode)
  static const Color backgroundDark = Color(0xFF0B0F19); // Deep Slate
  static const Color surfaceDark = Color(0xFF161F30);
  static const Color surfaceDarkLight = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);

  // Backgrounds & Surfaces (Light Mode)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightDark = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Priority Colors
  static const Color priority0 = Color(0xFF10B981); // P0: Thiết yếu (Emerald)
  static const Color priority1 = Color(0xFF3B82F6); // P1: Cao (Blue)
  static const Color priority2 = Color(0xFFF59E0B); // P2: Trung bình (Amber)
  static const Color priority3 = Color(0xFFEF4444); // P3: Thấp/Lãng phí (Rose Red)

  // Backward-compatible aliases
  static const Color priorityEssential = priority0;
  static const Color priorityHigh = priority1;
  static const Color priorityMedium = priority2;
  static const Color priorityLow = priority3;

  // Budget Warnings
  static const Color budgetSafe = Color(0xFF10B981);
  static const Color budgetWarning80 = Color(0xFFF59E0B);
  static const Color budgetWarning100 = Color(0xFFEF4444);

  static const Color categoryDefault = primary;

  // Gradients for Cards
  static const LinearGradient cardGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );

  static const LinearGradient balanceCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF0D1526),
      Color(0xFF064E3B),
    ],
  );

  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return priority0;
      case 1:
        return priority1;
      case 2:
        return priority2;
      case 3:
      default:
        return priority3;
    }
  }
}
