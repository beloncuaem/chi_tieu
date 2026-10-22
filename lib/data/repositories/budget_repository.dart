import 'package:flutter/foundation.dart';
import '../../core/config/supabase_config.dart';
import '../database/database_helper.dart';
import '../models/budget.dart';

class BudgetRepository {
  Future<Budget?> getBudgetForMonth(String month, {int? categoryId}) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        var query = client.from('budgets').select().eq('month', month);
        if (categoryId == null) {
          query = query.isFilter('category_id', null);
        } else {
          query = query.eq('category_id', categoryId);
        }
        final data = await query.maybeSingle();
        if (data != null) {
          return Budget(
            id: data['id'] as int?,
            month: data['month'] as String,
            categoryId: data['category_id'] as int?,
            amount: (data['amount'] as num).toDouble(),
          );
        }
      } catch (e) {
        debugPrint('Supabase getBudgetForMonth error, fallback to SQLite: $e');
      }
    }

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
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        final row = await client.from('budgets').upsert({
          'user_id': user.id,
          'month': budget.month,
          'category_id': budget.categoryId,
          'amount': budget.amount,
        }, onConflict: 'user_id,month,category_id').select().single();
        return row['id'] as int;
      } catch (e) {
        debugPrint('Supabase setBudget error, fallback to SQLite: $e');
      }
    }

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
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        await client.from('budgets').delete().eq('id', id);
        return 1;
      } catch (e) {
        debugPrint('Supabase deleteBudget error: $e');
      }
    }

    final db = await DatabaseHelper.instance.database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Budget>> getBudgetsByMonth(String month) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        final data = await client.from('budgets').select().eq('month', month);
        return (data as List).map((row) {
          return Budget(
            id: row['id'] as int?,
            month: row['month'] as String,
            categoryId: row['category_id'] as int?,
            amount: (row['amount'] as num).toDouble(),
          );
        }).toList();
      } catch (e) {
        debugPrint('Supabase getBudgetsByMonth error, fallback to SQLite: $e');
      }
    }

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'budgets',
      where: 'month = ?',
      whereArgs: [month],
    );
    return maps.map((map) => Budget.fromMap(map)).toList();
  }

  Future<double> getAllocatedAmount(String month) async {
    final budgets = await getBudgetsByMonth(month);
    return budgets
        .where((b) => b.categoryId != null)
        .fold<double>(0.0, (sum, b) => sum + b.amount);
  }
}
