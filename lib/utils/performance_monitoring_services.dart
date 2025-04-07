import 'package:firebase_performance/firebase_performance.dart';

class PerformanceMonitoringService {
  static final PerformanceMonitoringService instance =
      PerformanceMonitoringService._internal();
  final FirebasePerformance _performance = FirebasePerformance.instance;

  PerformanceMonitoringService._internal();

  Future<void> initialize() async {
    await _performance.setPerformanceCollectionEnabled(true);
  }

  Future<void> startTrace(String traceName) async {
    final trace = _performance.newTrace(traceName);
    await trace.start();
  }

  Future<void> stopTrace(String traceName) async {
    final trace = _performance.newTrace(traceName);
    await trace.stop();
  }

  Future<void> addMetric(String traceName, String metricName, int value) async {
    final trace = _performance.newTrace(traceName);
    trace.setMetric(metricName, value);
  }

  Future<void> addAttribute(
    String traceName,
    String attributeName,
    String value,
  ) async {
    final trace = _performance.newTrace(traceName);
    trace.putAttribute(attributeName, value);
  }

  Future<void> recordImageGenerationTime(
    String featureType,
    int milliseconds,
  ) async {
    final trace = _performance.newTrace('image_generation');
    await trace.start();
    trace.putAttribute('feature_type', featureType);
    trace.setMetric('generation_time', milliseconds);
    await trace.stop();
  }

  Future<void> recordAdLoadTime(String adType, int milliseconds) async {
    final trace = _performance.newTrace('ad_load');
    await trace.start();
    trace.putAttribute('ad_type', adType);
    trace.setMetric('load_time', milliseconds);
    await trace.stop();
  }

  Future<void> recordFirebaseOperationTime(
    String operationType,
    int milliseconds,
  ) async {
    final trace = _performance.newTrace('firebase_operation');
    await trace.start();
    trace.putAttribute('operation_type', operationType);
    trace.setMetric('operation_time', milliseconds);
    await trace.stop();
  }
}
