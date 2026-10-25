import '../../core/config/supabase_config.dart';

class BudgetAlertRepository {
  Future<bool> hasSent(String month, int threshold) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      throw StateError('Vui lòng đăng nhập để tiếp tục.');
    }

    final data = await client
        .from('budget_alerts')
        .select('id')
        .eq('month', month)
        .eq('threshold', threshold)
        .limit(1);
    return (data as List).isNotEmpty;
  }

  Future<void> markSent(String month, int threshold) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      throw StateError('Vui lòng đăng nhập để tiếp tục.');
    }

    await client.from('budget_alerts').upsert({
      'user_id': user.id,
      'month': month,
      'threshold': threshold,
    }, onConflict: 'user_id,month,threshold');
  }
}
