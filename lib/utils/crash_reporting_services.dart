import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashReportingService {
  static final CrashReportingService instance =
      CrashReportingService._internal();
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  CrashReportingService._internal();

  Future<void> initialize() async {
    // Enable crash reporting
    await _crashlytics.setCrashlyticsCollectionEnabled(true);

    // Set user identifier when user logs in
    // This should be called from your auth service
    // await _crashlytics.setUserIdentifier(userId);
  }

  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Iterable<Object> information = const [],
  }) async {
    try {
      // Add custom information
      for (var info in information) {
        _crashlytics.log(info.toString());
      }

      // Add reason if provided
      if (reason != null) {
        _crashlytics.log('Error reason: $reason');
      }

      // Record the error
      await _crashlytics.recordError(error, stackTrace, reason: reason);
    } catch (e) {}
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {}
  }

  Future<void> setUserIdentifier(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {}
  }
}
