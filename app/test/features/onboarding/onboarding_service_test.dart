import 'package:chronos/features/onboarding/services/onboarding_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingService', () {
    late OnboardingService service;

    setUp(() {
      service = OnboardingService();
    });

    test('inicia não concluído no passo 0', () {
      expect(service.isCompleted, isFalse);
      expect(service.currentStep, 0);
    });

    test('totalSteps retorna número correto', () {
      expect(service.totalSteps, 8);
    });

    test('next avança passo', () async {
      await service.next();
      expect(service.currentStep, 1);
    });

    test('previous volta passo', () async {
      await service.next();
      await service.next();
      service.previous();
      expect(service.currentStep, 1);
    });

    test('previous não recua abaixo de 0', () {
      service.previous();
      expect(service.currentStep, 0);
    });

    test('skip marca como concluído', () async {
      await service.skip();
      expect(service.isCompleted, isTrue);
    });

    test('complete marca como concluído', () async {
      await service.complete();
      expect(service.isCompleted, isTrue);
    });

    test('reset volta ao estado inicial', () async {
      await service.complete();
      await service.reset();
      expect(service.isCompleted, isFalse);
      expect(service.currentStep, 0);
    });

    test('progress calcula corretamente', () async {
      expect(service.progress, 0.0);
      await service.next(); // passo 1
      await service.next(); // passo 2
      await service.next(); // passo 3
      await service.next(); // passo 4
      await service.next(); // passo 5
      await service.next(); // passo 6
      await service.next(); // passo 7 (último)
      expect(service.progress, 1.0);
    });
  });
}
