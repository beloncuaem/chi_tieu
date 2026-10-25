import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/budget.dart';

class BudgetRepository {
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

  Budget _fromRow(Map<String, dynamic> row) {
    return Budget(
      id: row['id'] as int?,
      month: row['month'] as String,
      categoryId: row['category_id'] as int?,
      amount: (row['amount'] as num).toDouble(),
    );
  }

  Future<Budget?> getBudgetForMonth(String month, {int? categoryId}) async {
    final client = _requireClient();
    var query = client.from('budgets').select().eq('month', month);
    if (categoryId == null) {
      query = query.isFilter('category_id', null);
    } else {
      query = query.eq('category_id', categoryId);
    }
    // Phiên bản cũ dùng upsert với category_id NULL nên có thể đã tạo nhiều
    // dòng ngân sách tổng. Lấy dòng mới nhất thay vì maybeSingle() gây lỗi.
    final rows = await query.order('id', ascending: false).limit(1);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<int> setBudget(Budget budget) async {
    final client = _requireClient();
    final existing = await getBudgetForMonth(
      budget.month,
      categoryId: budget.categoryId,
    );

    if (existing?.id != null) {
      await client
          .from('budgets')
          .update({'amount': budget.amount})
          .eq('id', existing!.id!);
      if (budget.categoryId == null) {
        // Dọn các dòng ngân sách tổng trùng còn sót lại.
        await client
            .from('budgets')
            .delete()
            .eq('month', budget.month)
            .isFilter('category_id', null)
            .neq('id', existing.id!);
      }
      return existing.id!;
    }

    final row = await client
        .from('budgets')
        .insert({
          'user_id': client.auth.currentUser!.id,
          'month': budget.month,
          'category_id': budget.categoryId,
          'amount': budget.amount,
        })
        .select()
        .single();
    return row['id'] as int;
  }

  Future<void> clearTotalBudget(String month) async {
    final client = _requireClient();
    await client
        .from('budgets')
        .delete()
        .eq('month', month)
        .isFilter('category_id', null);
  }

  Future<int> insertBudget(Budget budget) async {
    return setBudget(budget);
  }

  Future<int> deleteBudget(int id) async {
    final client = _requireClient();
    await client.from('budgets').delete().eq('id', id);
    return 1;
  }

  Future<List<Budget>> getBudgetsByMonth(String month) async {
    final client = _requireClient();
    final data = await client
        .from('budgets')
        .select()
        .eq('month', month)
        .order('id', ascending: true);
    return (data as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<double> getAllocatedAmount(String month) async {
    final budgets = await getBudgetsByMonth(month);
    return budgets
        .where((b) => b.categoryId != null)
        .fold<double>(0.0, (sum, b) => sum + b.amount);
  }
}
