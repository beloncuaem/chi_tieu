import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';

class SupabaseStorageService {
  static const String bucketName = 'expense-receipts';

  Future<String> uploadReceiptImage(String localFilePath) async {
    final client = SupabaseConfig.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      throw StateError('Vui lòng đăng nhập để lưu ảnh lên Cloud.');
    }

    final file = File(localFilePath);
    if (!await file.exists()) {
      throw StateError('Không tìm thấy ảnh để tải lên Cloud.');
    }

    final extension = localFilePath.split('.').last.toLowerCase();
    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.lengthSync()}.$extension';
    final storagePath = '${user.id}/$fileName';

    await client.storage.from(bucketName).upload(
      storagePath,
      file,
      fileOptions: FileOptions(contentType: contentType, upsert: false),
    );

    return client.storage.from(bucketName).getPublicUrl(storagePath);
  }

  Future<void> deleteReceiptImage(String imageUrl) async {
    final client = SupabaseConfig.client;
    if (client == null) return;

    try {
      if (imageUrl.contains('/$bucketName/')) {
        final path = imageUrl.split('/$bucketName/').last;
        await client.storage.from(bucketName).remove([path]);
      }
    } catch (e) {
      debugPrint('Error deleting receipt from Supabase Storage: $e');
    }
  }
}
