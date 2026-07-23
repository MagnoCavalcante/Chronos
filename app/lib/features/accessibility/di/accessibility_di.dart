import '../../../core/di/service_locator.dart';
import '../services/accessibility_service.dart';

/// Módulo de DI de Acessibilidade.
class AccessibilityDI {
  static void register() {
    final sl = ServiceLocator.instance;
    sl.registerLazySingleton<AccessibilityService>(() => AccessibilityService());
  }
}
