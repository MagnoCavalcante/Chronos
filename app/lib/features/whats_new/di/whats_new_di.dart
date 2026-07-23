import '../../../core/di/service_locator.dart';
import '../services/whats_new_service.dart';

/// Módulo de DI do sistema Novidades da Versão.
class WhatsNewDI {
  static void register() {
    final sl = ServiceLocator.instance;
    sl.registerLazySingleton<WhatsNewService>(() => WhatsNewService());
  }
}
