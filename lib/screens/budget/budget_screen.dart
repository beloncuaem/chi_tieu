import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../data/models/category.dart';
import '../../core/utils/currency_formatter.dart';

import 'package:intl/intl.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  bool _isTotalBudget = true;
  final _totalBudgetController = TextEditingController();
  final Map<int, TextEditingController> _categoryControllers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  void _loadData() {
    final budgetState = ref.read(budgetProvider);
    final categoryState = ref.read(categoryProvider);

    if (budgetState.totalBudget != null &&
        budgetState.totalBudget!.amount > 0) {
      _totalBudgetController.text = budgetState.totalBudget!.amount
          .toInt()
          .toString();
    }

    for (var cat in categoryState.categories) {
      if (cat.id != null) {
        final amount = budgetState.categoryBudgets[cat.id];
        _categoryControllers[cat.id!] = TextEditingController(
          text: amount != null && amount > 0 ? amount.toInt().toString() : '',
        );
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _totalBudgetController.dispose();
    for (var controller in _categoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveBudget() {
    if (_isTotalBudget) {
      final total =
          double.tryParse(_totalBudgetController.text.replaceAll(',', '')) ??
          0.0;
      ref.read(budgetProvider.notifier).setTotalBudget(total);
    } else {
      final Map<int, double> catBudgets = {};
      _categoryControllers.forEach((id, controller) {
        final val = double.tryParse(controller.text.replaceAll(',', ''));
        if (val != null && val > 0) {
          catBudgets[id] = val;
        }
      });
      ref.read(budgetProvider.notifier).setCategoryBudgets(catBudgets);
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã lưu ngân sách!')));
  }

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetProvider);
    final categoryState = ref.watch(categoryProvider);
    final currentMonth = DateFormat('MM/yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text('Ngân sách tháng $currentMonth')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Tổng')),
                ButtonSegment(value: false, label: Text('Chia theo danh mục')),
              ],
              selected: {_isTotalBudget},
              onSelectionChanged: (set) {
                setState(() => _isTotalBudget = set.first);
              },
            ),
          ),
          Expanded(
            child: _isTotalBudget
                ? _buildTotalBudgetView(budgetState)
                : _buildCategoryBudgetView(
                    categoryState.categories,
                    budgetState,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBudget,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Lưu ngân sách',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBudgetView(BudgetState budgetState) {
    final spent = budgetState.totalSpent;
    final budget = budgetState.totalBudget?.amount ?? 0.0;
    final percent = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    Color progressColor = Colors.teal;
    if (percent >= 1.0) {
      progressColor = Colors.red;
    } else if (percent >= 0.8) {
      progressColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _totalBudgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Ngân sách tổng (VND)',
              hintText: '5000000',
              suffixText: '₫',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          if (budget > 0) ...[
            LinearProgressIndicator(
              value: percent,
              color: progressColor,
              backgroundColor: Colors.grey.shade200,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Đã tiêu: ${CurrencyFormatter.format(spent)}'),
                Text('${(percent * 100).toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Còn lại: ${CurrencyFormatter.format(budget - spent)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: (budget - spent) < 0
                    ? Colors.red
                    : Colors.green.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetView(
    List<Category> categories,
    BudgetState budgetState,
  ) {
    if (categories.isEmpty) {
      return const Center(child: Text('Chưa có danh mục nào'));
    }

    return ListView.builder(
      itemCount: categories.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final cat = categories[index];
        if (cat.id == null) return const SizedBox.shrink();

        if (!_categoryControllers.containsKey(cat.id!)) {
          final amt = budgetState.categoryBudgets[cat.id!];
          _categoryControllers[cat.id!] = TextEditingController(
            text: amt != null && amt > 0 ? amt.toInt().toString() : '',
          );
        }

        final budget = budgetState.categoryBudgets[cat.id!] ?? 0.0;
        final spent = budgetState.categorySpent[cat.id!] ?? 0.0;
        final percent = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

        Color progressColor = Colors.teal;
        if (percent >= 1.0) {
          progressColor = Colors.red;
        } else if (percent >= 0.8) {
          progressColor = Colors.orange;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cat.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _categoryControllers[cat.id!],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ngân sách',
                    suffixText: '₫',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                if (budget > 0) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: percent,
                    color: progressColor,
                    backgroundColor: Colors.grey.shade200,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đã tiêu: ${CurrencyFormatter.format(spent)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${(percent * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
