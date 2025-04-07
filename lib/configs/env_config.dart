import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  static String get baseUrl => _baseUrl;

  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }

  // OpenAI API Configuration
  static String get openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  // Environment
  static bool get isDebugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static bool get useTestAds =>
      dotenv.env['USE_TEST_ADS']?.toLowerCase() == 'true';

  static bool get isConfigured {
    if (kDebugMode) {
      return dotenv.env['OPENAI_API_KEY']?.isNotEmpty ?? false;
    }
    return true;
  }

  static void validate() {
    final requiredVars = [
      // 'FIREBASE_API_KEY',
      // 'FIREBASE_APP_ID',
      // 'FIREBASE_MESSAGING_SENDER_ID',  
      // 'FIREBASE_PROJECT_ID',
      // 'ADMOB_APP_ID',
      'OPENAI_API_KEY',
    ];

    final missingVars =
        requiredVars
            .where((envVar) => dotenv.env[envVar]?.isEmpty ?? true)
            .toList();

    if (missingVars.isNotEmpty) {
      throw Exception(
        'Missing required environment variables: ${missingVars.join(", ")}',
      );
    }
  }

  // Add other environment variables here
  static String get adUnitId => dotenv.env['AD_UNIT_ID'] ?? '';
  static bool get isDevelopment => dotenv.env['ENVIRONMENT'] == 'development';
}
