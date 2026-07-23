import '../../../core/di/service_locator.dart';
import '../services/design_validator.dart';
import '../services/ui_inspector_service.dart';

/// Módulo de DI das Developer Tools.
class DevToolsDI {
  static void register() {
    final sl = ServiceLocator.instance;
    sl.registerLazySingleton<UIInspectorService>(() => UIInspectorService());
    sl.registerFactory<DesignValidator>(() => DesignValidator());
  }
}
