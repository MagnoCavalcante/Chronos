import '../../../core/di/service_locator.dart';
import '../services/presentation_controller.dart';

/// Módulo de DI do Modo Apresentação.
class PresentationModeDI {
  static void register() {
    final sl = ServiceLocator.instance;
    sl.registerFactory<PresentationController>(() => PresentationController());
  }
}
