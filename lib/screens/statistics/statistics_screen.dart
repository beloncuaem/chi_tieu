import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/statistics_provider.dart';
import '../../providers/category_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/constants/app_colors.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  String _selectedRange = 'Tháng này';
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  void _loadData() {
    ref.read(statisticsProvider.notifier).loadStatistics(_startDate, _endDate);
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _selectedRange = 'Tùy chọn';
        _startDate = picked.start;
        _endDate = DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
          999,
        );
      });
      _loadData();
    }
  }

  void _setRange(String range) {
    final now = DateTime.now();
    setState(() {
      _selectedRange = range;
      if (range == 'Hôm nay') {
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
      } else if (range == 'Tuần này') {
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = now;
      } else if (range == 'Tháng này') {
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
      } else if (range == 'Năm nay') {
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
      }
    });
    if (range != 'Tùy chọn') _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(statisticsProvider);
    final categoryState = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children:
                  [
                    'Hôm nay',
                    'Tuần này',
                    'Tháng này',
                    'Năm nay',
                    'Tùy chọn',
                  ].map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(r),
                        selected: _selectedRange == r,
                        onSelected: (_) {
                          if (r == 'Tùy chọn') {
                            _selectCustomDateRange();
                          } else {
                            _setRange(r);
                          }
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
          Expanded(
            child: statsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : statsState.totalSpending == 0
                ? const Center(
                    child: Text(
                      'Không có dữ liệu trong khoảng thời gian này',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Tổng chi tiêu',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(statsState.totalSpending),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Theo danh mục',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: statsState.spendingByCategory.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((e) {
                                    final index = e.key;
                                    final entry = e.value;
                                    final colors = [
                                      Colors.blue,
                                      Colors.orange,
                                      Colors.green,
                                      Colors.purple,
                                      Colors.red,
                                      Colors.teal,
                                    ];
                                    final percent =
                                        (entry.value /
                                        statsState.totalSpending *
                                        100);
                                    return PieChartSectionData(
                                      color: colors[index % colors.length],
                                      value: entry.value,
                                      title: '${percent.toStringAsFixed(1)}%',
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...statsState.spendingByCategory.entries
                            .toList()
                            .asMap()
                            .entries
                            .map((e) {
                              final index = e.key;
                              final entry = e.value;
                              final colors = [
                                Colors.blue,
                                Colors.orange,
                                Colors.green,
                                Colors.purple,
                                Colors.red,
                                Colors.teal,
                              ];
                              final percent =
                                  (entry.value /
                                  statsState.totalSpending *
                                  100);
                              final cat = categoryState.categories
                                  .cast()
                                  .firstWhere(
                                    (c) => c.id == entry.key,
                                    orElse: () => null,
                                  );
                              final catName = cat != null
                                  ? '${cat.icon} ${cat.name}'
                                  : 'Danh mục #${entry.key}';

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: colors[index % colors.length],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(catName)),
                                    Text(
                                      '${CurrencyFormatter.format(entry.value)} (${percent.toStringAsFixed(1)}%)',
                                    ),
                                  ],
                                ),
                              );
                            }),
                        const SizedBox(height: 32),
                        Text(
                          'Theo mức độ cần thiết',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (statsState.totalSpending > 0)
                                  ? statsState.totalSpending
                                  : 100,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                          final labels = [
                                            'Thiết yếu',
                                            'Rất cần',
                                            'Cần vừa',
                                            'Chưa cần',
                                          ];
                                          final val = value.toInt();
                                          if (val < 0 || val >= labels.length) {
                                            return const SizedBox.shrink();
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: Text(
                                              labels[val],
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        },
                                  ),
                                ),
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                _buildBar(
                                  0,
                                  statsState.spendingByPriority[0] ?? 0,
                                  AppColors.priority0,
                                ),
                                _buildBar(
                                  1,
                                  statsState.spendingByPriority[1] ?? 0,
                                  AppColors.priority1,
                                ),
                                _buildBar(
                                  2,
                                  statsState.spendingByPriority[2] ?? 0,
                                  AppColors.priority2,
                                ),
                                _buildBar(
                                  3,
                                  statsState.spendingByPriority[3] ?? 0,
                                  AppColors.priority3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Gợi ý & Nhận xét',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (statsState.insights.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('Chưa đủ dữ liệu để tạo nhận xét'),
                            ),
                          )
                        else
                          ...statsState.insights.map(
                            (insight) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.lightbulb,
                                  color: Colors.amber,
                                ),
                                title: Text(insight),
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBar(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}
