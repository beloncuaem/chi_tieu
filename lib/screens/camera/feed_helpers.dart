import '../../data/models/expense.dart';

/// Ảnh trong nhật ký Locket: chỉ lấy khoản chi có ảnh, mới nhất trước.
List<Expense> buildFeedPhotos(Iterable<Expense> expenses) {
  final photos = expenses.where((expense) {
    final path = expense.imagePath;
    return path != null && path.trim().isNotEmpty;
  }).toList();

  photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return photos;
}
