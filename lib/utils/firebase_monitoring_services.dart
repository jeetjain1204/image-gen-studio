import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseMonitoringService {
  static final FirebaseMonitoringService instance =
      FirebaseMonitoringService._internal();
  final FirebasePerformance _performance = FirebasePerformance.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  FirebaseMonitoringService._internal();

  Future<void> initialize() async {
    // Enable Crashlytics debug mode in development
    await _crashlytics.setCrashlyticsCollectionEnabled(true);

    // Enable Performance Monitoring
    await _performance.setPerformanceCollectionEnabled(true);
  }

  // Performance Monitoring Methods
  Future<T> trackOperation<T>({
    required String name,
    required Future<T> Function() operation,
  }) async {
    final trace = _performance.newTrace(name);
    await trace.start();
    try {
      final result = await operation();
      await trace.stop();
      return result;
    } catch (e, stackTrace) {
      await trace.stop();
      await logError(e, stackTrace, reason: 'Operation failed: $name');
      rethrow;
    }
  }

  Future<T> trackNetworkRequest<T>({
    required String url,
    required Future<T> Function() request,
  }) async {
    final metric = _performance.newHttpMetric(url, HttpMethod.Get);
    await metric.start();

    try {
      final result = await request();
      await metric.stop();
      return result;
    } catch (e) {
      await metric.stop();
      rethrow;
    }
  }

  // Crashlytics Methods
  Future<void> logError(
    dynamic error,
    StackTrace stackTrace, {
    String? reason,
    List<String>? information,
  }) async {
    if (reason != null) {
      await _crashlytics.setCustomKey('error_reason', reason);
    }
    if (information != null) {
      for (var i = 0; i < information.length; i++) {
        await _crashlytics.setCustomKey('info_$i', information[i]);
      }
    }
    await _crashlytics.recordError(error, stackTrace);
  }

  Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }
}
