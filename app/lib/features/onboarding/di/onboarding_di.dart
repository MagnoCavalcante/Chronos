import '../../../core/di/service_locator.dart';
import '../services/onboarding_service.dart';
import '../services/tooltip_service.dart';

/// Módulo de DI do Onboarding e Tooltips.
class OnboardingDI {
  static void register() {
    final sl = ServiceLocator.instance;
    sl.registerLazySingleton<OnboardingService>(() => OnboardingService());
    sl.registerLazySingleton<TooltipService>(() => TooltipService());
  }
}
