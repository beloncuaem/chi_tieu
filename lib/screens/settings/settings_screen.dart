import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../data/repositories/data_sync_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import '../categories/manage_categories_screen.dart';
import '../trash/trash_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _handleSync(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang đồng bộ dữ liệu lên Cloud...'),
          duration: Duration(seconds: 1),
        ),
      );
      final count = await DataSyncService().syncLocalToCloud();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã đồng bộ thành công $count khoản chi lên Supabase!',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đồng bộ: $e'),
            backgroundColor: AppColors.priority3,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // App Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradientDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chi Tiêu App',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authState.user != null
                            ? authState.user!.email ?? 'Tài khoản đám mây'
                            : 'Chế độ Cục bộ (Offline)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cloud Account Section
          if (authState.user != null) ...[
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Đồng bộ dữ liệu cục bộ lên Cloud'),
                    subtitle: const Text(
                      'Đẩy các khoản chi từ máy lên Supabase',
                    ),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () => _handleSync(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.priority3,
                    ),
                    title: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: AppColors.priority3),
                    ),
                    onTap: () async {
                      await ref.read(authProvider.notifier).signOut();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.account_circle_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Đăng nhập Supabase'),
                subtitle: const Text('Kích hoạt đồng bộ hóa trên mọi thiết bị'),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Preferences & Features
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Chế độ tối'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Quản lý danh mục'),
                  leading: const Icon(Icons.label_outline_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageCategoriesScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Thùng rác'),
                  leading: const Icon(Icons.delete_outline_rounded),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrashScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Phiên bản 2.1.0 • Locket Journal',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
