import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/expense.dart';
import '../../data/models/category.dart';
import '../../core/utils/currency_formatter.dart';
import 'priority_badge.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final Category category;

  const ExpenseCard({super.key, required this.expense, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildThumbnail(),
        title: Text(expense.caption),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${category.icon} ${category.name}'),
                const SizedBox(width: 8),
                PriorityBadge(priority: expense.priority),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${expense.dateTime.hour.toString().padLeft(2, '0')}:${expense.dateTime.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Text(
          CurrencyFormatter.format(expense.amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (expense.imagePath != null && expense.imagePath!.isNotEmpty) {
      final file = File(expense.imagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(file, width: 50, height: 50, fit: BoxFit.cover),
        );
      }
    }
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.receipt, color: Colors.grey),
    );
  }
}
