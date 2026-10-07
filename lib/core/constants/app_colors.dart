import 'package:flutter/material.dart';

class AppColors {
  static const Color priorityEssential = Colors.green;
  static const Color priorityHigh = Colors.blue;
  static const Color priorityMedium = Colors.orange;
  static const Color priorityLow = Colors.red;

  static const Color priority0 = priorityEssential;
  static const Color priority1 = priorityHigh;
  static const Color priority2 = priorityMedium;
  static const Color priority3 = priorityLow;

  static const Color budgetWarning80 = Colors.amber;
  static const Color budgetWarning100 = Colors.red;

  static const Color categoryDefault = Colors.teal;

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
