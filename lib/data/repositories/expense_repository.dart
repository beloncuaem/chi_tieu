import 'package:flutter/foundation.dart';
import '../../core/config/supabase_config.dart';
import '../database/database_helper.dart';
import '../models/expense.dart';
import 'supabase_storage_service.dart';

class ExpenseRepository {
  final SupabaseStorageService _storageService = SupabaseStorageService();

  Future<int> insertExpense(Expense expense) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        String? imageUrl = expense.imagePath;
        if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
          imageUrl = await _storageService.uploadReceiptImage(imageUrl);
        }

        final row = await client.from('expenses').insert({
          'user_id': user.id,
          'caption': expense.caption,
          'amount': expense.amount,
          'category_id': expense.categoryId,
          'priority': expense.priority,
          'image_url': imageUrl,
          'created_at': expense.createdAt.toIso8601String(),
          'deleted_at': expense.deletedAt?.toIso8601String(),
        }).select().single();

        return row['id'] as int;
      } catch (e) {
        debugPrint('Supabase insert expense error, fallback to SQLite: $e');
      }
    }

    final db = await DatabaseHelper.instance.database;
    return db.insert('expenses', expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null && expense.id != null) {
      try {
        String? imageUrl = expense.imagePath;
        if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
          imageUrl = await _storageService.uploadReceiptImage(imageUrl);
        }

        await client.from('expenses').update({
          'caption': expense.caption,
          'amount': expense.amount,
          'category_id': expense.categoryId,
          'priority': expense.priority,
          'image_url': imageUrl,
          'created_at': expense.createdAt.toIso8601String(),
          'deleted_at': expense.deletedAt?.toIso8601String(),
        }).eq('id', expense.id!);

        return 1;
      } catch (e) {
        debugPrint('Supabase update expense error, fallback to SQLite: $e');
      }
    }

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
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        var query = client.from('expenses').select().isFilter('deleted_at', null);

        if (from != null) {
          query = query.gte('created_at', from.toIso8601String());
        }
        if (to != null) {
          query = query.lte('created_at', to.toIso8601String());
        }
        if (search != null && search.trim().isNotEmpty) {
          query = query.ilike('caption', '%${search.trim()}%');
        }
        if (categoryId != null) {
          query = query.eq('category_id', categoryId);
        }
        if (priority != null) {
          query = query.eq('priority', priority);
        }
        if (minAmount != null) {
          query = query.gte('amount', minAmount);
        }
        if (maxAmount != null) {
          query = query.lte('amount', maxAmount);
        }

        final data = await query.order('created_at', ascending: false);

        return (data as List).map((row) {
          return Expense(
            id: row['id'] as int?,
            imagePath: row['image_url'] as String?,
            caption: row['caption'] as String,
            amount: (row['amount'] as num).toDouble(),
            categoryId: (row['category_id'] as int?) ?? 1,
            priority: (row['priority'] as int?) ?? 0,
            createdAt: DateTime.parse(row['created_at'] as String),
            deletedAt: row['deleted_at'] != null
                ? DateTime.tryParse(row['deleted_at'] as String)
                : null,
          );
        }).toList();
      } catch (e) {
        debugPrint('Supabase getExpenses error, fallback to SQLite: $e');
      }
    }

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
    final expenses = await getExpenses(from: from, to: to);
    return expenses.fold<double>(0.0, (sum, item) => sum + item.amount);
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
    final expenses = await getExpenses(
      categoryId: categoryId,
      from: from,
      to: to,
    );
    return expenses.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  Future<double> getTotalByPriorityAndDateRange(
    int priority,
    DateTime from,
    DateTime to,
  ) async {
    final expenses = await getExpenses(
      priority: priority,
      from: from,
      to: to,
    );
    return expenses.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  Future<int> moveToTrash(int id) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        await client.from('expenses').update({
          'deleted_at': DateTime.now().toIso8601String(),
        }).eq('id', id);
        return 1;
      } catch (e) {
        debugPrint('Supabase moveToTrash error: $e');
      }
    }

    final db = await DatabaseHelper.instance.database;
    return db.update(
      'expenses',
      {'deleted_at': DateTime.now().toIso8601String()},
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
  }

  Future<int> restoreExpense(int id) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        await client.from('expenses').update({
          'deleted_at': null,
        }).eq('id', id);
        return 1;
      } catch (e) {
        debugPrint('Supabase restoreExpense error: $e');
      }
    }

    final db = await DatabaseHelper.instance.database;
    return db.update(
      'expenses',
      {'deleted_at': null},
      where: 'id = ? AND deleted_at IS NOT NULL',
      whereArgs: [id],
    );
  }

  Future<int> permanentlyDeleteExpense(int id) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        await client.from('expenses').delete().eq('id', id);
        return 1;
      } catch (e) {
        debugPrint('Supabase permanentlyDeleteExpense error: $e');
      }
    }

    final db = await DatabaseHelper.instance.database;
    return db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getDeletedExpenses() async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        final data = await client
            .from('expenses')
            .select()
            .not('deleted_at', 'is', null)
            .order('deleted_at', ascending: false);

        return (data as List).map((row) {
          return Expense(
            id: row['id'] as int?,
            imagePath: row['image_url'] as String?,
            caption: row['caption'] as String,
            amount: (row['amount'] as num).toDouble(),
            categoryId: (row['category_id'] as int?) ?? 1,
            priority: (row['priority'] as int?) ?? 0,
            createdAt: DateTime.parse(row['created_at'] as String),
            deletedAt: DateTime.tryParse(row['deleted_at'] as String),
          );
        }).toList();
      } catch (e) {
        debugPrint('Supabase getDeletedExpenses error: $e');
      }
    }

    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'expenses',
      where: 'deleted_at IS NOT NULL',
      orderBy: 'deleted_at DESC',
    );
    return maps.map(Expense.fromMap).toList();
  }

  Future<Expense?> getExpenseById(int id, {bool includeDeleted = false}) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;

    if (client != null && user != null) {
      try {
        var query = client.from('expenses').select().eq('id', id);
        if (!includeDeleted) {
          query = query.isFilter('deleted_at', null);
        }
        final data = await query.maybeSingle();
        if (data != null) {
          return Expense(
            id: data['id'] as int?,
            imagePath: data['image_url'] as String?,
            caption: data['caption'] as String,
            amount: (data['amount'] as num).toDouble(),
            categoryId: (data['category_id'] as int?) ?? 1,
            priority: (data['priority'] as int?) ?? 0,
            createdAt: DateTime.parse(data['created_at'] as String),
            deletedAt: data['deleted_at'] != null
                ? DateTime.tryParse(data['deleted_at'] as String)
                : null,
          );
        }
      } catch (e) {
        debugPrint('Supabase getExpenseById error: $e');
      }
    }

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
    final expenses = await getExpenses(from: from, to: to);
    final map = <String, double>{};
    for (final exp in expenses) {
      final key = '${exp.createdAt.year}-${exp.createdAt.month.toString().padLeft(2, '0')}-${exp.createdAt.day.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0.0) + exp.amount;
    }
    return map;
  }
}
