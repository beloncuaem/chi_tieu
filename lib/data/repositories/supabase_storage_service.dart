import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/config/supabase_config.dart';

class SupabaseStorageService {
  static const String bucketName = 'expense-receipts';

  Future<String?> uploadReceiptImage(String localFilePath) async {
    final client = SupabaseConfig.client;
    if (client == null) return localFilePath;

    final user = client.auth.currentUser;
    if (user == null) return localFilePath;

    try {
      final file = File(localFilePath);
      if (!file.existsSync()) return null;

      final fileExt = localFilePath.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final storagePath = '${user.id}/$fileName';

      await client.storage.from(bucketName).upload(
            storagePath,
            file,
          );

      final publicUrl = client.storage.from(bucketName).getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading receipt to Supabase Storage: $e');
      // Fallback về local file path nếu có lỗi mạng hoặc storage
      return localFilePath;
    }
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

