import '../database/database_helper.dart';

class BudgetAlertRepository {
  Future<bool> hasSent(String month, int threshold) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'budget_alerts',
      where: 'month = ? AND threshold = ?',
      whereArgs: [month, threshold],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<void> markSent(String month, int threshold) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('budget_alerts', {
      'month': month,
      'threshold': threshold,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
