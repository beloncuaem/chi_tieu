import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static SupabaseClient? get client {
    if (!_isInitialized) return null;
    return Supabase.instance.client;
  }

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Warning: Could not load .env file: $e");
    }

    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (url.isNotEmpty &&
        anonKey.isNotEmpty &&
        !url.contains('your-project.supabase.co')) {
      try {
        await Supabase.initialize(
          url: url,
          anonKey: anonKey,
        );
        _isInitialized = true;
        debugPrint("Supabase initialized successfully.");
      } catch (e) {
        debugPrint("Error initializing Supabase: $e");
      }
    } else {
      debugPrint("Supabase credentials not configured in .env yet.");
    }
  }
}

