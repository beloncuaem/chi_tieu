import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/icon_helper.dart';
import '../../data/models/category.dart';
import '../../providers/category_provider.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  Future<void> _showCategoryDialog(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final controller = TextEditingController(text: category?.name ?? '');
    var selectedIcon = IconHelper.normalizeIconKey(
      category?.icon ?? 'dotsThreeOutline',
    );
    final isEditing = category != null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Sửa danh mục' : 'Thêm danh mục'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Biểu tượng'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: IconHelper.availableIcons.map((iconKey) {
                    final isSelected = iconKey == selectedIcon;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () =>
                          setDialogState(() => selectedIcon = iconKey),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(
                                  context,
                                ).colorScheme.primaryContainer
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 1.6,
                          ),
                        ),
                        child: Center(
                          child: IconHelper.getIconWidget(
                            iconKey,
                            size: 20,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Tên danh mục',
                    hintText: 'Ví dụ: Cà phê, Du lịch',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                if (isEditing) {
                  await ref
                      .read(categoryProvider.notifier)
                      .updateCategory(
                        category.copyWith(name: name, icon: selectedIcon),
                      );
                } else {
                  await ref
                      .read(categoryProvider.notifier)
                      .addCategory(name, selectedIcon);
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa danh mục?'),
        content: Text(
          'Các khoản chi thuộc “${category.name}” sẽ chuyển sang “Khác”. '
          'Ngân sách của danh mục này sẽ bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && category.id != null) {
      await ref.read(categoryProvider.notifier).deleteCategory(category.id!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý danh mục')),
      body: state.isLoading && state.categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.categories.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return ListTile(
                  onTap: category.isDefault
                      ? null
                      : () => _showCategoryDialog(
                          context,
                          ref,
                          category: category,
                        ),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: IconHelper.getIconWidget(
                        category.icon,
                        size: 22,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(category.name),
                  subtitle: Text(
                    category.isDefault
                        ? 'Danh mục mặc định'
                        : 'Chạm để chỉnh sửa',
                  ),
                  trailing: category.isDefault
                      ? const Tooltip(
                          message: 'Danh mục mặc định không thể sửa hoặc xóa',
                          child: Icon(Icons.lock_outline),
                        )
                      : IconButton(
                          tooltip: 'Xóa danh mục',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              _confirmDelete(context, ref, category),
                        ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Thêm danh mục'),
      ),
    );
  }
}
