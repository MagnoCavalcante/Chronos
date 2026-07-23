import '../../../core/di/service_locator.dart';
import '../services/beta_center_service.dart';
import '../services/bug_tracker_service.dart';
import '../services/feature_toggle_service.dart';
import '../services/feedback_assistant_service.dart';
import '../services/release_metrics_service.dart';
import '../services/telemetry_service.dart';

/// Módulo de DI do sistema Beta.
class BetaDI {
  static void register() {
    final sl = ServiceLocator.instance;
    sl.registerLazySingleton<BugTrackerService>(() => BugTrackerService());
    sl.registerLazySingleton<TelemetryService>(() => TelemetryService());
    sl.registerLazySingleton<BetaCenterService>(() => BetaCenterService());
    sl.registerLazySingleton<FeatureToggleService>(() => FeatureToggleService());
    sl.registerLazySingleton<FeedbackAssistantService>(() => FeedbackAssistantService());
    sl.registerLazySingleton<ReleaseMetricsService>(() => ReleaseMetricsService());
  }
}
