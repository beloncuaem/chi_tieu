import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/expense.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/priority_provider.dart';

class ExpenseFormSheet extends ConsumerStatefulWidget {
  final String? imagePath;
  final Expense? expense;

  const ExpenseFormSheet({super.key, this.imagePath, this.expense})
    : assert(imagePath != null || expense != null);

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _captionController;
  late final TextEditingController _amountController;
  int? _selectedCategoryId;
  late int _selectedPriority;
  bool _isSaving = false;

  bool get _isEditing => widget.expense != null;
  String get _sourceImagePath => widget.expense?.imagePath ?? widget.imagePath!;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _captionController = TextEditingController(text: expense?.caption ?? '');
    _amountController = TextEditingController(
      text: expense?.amount.toInt().toString() ?? '',
    );
    _selectedCategoryId = expense?.categoryId;
    _selectedPriority = expense?.priority ?? 2;
  }

  Future<String> _saveImageToLocalDirectory(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('Không tìm thấy ảnh đã chọn');
    }
    final appDir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory(path.join(appDir.path, 'receipts'));
    await receiptsDir.create(recursive: true);
    final extension = path.extension(sourcePath).isEmpty
        ? '.jpg'
        : path.extension(sourcePath);
    final savedImagePath = path.join(
      receiptsDir.path,
      '${const Uuid().v4()}$extension',
    );
    await source.copy(savedImagePath);
    return savedImagePath;
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    final categories = ref.read(categoryProvider).categories;
    final fallbackCategory = categories.where(
      (category) => category.name == 'Khác',
    );
    final categoryId =
        _selectedCategoryId ??
        (fallbackCategory.isEmpty ? null : fallbackCategory.first.id);
    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy danh mục Khác để lưu khoản chi.'),
        ),
      );
      return;
    }

    final amount = double.tryParse(
      _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số tiền phải lớn hơn 0.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        final updated = widget.expense!.copyWith(
          caption: _captionController.text.trim(),
          amount: amount,
          categoryId: categoryId,
          priority: _selectedPriority,
        );
        await ref.read(expenseProvider.notifier).updateExpense(updated);
      } else {
        final storedImagePath = await _saveImageToLocalDirectory(
          _sourceImagePath,
        );
        final newExpense = Expense(
          caption: _captionController.text.trim(),
          amount: amount,
          categoryId: categoryId,
          priority: _selectedPriority,
          imagePath: storedImagePath,
          createdAt: DateTime.now(),
        );
        await ref.read(expenseProvider.notifier).addExpense(newExpense);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Đã cập nhật khoản chi.' : 'Đã lưu khoản chi.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu khoản chi. Vui lòng thử lại.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
    final priorityState = ref.watch(priorityProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Text(
                    _isEditing ? 'Chỉnh sửa khoản chi' : 'Thêm khoản chi',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildSquareImage(),
                  if (_isEditing) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Ảnh không thể thay đổi sau khi đã lưu.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _captionController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú (tùy chọn)',
                      hintText: 'Ví dụ: Ăn trưa, mua sữa...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền (VND)',
                      hintText: '35000',
                      suffixText: '₫',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final amount = double.tryParse(
                        (value ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
                      );
                      return amount == null || amount <= 0
                          ? 'Nhập số tiền lớn hơn 0'
                          : null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Danh mục',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  const Text('Không chọn tag sẽ tự xếp vào danh mục Khác.'),
                  const SizedBox(height: 8),
                  if (categoryState.isLoading &&
                      categoryState.categories.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categoryState.categories.map((category) {
                        final selected = _selectedCategoryId == category.id;
                        return ChoiceChip(
                          label: Text('${category.icon} ${category.name}'),
                          selected: selected,
                          onSelected: (value) => setState(() {
                            _selectedCategoryId = value ? category.id : null;
                          }),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'Mức độ cần thiết',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (priorityState.levels.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: priorityState.levels.map((level) {
                        final selected = _selectedPriority == level.id;
                        return ChoiceChip(
                          label: Text(level.name),
                          selected: selected,
                          selectedColor: level.color.withValues(alpha: 0.25),
                          labelStyle: TextStyle(
                            color: selected ? level.color : null,
                            fontWeight: selected ? FontWeight.bold : null,
                          ),
                          onSelected: (value) {
                            if (value)
                              setState(() => _selectedPriority = level.id);
                          },
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSaving ? null : _saveExpense,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Lưu thay đổi' : 'Lưu khoản chi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquareImage() {
    final file = File(_sourceImagePath);
    return Semantics(
      label: 'Ảnh của khoản chi',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image_outlined, size: 56),
            ),
          ),
        ),
      ),
    );
  }
}
