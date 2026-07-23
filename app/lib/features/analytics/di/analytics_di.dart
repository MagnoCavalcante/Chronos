import '../../../core/di/service_locator.dart';
import '../services/analytics_service.dart';

/// Módulo de DI de Analytics Local.
class AnalyticsDI {
  static void register() {
    final sl = ServiceLocator.instance;
    sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  }
}
