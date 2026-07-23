import 'package:chronos/features/beta/services/feature_toggle_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeatureToggleService', () {
    late FeatureToggleService service;

    setUp(() {
      service = FeatureToggleService();
    });

    test('features ativas por padrão', () {
      expect(service.isEnabled(BetaFeature.aiAssistant), isTrue);
      expect(service.isEnabled(BetaFeature.mapView), isTrue);
    });

    test('setEnabled desativa feature', () async {
      await service.setEnabled(BetaFeature.aiAssistant, false);
      expect(service.isEnabled(BetaFeature.aiAssistant), isFalse);
    });

    test('setEnabled reativa feature', () async {
      await service.setEnabled(BetaFeature.mapView, false);
      await service.setEnabled(BetaFeature.mapView, true);
      expect(service.isEnabled(BetaFeature.mapView), isTrue);
    });

    test('disableAll desativa todas', () async {
      await service.disableAll();
      for (final feature in BetaFeature.values) {
        expect(service.isEnabled(feature), isFalse);
      }
    });

    test('enableAll ativa todas', () async {
      await service.disableAll();
      await service.enableAll();
      for (final feature in BetaFeature.values) {
        expect(service.isEnabled(feature), isTrue);
      }
    });

    test('enabledCount e disabledCount corretos após enableAll/disable', () async {
      await service.enableAll();
      await service.setEnabled(BetaFeature.aiAssistant, false);
      await service.setEnabled(BetaFeature.mapView, false);
      expect(service.disabledCount, 2);
      expect(service.enabledCount, BetaFeature.values.length - 2);
    });

    test('reset volta ao padrão', () async {
      await service.disableAll();
      await service.reset();
      // Após reset, isEnabled retorna true (padrão)
      expect(service.isEnabled(BetaFeature.gamification), isTrue);
    });
  });
}
