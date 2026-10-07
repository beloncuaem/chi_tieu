import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import '../../data/models/priority_level.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/priority_provider.dart';
import '../camera/expense_form_sheet.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  _ExpenseFilter _filter = const _ExpenseFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _searchController.clear();
    setState(() => _filter = const _ExpenseFilter());
    await ref.read(expenseProvider.notifier).refreshDashboard();
    await ref.read(budgetProvider.notifier).refreshCurrentMonthAfterExpenseChange();
  }

  Future<void> _applySearch() async {
    _filter = _filter.copyWith(search: _searchController.text.trim());
    setState(() {});
    await _loadFilteredExpenses();
  }

  Future<void> _loadFilteredExpenses() {
    final range = _filter.dateRange;
    return ref.read(expenseProvider.notifier).loadExpenses(
          from: range?.start,
          to: range == null
              ? null
              : DateTime(
                  range.end.year,
                  range.end.month,
                  range.end.day,
                  23,
                  59,
                  59,
                  999,
                ),
          search: _filter.search,
          categoryId: _filter.categoryId,
          priority: _filter.priorityId,
          minAmount: _filter.minAmount,
          maxAmount: _filter.maxAmount,
        );
  }

  Future<void> _showFilters() async {
    final selected = await showModalBottomSheet<_ExpenseFilter>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(
        initial: _filter,
        categories: ref.read(categoryProvider).categories,
        priorities: ref.read(priorityProvider).levels,
      ),
    );
    if (selected == null) return;
    _searchController.text = selected.search;
    setState(() => _filter = selected);
    await _loadFilteredExpenses();
  }

  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.file(File(imagePath), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  void _showEditSheet(Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseFormSheet(expense: expense),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    final categories = ref.watch(categoryProvider).categories;
    final priorities = ref.watch(priorityProvider).levels;
    final budgetState = ref.watch(budgetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan'),
        actions: [
          IconButton(
            tooltip: 'Cài đặt',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryCards(
              today: expenseState.todayTotal,
              week: expenseState.weekTotal,
              month: expenseState.monthTotal,
            ),
            const SizedBox(height: 16),
            _BudgetProgressCard(budgetState: budgetState),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _applySearch(),
                    decoration: InputDecoration(
                      hintText: 'Tìm ghi chú, danh mục...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Tìm kiếm',
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _applySearch,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Lọc giao dịch',
                  onPressed: _showFilters,
                  icon: Badge(
                    isLabelVisible: _filter.isActive,
                    label: const Text(''),
                    child: const Icon(Icons.tune),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _filter.isActive ? 'Kết quả lọc' : 'Giao dịch gần đây',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (expenseState.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                expenseState.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 8),
            if (expenseState.isLoading && expenseState.expenses.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (expenseState.expenses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    'Chưa có khoản chi phù hợp.\nHãy chụp hoặc chọn một ảnh để bắt đầu.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ..._buildGroupedExpenses(
                context,
                expenseState.expenses,
                categories,
                priorities,
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGroupedExpenses(
    BuildContext context,
    List<Expense> expenses,
    List<Category> categories,
    List<PriorityLevel> priorities,
  ) {
    final categoryMap = {for (final category in categories) category.id: category};
    final priorityMap = {for (final priority in priorities) priority.id: priority};
    final groups = <DateTime, List<Expense>>{};
    for (final expense in expenses) {
      final date = DateUtils.dateOnly(expense.createdAt);
      groups.putIfAbsent(date, () => []).add(expense);
    }

    final result = <Widget>[];
    for (final entry in groups.entries) {
      result.add(Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(
          DateFormatter.formatDate(entry.key),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ));
      for (final expense in entry.value) {
        result.add(
          _ExpenseTile(
            expense: expense,
            category: categoryMap[expense.categoryId],
            priority: priorityMap[expense.priority],
            onTap: () => _showEditSheet(expense),
            onImageTap: expense.imagePath == null
                ? null
                : () => _showImageDialog(expense.imagePath!),
            onMoveToTrash: () async {
              if (expense.id == null) return;
              await ref.read(expenseProvider.notifier).moveToTrash(expense.id!);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã chuyển khoản chi vào thùng rác.'),
                  action: SnackBarAction(
                    label: 'Hoàn tác',
                    onPressed: () => ref
                        .read(expenseProvider.notifier)
                        .restoreExpense(expense.id!),
                  ),
                ),
              );
            },
          ),
        );
      }
    }
    return result;
  }
}

class _SummaryCards extends StatelessWidget {
  final double today;
  final double week;
  final double month;

  const _SummaryCards({
    required this.today,
    required this.week,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Hôm nay', today, Icons.today_outlined),
      ('Tuần này', week, Icons.date_range_outlined),
      ('Tháng này', month, Icons.calendar_month_outlined),
    ];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: items
              .map(
                (item) => Expanded(
                  child: Semantics(
                    label: '${item.$1}: ${CurrencyFormatter.format(item.$2)}',
                    child: Column(
                      children: [
                        Icon(item.$3),
                        const SizedBox(height: 4),
                        Text(item.$1, style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(item.$2),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _BudgetProgressCard extends StatelessWidget {
  final BudgetState budgetState;
  const _BudgetProgressCard({required this.budgetState});

  @override
  Widget build(BuildContext context) {
    final total = budgetState.totalBudgetAmount;
    if (total <= 0) return const SizedBox.shrink();
    final progress = budgetState.budgetUsagePercent.clamp(0, 1).toDouble();
    final isOver = budgetState.budgetUsagePercent >= 1;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined),
                const SizedBox(width: 8),
                Text('Ngân sách tháng', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text('${(budgetState.budgetUsagePercent * 100).toStringAsFixed(0)}%'),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
              color: isOver ? Colors.red : null,
            ),
            const SizedBox(height: 8),
            Text(
              '${CurrencyFormatter.format(budgetState.totalSpent)} / ${CurrencyFormatter.format(total)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final Category? category;
  final PriorityLevel? priority;
  final VoidCallback onTap;
  final VoidCallback? onImageTap;
  final Future<void> Function() onMoveToTrash;

  const _ExpenseTile({
    required this.expense,
    required this.category,
    required this.priority,
    required this.onTap,
    required this.onImageTap,
    required this.onMoveToTrash,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('expense-${expense.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onMoveToTrash(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onError),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.all(10),
          leading: GestureDetector(
            onTap: onImageTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 60,
                child: expense.imagePath != null && File(expense.imagePath!).existsSync()
                    ? Image.file(File(expense.imagePath!), fit: BoxFit.cover)
                    : ColoredBox(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.receipt_long_outlined),
                      ),
              ),
            ),
          ),
          title: Text(expense.caption.isEmpty ? 'Không có ghi chú' : expense.caption),
          subtitle: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                visualDensity: VisualDensity.compact,
                avatar: Text(category?.icon ?? '🏷️'),
                label: Text(category?.name ?? 'Khác'),
              ),
              if (priority != null)
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(priority!.name),
                  side: BorderSide(color: priority!.color),
                ),
              Text(DateFormatter.formatTime(expense.createdAt)),
            ],
          ),
          trailing: Text(
            CurrencyFormatter.format(expense.amount),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseFilter {
  final String search;
  final DateTimeRange? dateRange;
  final int? categoryId;
  final int? priorityId;
  final double? minAmount;
  final double? maxAmount;

  const _ExpenseFilter({
    this.search = '',
    this.dateRange,
    this.categoryId,
    this.priorityId,
    this.minAmount,
    this.maxAmount,
  });

  bool get isActive =>
      search.isNotEmpty ||
      dateRange != null ||
      categoryId != null ||
      priorityId != null ||
      minAmount != null ||
      maxAmount != null;

  _ExpenseFilter copyWith({
    String? search,
    DateTimeRange? dateRange,
    int? categoryId,
    int? priorityId,
    double? minAmount,
    double? maxAmount,
    bool clearDateRange = false,
    bool clearCategory = false,
    bool clearPriority = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) =>
      _ExpenseFilter(
        search: search ?? this.search,
        dateRange: clearDateRange ? null : dateRange ?? this.dateRange,
        categoryId: clearCategory ? null : categoryId ?? this.categoryId,
        priorityId: clearPriority ? null : priorityId ?? this.priorityId,
        minAmount: clearMinAmount ? null : minAmount ?? this.minAmount,
        maxAmount: clearMaxAmount ? null : maxAmount ?? this.maxAmount,
      );
}

class _FilterSheet extends StatefulWidget {
  final _ExpenseFilter initial;
  final List<Category> categories;
  final List<PriorityLevel> priorities;

  const _FilterSheet({
    required this.initial,
    required this.categories,
    required this.priorities,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late DateTimeRange? _dateRange;
  late int? _categoryId;
  late int? _priorityId;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _dateRange = widget.initial.dateRange;
    _categoryId = widget.initial.categoryId;
    _priorityId = widget.initial.priorityId;
    _minController = TextEditingController(text: widget.initial.minAmount?.toInt().toString() ?? '');
    _maxController = TextEditingController(text: widget.initial.maxAmount?.toInt().toString() ?? '');
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _dateRange,
    );
    if (result != null) setState(() => _dateRange = result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lọc giao dịch', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range_outlined),
                  label: Text(
                    _dateRange == null
                        ? 'Chọn khoảng thời gian'
                        : '${DateFormatter.formatDate(_dateRange!.start)} – ${DateFormatter.formatDate(_dateRange!.end)}',
                  ),
                ),
                if (_dateRange != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _dateRange = null),
                    icon: const Icon(Icons.clear),
                    label: const Text('Bỏ lọc thời gian'),
                  ),
                const SizedBox(height: 12),
                Text('Danh mục', style: Theme.of(context).textTheme.titleSmall),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Tất cả'),
                      selected: _categoryId == null,
                      onSelected: (_) => setState(() => _categoryId = null),
                    ),
                    ...widget.categories.map(
                      (category) => ChoiceChip(
                        label: Text('${category.icon} ${category.name}'),
                        selected: _categoryId == category.id,
                        onSelected: (selected) =>
                            setState(() => _categoryId = selected ? category.id : null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Mức độ cần thiết', style: Theme.of(context).textTheme.titleSmall),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Tất cả'),
                      selected: _priorityId == null,
                      onSelected: (_) => setState(() => _priorityId = null),
                    ),
                    ...widget.priorities.map(
                      (priority) => ChoiceChip(
                        label: Text(priority.name),
                        selected: _priorityId == priority.id,
                        onSelected: (selected) =>
                            setState(() => _priorityId = selected ? priority.id : null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Từ số tiền',
                          suffixText: '₫',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _maxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Đến số tiền',
                          suffixText: '₫',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, const _ExpenseFilter()),
                      child: const Text('Xóa bộ lọc'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () => Navigator.pop(
                        context,
                        _ExpenseFilter(
                          search: widget.initial.search,
                          dateRange: _dateRange,
                          categoryId: _categoryId,
                          priorityId: _priorityId,
                          minAmount: double.tryParse(_minController.text),
                          maxAmount: double.tryParse(_maxController.text),
                        ),
                      ),
                      child: const Text('Áp dụng'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
