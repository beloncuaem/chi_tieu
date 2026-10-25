import 'package:flutter/foundation.dart' hide Category;

import '../../core/config/supabase_config.dart';
import '../database/database_helper.dart';
import '../models/category.dart';

class CategoryRepository {
  Future<List<Category>> getAll() async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        final data = await client
            .from('categories')
            .select()
            .order('is_default', ascending: false)
            .order('name');

        return (data as List).map((row) {
          return Category(
            id: row['id'] as int?,
            name: row['name'] as String,
            icon: row['icon'] as String,
            isDefault: (row['is_default'] as bool?) ?? false,
            createdAt: DateTime.parse(row['created_at'] as String),
          );
        }).toList();
      } catch (e) {
        debugPrint('Supabase get categories error, fallback to SQLite: $e');
      }
    }

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
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        final data = await client
            .from('categories')
            .select()
            .eq('id', id)
            .maybeSingle();

        if (data != null) {
          return Category(
            id: data['id'] as int?,
            name: data['name'] as String,
            icon: data['icon'] as String,
            isDefault: (data['is_default'] as bool?) ?? false,
            createdAt: DateTime.parse(data['created_at'] as String),
          );
        }
      } catch (e) {
        debugPrint('Supabase get category by id error, fallback to SQLite: $e');
      }
    }

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insert(Category category) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        final row = await client
            .from('categories')
            .insert({
              'user_id': user.id,
              'name': category.name,
              'icon': category.icon,
              'color_hex': '#10B981',
              'is_default': false,
            })
            .select()
            .single();
        return row['id'] as int;
      } catch (e) {
        debugPrint('Supabase insert category error: $e');
      }
    }

    final db = await DatabaseHelper.instance.database;
    return await db.insert('categories', category.toMap());
  }

  Future<int> insertCategory(Category category) async {
    return insert(category);
  }

  Future<int> update(Category category) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null && category.id != null) {
      try {
        await client
            .from('categories')
            .update({'name': category.name, 'icon': category.icon})
            .eq('id', category.id!);
        return 1;
      } catch (e) {
        debugPrint('Supabase update category error: $e');
      }
    }

    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<Category?> getOtherCategory() async {
    final all = await getAll();
    try {
      return all.firstWhere((c) => c.name.toLowerCase() == 'khác');
    } catch (_) {
      return all.isNotEmpty ? all.first : null;
    }
  }

  Future<int> deleteAndMoveExpensesToOther(int id) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        final other = await getOtherCategory();
        if (other != null && other.id != null) {
          await client
              .from('expenses')
              .update({'category_id': other.id})
              .eq('category_id', id);
        }
        await client.from('categories').delete().eq('id', id);
        return 1;
      } catch (e) {
        debugPrint('Supabase delete category error: $e');
      }
    }

    final db = await DatabaseHelper.instance.database;
    return db.transaction((txn) async {
      final categoryMaps = await txn.query(
        'categories',
        where: 'name = ?',
        whereArgs: ['Khác'],
        limit: 1,
      );

      int otherId;
      if (categoryMaps.isNotEmpty) {
        otherId = categoryMaps.first['id'] as int;
      } else {
        otherId = await txn.insert('categories', {
          'name': 'Khác',
          'icon': 'dotsThreeOutline',
          'is_default': 1,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      await txn.update(
        'expenses',
        {'category_id': otherId},
        where: 'category_id = ?',
        whereArgs: [id],
      );

      return txn.delete('categories', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> deleteCategory(int id) async {
    return deleteAndMoveExpensesToOther(id);
  }
}
