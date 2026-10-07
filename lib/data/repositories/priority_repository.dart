import '../database/database_helper.dart';
import '../models/priority_level.dart';

class PriorityRepository {
  Future<List<PriorityLevel>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('priority_levels', orderBy: 'sort_order ASC');
    return maps.map(PriorityLevel.fromMap).toList();
  }

  Future<int> insert(PriorityLevel level) async {
    final db = await DatabaseHelper.instance.database;
    return db.insert('priority_levels', level.toMap());
  }

  Future<int> update(PriorityLevel level) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'priority_levels',
      level.toMap(),
      where: 'id = ?',
      whereArgs: [level.id],
    );
  }

  Future<void> deleteAndMoveExpenses({
    required int id,
    required int replacementId,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.update(
        'expenses',
        {'priority': replacementId},
        where: 'priority = ?',
        whereArgs: [id],
      );
      await txn.delete('priority_levels', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> nextId() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(
      'SELECT MAX(id) AS max_id FROM priority_levels',
    );
    return ((rows.first['max_id'] as int?) ?? -1) + 1;
  }
}
