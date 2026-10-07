import '../database/database_helper.dart';
import '../models/category.dart';

class CategoryRepository {
  Future<List<Category>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'categories',
      orderBy: 'is_default DESC, name COLLATE NOCASE',
    );
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  Future<List<Category>> getCategories() async {
    return getAll();
  }

  Future<Category?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insert(Category category) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> insertCategory(Category category) async {
    return insert(category);
  }

  Future<int> update(Category category) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<Category?> getOtherCategory() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: ['Khác'],
      limit: 1,
    );
    return maps.isEmpty ? null : Category.fromMap(maps.first);
  }

  Future<int> deleteAndMoveExpensesToOther(int id) async {
    final db = await DatabaseHelper.instance.database;
    return db.transaction((txn) async {
      final categoryMaps = await txn.query(
        'categories',
        where: 'id = ? AND is_default = 0',
        whereArgs: [id],
      );
      if (categoryMaps.isEmpty) return 0;

      final otherMaps = await txn.query(
        'categories',
        where: 'name = ?',
        whereArgs: ['Khác'],
        limit: 1,
      );
      if (otherMaps.isEmpty) {
        throw StateError('Không tìm thấy danh mục Khác');
      }

      final otherId = otherMaps.first['id'] as int;
      await txn.update(
        'expenses',
        {'category_id': otherId},
        where: 'category_id = ?',
        whereArgs: [id],
      );
      await txn.delete('budgets', where: 'category_id = ?', whereArgs: [id]);
      return txn.delete('categories', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> deleteCategory(int id) async {
    return deleteAndMoveExpensesToOther(id);
  }
}
