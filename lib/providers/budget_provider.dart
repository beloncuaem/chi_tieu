import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/services/notification_service.dart';
import '../data/models/budget.dart';
import '../data/repositories/budget_alert_repository.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/expense_repository.dart';

class BudgetValidationException implements Exception {
  final String message;
  const BudgetValidationException(this.message);
}

class BudgetState {
  final String month;
  final List<Budget> budgets;
  final Budget? totalBudget;
  final bool isOverBudget;
  final double budgetUsagePercent;
  final double totalSpent;
  final double allocatedAmount;
  final Map<int, double> categoryBudgets;
  final Map<int, double> categorySpent;
  final bool isLoading;
  final String? errorMessage;

  const BudgetState({
    required this.month,
    this.budgets = const [],
    this.totalBudget,
    this.isOverBudget = false,
    this.budgetUsagePercent = 0,
    this.totalSpent = 0,
    this.allocatedAmount = 0,
    this.categoryBudgets = const {},
    this.categorySpent = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  double get totalBudgetAmount => totalBudget?.amount ?? 0;
  double get unallocatedAmount =>
      (totalBudgetAmount - allocatedAmount).clamp(0, double.infinity).toDouble();

  BudgetState copyWith({
    String? month,
    List<Budget>? budgets,
    Budget? totalBudget,
    bool clearTotalBudget = false,
    bool? isOverBudget,
    double? budgetUsagePercent,
    double? totalSpent,
    double? allocatedAmount,
    Map<int, double>? categoryBudgets,
    Map<int, double>? categorySpent,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BudgetState(
      month: month ?? this.month,
      budgets: budgets ?? this.budgets,
      totalBudget: clearTotalBudget ? null : totalBudget ?? this.totalBudget,
      isOverBudget: isOverBudget ?? this.isOverBudget,
      budgetUsagePercent: budgetUsagePercent ?? this.budgetUsagePercent,
      totalSpent: totalSpent ?? this.totalSpent,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      categorySpent: categorySpent ?? this.categorySpent,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  BudgetNotifier()
      : super(BudgetState(month: DateFormat('yyyy-MM').format(DateTime.now()))) {
    loadBudgets(state.month);
  }

  final BudgetRepository _repository = BudgetRepository();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final BudgetAlertRepository _alertRepository = BudgetAlertRepository();

  Future<void> loadBudgets(String month, {bool checkAlerts = false}) async {
    state = state.copyWith(month: month, isLoading: true, clearError: true);
    try {
      final budgets = await _repository.getBudgetsByMonth(month);
      Budget? totalBudget;
      final categoryBudgets = <int, double>{};
      for (final budget in budgets) {
        if (budget.categoryId == null) {
          totalBudget = budget;
        } else {
          categoryBudgets[budget.categoryId!] = budget.amount;
        }
      }

      final parts = month.split('-');
      final year = int.parse(parts[0]);
      final monthNumber = int.parse(parts[1]);
      final startOfMonth = DateTime(year, monthNumber, 1);
      final endOfMonth = DateTime(year, monthNumber + 1, 0, 23, 59, 59, 999);
      final expenses = await _expenseRepository.getExpenses(
        from: startOfMonth,
        to: endOfMonth,
      );
      final totalSpent = expenses.fold<double>(0, (sum, item) => sum + item.amount);
      final categorySpent = <int, double>{};
      for (final expense in expenses) {
        categorySpent.update(
          expense.categoryId,
          (amount) => amount + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }

      final usagePercent = totalBudget == null || totalBudget.amount <= 0
          ? 0.0
          : totalSpent / totalBudget.amount;
      state = state.copyWith(
        month: month,
        budgets: budgets,
        totalBudget: totalBudget,
        clearTotalBudget: totalBudget == null,
        categoryBudgets: categoryBudgets,
        categorySpent: categorySpent,
        totalSpent: totalSpent,
        allocatedAmount: categoryBudgets.values.fold(0, (sum, amount) => sum + amount),
        budgetUsagePercent: usagePercent,
        isOverBudget: usagePercent >= 1,
        isLoading: false,
      );

      if (checkAlerts && month == DateFormat('yyyy-MM').format(DateTime.now())) {
        await _sendNewAlerts();
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải ngân sách.',
      );
    }
  }

  Future<void> _sendNewAlerts() async {
    final usagePercent = state.budgetUsagePercent;
    if (state.totalBudgetAmount <= 0) return;
    for (final threshold in [80, 90, 100]) {
      if (usagePercent * 100 < threshold ||
          await _alertRepository.hasSent(state.month, threshold)) {
        continue;
      }
      await NotificationService.instance.showBudgetAlert(
        threshold: threshold,
        monthLabel: DateFormat('MM/yyyy').format(DateTime.parse('${state.month}-01')),
      );
      await _alertRepository.markSent(state.month, threshold);
    }
  }

  Future<void> setTotalBudget({required String month, required double amount}) async {
    final allocated = await _repository.getAllocatedAmount(month);
    if (amount < allocated) {
      throw const BudgetValidationException(
        'Ngân sách tổng không thể thấp hơn phần đã phân bổ. Hãy điều chỉnh các danh mục trước.',
      );
    }
    final existing = await _repository.getBudgetForMonth(month);
    if (amount <= 0) {
      if (existing != null) await _repository.deleteBudget(existing.id!);
    } else {
      await _repository.setBudget(Budget(month: month, amount: amount));
    }
    await loadBudgets(month, checkAlerts: true);
  }

  Future<void> setCategoryBudgets({
    required String month,
    required Map<int, double> categoryBudgets,
  }) async {
    final totalBudget = await _repository.getBudgetForMonth(month);
    if (totalBudget == null || totalBudget.amount <= 0) {
      throw const BudgetValidationException(
        'Hãy nhập ngân sách tổng trước khi phân bổ theo danh mục.',
      );
    }
    final allocation = categoryBudgets.values.fold<double>(0, (sum, value) => sum + value);
    if (allocation > totalBudget.amount) {
      throw const BudgetValidationException(
        'Tổng phân bổ không được vượt ngân sách tổng.',
      );
    }

    final existing = await _repository.getBudgetsByMonth(month);
    for (final budget in existing.where((item) => item.categoryId != null)) {
      if (!categoryBudgets.containsKey(budget.categoryId) ||
          categoryBudgets[budget.categoryId]! <= 0) {
        await _repository.deleteBudget(budget.id!);
      }
    }
    for (final entry in categoryBudgets.entries) {
      if (entry.value > 0) {
        await _repository.setBudget(
          Budget(month: month, categoryId: entry.key, amount: entry.value),
        );
      }
    }
    await loadBudgets(month, checkAlerts: true);
  }

  Future<void> deleteBudget(int id) async {
    await _repository.deleteBudget(id);
    await loadBudgets(state.month);
  }

  Future<void> refreshCurrentMonthAfterExpenseChange() async {
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    await loadBudgets(currentMonth, checkAlerts: true);
  }
}

final budgetProvider =
    StateNotifierProvider<BudgetNotifier, BudgetState>((ref) => BudgetNotifier());
