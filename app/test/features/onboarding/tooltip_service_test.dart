import 'package:chronos/features/onboarding/services/tooltip_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TooltipService', () {
    late TooltipService service;

    setUp(() {
      service = TooltipService();
    });

    test('tooltips habilitados por padrão', () {
      expect(service.tooltipsEnabled, isTrue);
    });

    test('shouldShow retorna true para tooltip não visto', () {
      expect(service.shouldShow('first_search'), isTrue);
    });

    test('shouldShow retorna false após markSeen', () async {
      await service.markSeen('first_search');
      expect(service.shouldShow('first_search'), isFalse);
    });

    test('shouldShow retorna false quando desabilitado', () async {
      await service.setEnabled(false);
      expect(service.shouldShow('first_search'), isFalse);
    });

    test('resetAll reativa todos os tooltips', () async {
      await service.markSeen('tip_a');
      await service.markSeen('tip_b');
      await service.resetAll();
      expect(service.shouldShow('tip_a'), isTrue);
      expect(service.shouldShow('tip_b'), isTrue);
    });
  });
}
