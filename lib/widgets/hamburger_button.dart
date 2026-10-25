import 'package:flutter/material.dart';

class HamburgerButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool light;

  const HamburgerButton({super.key, required this.onTap, this.light = false});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Mở menu',
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: light
            ? Colors.black.withValues(alpha: 0.28)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        side: BorderSide(
          color: light
              ? Colors.white.withValues(alpha: 0.22)
              : Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        padding: const EdgeInsets.all(10),
      ),
      icon: Icon(
        Icons.menu_rounded,
        size: 24,
        color: light ? Colors.white : null,
      ),
    );
  }
}
