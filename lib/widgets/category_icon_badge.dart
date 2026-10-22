import 'package:flutter/material.dart';
import '../core/utils/icon_helper.dart';

class CategoryIconBadge extends StatelessWidget {
  final String iconKey;
  final String? colorHex;
  final double size;
  final double iconSize;

  const CategoryIconBadge({
    super.key,
    required this.iconKey,
    this.colorHex,
    this.size = 46,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = IconHelper.parseColor(colorHex);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: baseColor.withOpacity(isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(size * 0.35),
        border: Border.all(
          color: baseColor.withOpacity(isDark ? 0.35 : 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: IconHelper.getIconWidget(
          iconKey,
          size: iconSize,
          color: baseColor,
        ),
      ),
    );
  }
}

