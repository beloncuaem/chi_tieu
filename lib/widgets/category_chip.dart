import 'package:flutter/material.dart';

import '../core/utils/icon_helper.dart';
import '../data/models/category.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: IconHelper.getIconWidget(category.icon, size: 16),
      label: Text(category.name),
      backgroundColor: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      onPressed: onTap,
    );
  }
}
