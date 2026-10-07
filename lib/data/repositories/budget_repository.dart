import '../database/database_helper.dart';
import '../models/budget.dart';

class BudgetRepository {
  Future<Budget?> getBudgetForMonth(String month, {int? categoryId}) async {
    final db = await DatabaseHelper.instance.database;
    String whereStr = 'month = ? AND ';
    List<dynamic> args = [month];
    if (categoryId == null) {
      whereStr += 'category_id IS NULL';
    } else {
      whereStr += 'category_id = ?';
      args.add(categoryId);
    }

    final maps = await db.query('budgets', where: whereStr, whereArgs: args);

    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  Future<int> setBudget(Budget budget) async {
    final db = await DatabaseHelper.instance.database;
    final existing = await getBudgetForMonth(
      budget.month,
      categoryId: budget.categoryId,
    );
    if (existing != null) {
      return db.update(
        'budgets',
        budget.copyWith(id: existing.id).toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
    return db.insert('budgets', budget.toMap());
  }

  Future<int> insertBudget(Budget budget) async {
    return await setBudget(budget);
  }

  Future<int> deleteBudget(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Budget>> getBudgetsByMonth(String month) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'budgets',
      where: 'month = ?',
      whereArgs: [month],
    );
    return maps.map((map) => Budget.fromMap(map)).toList();
  }

  Future<double> getAllocatedAmount(String month) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM budgets WHERE month = ? AND category_id IS NOT NULL',
      [month],
    );
    return ((result.first['total'] as num?) ?? 0).toDouble();
  }
}
