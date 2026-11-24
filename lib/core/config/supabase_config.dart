import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://stylehouse-mock.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'mock-anon-key';

  static bool get isMockMode =>
      supabaseUrl.contains('mock') || supabaseAnonKey.contains('mock');

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // In case .env asset cannot be read in some unit test runners
    }

    if (!isMockMode) {
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          // ignore: deprecated_member_use
          anonKey: supabaseAnonKey,
        );
        _isInitialized = true;
      } catch (_) {
        _isInitialized = false;
      }
    }
  }

  static SupabaseClient? get client {
    if (_isInitialized) {
      try {
        return Supabase.instance.client;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
