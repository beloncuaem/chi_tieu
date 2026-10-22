import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PriorityBadge extends StatelessWidget {
  final int priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (priority) {
      case 0:
        text = 'Thiết yếu';
        color = AppColors.priority0;
        break;
      case 1:
        text = 'Rất cần';
        color = AppColors.priority1;
        break;
      case 2:
        text = 'Cần vừa';
        color = AppColors.priority2;
        break;
      case 3:
      default:
        text = 'Chưa cần';
        color = AppColors.priority3;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
