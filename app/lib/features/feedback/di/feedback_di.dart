import '../../../core/di/service_locator.dart';
import '../services/feedback_service.dart';

/// Módulo de DI do sistema de Feedback.
class FeedbackDI {
  static void register() {
    final sl = ServiceLocator.instance;
    sl.registerLazySingleton<FeedbackService>(() => FeedbackService());
  }
}
