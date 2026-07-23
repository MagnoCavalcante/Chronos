import 'package:chronos/features/accessibility/domain/entities/accessibility_entities.dart';
import 'package:chronos/features/accessibility/services/accessibility_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AccessibilityService', () {
    late AccessibilityService service;

    setUp(() {
      service = AccessibilityService();
    });

    test('configuração padrão é standard', () {
      expect(service.config.colorMode, AccessibilityMode.standard);
      expect(service.config.fontScale, 1.0);
      expect(service.config.hapticFeedbackEnabled, isTrue);
    });

    test('setColorMode altera modo de cor', () async {
      await service.setColorMode(AccessibilityMode.highContrast);
      expect(service.config.colorMode, AccessibilityMode.highContrast);
    });

    test('setFontScale respeita limites', () async {
      await service.setFontScale(3.0);
      expect(service.config.fontScale, 2.0);

      await service.setFontScale(0.5);
      expect(service.config.fontScale, 0.8);

      await service.setFontScale(1.5);
      expect(service.config.fontScale, 1.5);
    });

    test('generateImageDescription gera texto descritivo', () {
      final desc = service.generateImageDescription(
        title: 'Coliseu',
        entityType: 'monument',
        year: 80,
        location: 'Roma, Itália',
      );
      expect(desc, contains('Coliseu'));
      expect(desc, contains('monument'));
      expect(desc, contains('80'));
      expect(desc, contains('Roma'));
    });

    test('reset restaura configuração padrão', () async {
      await service.setColorMode(AccessibilityMode.protanopia);
      await service.setFontScale(1.8);
      await service.reset();
      expect(service.config.colorMode, AccessibilityMode.standard);
      expect(service.config.fontScale, 1.0);
    });
  });
}
