import 'package:flutter/foundation.dart';

import '../../core/config/supabase_config.dart';
import '../database/database_helper.dart';
import 'supabase_storage_service.dart';

class DataSyncService {
  final SupabaseStorageService _storageService = SupabaseStorageService();

  Future<int> syncLocalToCloud() async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      throw Exception('Vui lòng đăng nhập để đồng bộ dữ liệu lên Cloud.');
    }

    final db = await DatabaseHelper.instance.database;
    int syncedCount = 0;

    // 1. Sync custom categories (non-default)
    final localCats = await db.query('categories', where: 'is_default = 0');
    final Map<int, int> categoryIdMap = {};

    for (final cat in localCats) {
      final oldId = cat['id'] as int;
      try {
        final inserted = await client
            .from('categories')
            .insert({
              'user_id': user.id,
              'name': cat['name'],
              'icon': cat['icon'],
              'color_hex': '#10B981',
              'is_default': false,
            })
            .select()
            .single();
        categoryIdMap[oldId] = inserted['id'] as int;
      } catch (e) {
        debugPrint('Category sync warning: $e');
      }
    }

    // 2. Sync expenses
    final localExpenses = await db.query(
      'expenses',
      where: 'deleted_at IS NULL',
    );
    for (final exp in localExpenses) {
      try {
        final localImg = exp['image_path'] as String?;
        String? remoteImg;
        if (localImg != null && localImg.isNotEmpty) {
          remoteImg = await _storageService.uploadReceiptImage(localImg);
        }

        final oldCatId = exp['category_id'] as int;
        final targetCatId = categoryIdMap[oldCatId] ?? oldCatId;

        await client.from('expenses').insert({
          'user_id': user.id,
          'caption': exp['caption'],
          'amount': exp['amount'],
          'category_id': targetCatId,
          'priority': exp['priority'],
          'image_url': remoteImg,
          'created_at': exp['created_at'],
        });
        syncedCount++;
      } catch (e) {
        debugPrint('Expense sync warning: $e');
      }
    }

    // 3. Sync budgets
    final localBudgets = await db.query('budgets');
    for (final b in localBudgets) {
      try {
        final oldCatId = b['category_id'] as int?;
        final targetCatId = oldCatId != null
            ? (categoryIdMap[oldCatId] ?? oldCatId)
            : null;

        await client.from('budgets').upsert({
          'user_id': user.id,
          'month': b['month'],
          'category_id': targetCatId,
          'amount': b['amount'],
        });
      } catch (e) {
        debugPrint('Budget sync warning: $e');
      }
    }

    return syncedCount;
  }
}
