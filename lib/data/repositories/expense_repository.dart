import '../database/database_helper.dart';
import '../models/expense.dart';

class ExpenseRepository {
  Future<int> insertExpense(Expense expense) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('expenses', expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [expense.id],
    );
  }

  Future<List<Expense>> getExpenses({
    DateTime? from,
    DateTime? to,
    String? search,
    int? categoryId,
    int? priority,
    double? minAmount,
    double? maxAmount,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final conditions = <String>['deleted_at IS NULL'];
    final whereArgs = <dynamic>[];

    if (from != null && to != null) {
      conditions.add('created_at >= ? AND created_at <= ?');
      whereArgs.addAll([from.toIso8601String(), to.toIso8601String()]);
    }
    if (search != null && search.trim().isNotEmpty) {
      conditions.add('caption LIKE ?');
      whereArgs.add('%${search.trim()}%');
    }
    if (categoryId != null) {
      conditions.add('category_id = ?');
      whereArgs.add(categoryId);
    }
    if (priority != null) {
      conditions.add('priority = ?');
      whereArgs.add(priority);
    }
    if (minAmount != null) {
      conditions.add('amount >= ?');
      whereArgs.add(minAmount);
    }
    if (maxAmount != null) {
      conditions.add('amount <= ?');
      whereArgs.add(maxAmount);
    }

    final maps = await db.query(
      'expenses',
      where: conditions.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return maps.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> getExpensesByCategory(
    int categoryId, {
    DateTime? from,
    DateTime? to,
  }) {
    return getExpenses(from: from, to: to, categoryId: categoryId);
  }

  Future<List<Expense>> getExpensesToday() async {
    final now = DateTime.now();
    return getExpenses(
      from: DateTime(now.year, now.month, now.day),
      to: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );
  }

  Future<double> getTotalByDateRange(DateTime from, DateTime to) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      '''SELECT SUM(amount) AS total FROM expenses
         WHERE deleted_at IS NULL AND created_at >= ? AND created_at <= ?''',
      [from.toIso8601String(), to.toIso8601String()],
    );
    return ((result.first['total'] as num?) ?? 0).toDouble();
  }

  Future<double> getTotalAmount({
    required DateTime from,
    required DateTime to,
  }) {
    return getTotalByDateRange(from, to);
  }

  Future<double> getTotalByCategoryAndDateRange(
    int categoryId,
    DateTime from,
    DateTime to,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      '''SELECT SUM(amount) AS total FROM expenses
         WHERE category_id = ? AND deleted_at IS NULL
         AND created_at >= ? AND created_at <= ?''',
      [categoryId, from.toIso8601String(), to.toIso8601String()],
    );
    return ((result.first['total'] as num?) ?? 0).toDouble();
  }

  Future<double> getTotalByPriorityAndDateRange(
    int priority,
    DateTime from,
    DateTime to,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      '''SELECT SUM(amount) AS total FROM expenses
         WHERE priority = ? AND deleted_at IS NULL
         AND created_at >= ? AND created_at <= ?''',
      [priority, from.toIso8601String(), to.toIso8601String()],
    );
    return ((result.first['total'] as num?) ?? 0).toDouble();
  }

  Future<int> moveToTrash(int id) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'expenses',
      {'deleted_at': DateTime.now().toIso8601String()},
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
  }

  Future<int> restoreExpense(int id) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'expenses',
      {'deleted_at': null},
      where: 'id = ? AND deleted_at IS NOT NULL',
      whereArgs: [id],
    );
  }

  Future<int> permanentlyDeleteExpense(int id) async {
    final db = await DatabaseHelper.instance.database;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getDeletedExpenses() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'expenses',
      where: 'deleted_at IS NOT NULL',
      orderBy: 'deleted_at DESC',
    );
    return maps.map(Expense.fromMap).toList();
  }

  Future<Expense?> getExpenseById(int id, {bool includeDeleted = false}) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'expenses',
      where: includeDeleted ? 'id = ?' : 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isEmpty ? null : Expense.fromMap(maps.first);
  }

  Future<Map<String, double>> getDailyTotals(DateTime from, DateTime to) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      '''SELECT date(created_at) AS date_str, SUM(amount) AS total
         FROM expenses
         WHERE deleted_at IS NULL AND created_at >= ? AND created_at <= ?
         GROUP BY date(created_at)''',
      [from.toIso8601String(), to.toIso8601String()],
    );

    return {
      for (final row in result)
        row['date_str'] as String: ((row['total'] as num?) ?? 0).toDouble(),
    };
  }
}
