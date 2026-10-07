import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';

class AmountDisplay extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final Color? color;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      CurrencyFormatter.format(amount),
      style: style?.copyWith(color: color) ?? TextStyle(color: color),
    );
  }
}
