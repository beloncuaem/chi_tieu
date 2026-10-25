import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/expense.dart';
import 'supabase_storage_service.dart';

class ExpenseRepository {
  final SupabaseStorageService _storageService = SupabaseStorageService();

  SupabaseClient _requireClient() {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw StateError('Chưa kết nối được Supabase. Vui lòng kiểm tra mạng.');
    }
    if (client.auth.currentUser == null) {
      throw StateError('Vui lòng đăng nhập để tiếp tục.');
    }
    return client;
  }

  Expense _fromRow(Map<String, dynamic> row) {
    return Expense(
      id: row['id'] as int?,
      imagePath: row['image_url'] as String?,
      caption: (row['caption'] as String?) ?? '',
      amount: (row['amount'] as num).toDouble(),
      categoryId: (row['category_id'] as int?) ?? 0,
      priority: (row['priority'] as int?) ?? 0,
      createdAt: DateTime.parse(row['created_at'] as String),
      deletedAt: row['deleted_at'] != null
          ? DateTime.tryParse(row['deleted_at'] as String)
          : null,
    );
  }

  Future<String?> _resolveImageUrl(String? path) async {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return _storageService.uploadReceiptImage(path);
  }

  Future<int> insertExpense(Expense expense) async {
    final client = _requireClient();
    final user = client.auth.currentUser!;
    final imageUrl = await _resolveImageUrl(expense.imagePath);

    final row = await client
        .from('expenses')
        .insert({
          'user_id': user.id,
          'caption': expense.caption,
          'amount': expense.amount,
          'category_id': expense.categoryId,
          'priority': expense.priority,
          'image_url': imageUrl,
          'created_at': expense.createdAt.toIso8601String(),
          'deleted_at': expense.deletedAt?.toIso8601String(),
        })
        .select()
        .single();

    return row['id'] as int;
  }

  Future<int> updateExpense(Expense expense) async {
    final client = _requireClient();
    final id = expense.id;
    if (id == null) {
      throw StateError('Không tìm thấy khoản chi cần cập nhật.');
    }

    final imageUrl = await _resolveImageUrl(expense.imagePath);
    await client
        .from('expenses')
        .update({
          'caption': expense.caption,
          'amount': expense.amount,
          'category_id': expense.categoryId,
          'priority': expense.priority,
          'image_url': imageUrl,
          'created_at': expense.createdAt.toIso8601String(),
          'deleted_at': expense.deletedAt?.toIso8601String(),
        })
        .eq('id', id);

    return 1;
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
    final client = _requireClient();
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
    return (data as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
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
    final expenses = await getExpenses(priority: priority, from: from, to: to);
    return expenses.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  Future<int> moveToTrash(int id) async {
    final client = _requireClient();
    await client
        .from('expenses')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
    return 1;
  }

  Future<int> restoreExpense(int id) async {
    final client = _requireClient();
    await client.from('expenses').update({'deleted_at': null}).eq('id', id);
    return 1;
  }

  Future<int> permanentlyDeleteExpense(int id) async {
    final client = _requireClient();
    await client.from('expenses').delete().eq('id', id);
    return 1;
  }

  Future<List<Expense>> getDeletedExpenses() async {
    final client = _requireClient();
    final data = await client
        .from('expenses')
        .select()
        .not('deleted_at', 'is', null)
        .order('deleted_at', ascending: false);

    return (data as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<Expense?> getExpenseById(int id, {bool includeDeleted = false}) async {
    final client = _requireClient();
    var query = client.from('expenses').select().eq('id', id);
    if (!includeDeleted) {
      query = query.isFilter('deleted_at', null);
    }
    final data = await query.maybeSingle();
    return data == null ? null : _fromRow(data);
  }

  Future<Map<String, double>> getDailyTotals(DateTime from, DateTime to) async {
    final expenses = await getExpenses(from: from, to: to);
    final map = <String, double>{};
    for (final exp in expenses) {
      final key =
          '${exp.createdAt.year}-${exp.createdAt.month.toString().padLeft(2, '0')}-${exp.createdAt.day.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0.0) + exp.amount;
    }
    return map;
  }
}
