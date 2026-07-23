import 'package:chronos/features/feedback/domain/entities/feedback_entities.dart';
import 'package:chronos/features/feedback/services/feedback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedbackService', () {
    late FeedbackService service;

    setUp(() {
      service = FeedbackService();
    });

    test('inicia sem feedbacks', () {
      expect(service.feedbacks, isEmpty);
    });

    test('submit adiciona feedback', () async {
      await service.submit(
        type: FeedbackType.suggestion,
        message: 'Adicionar modo noturno extra',
      );
      expect(service.feedbacks, hasLength(1));
      expect(service.feedbacks.first.type, FeedbackType.suggestion);
      expect(service.feedbacks.first.message, 'Adicionar modo noturno extra');
    });

    test('submit registra todos os tipos', () async {
      await service.submit(type: FeedbackType.suggestion, message: 'S');
      await service.submit(type: FeedbackType.problem, message: 'P');
      await service.submit(type: FeedbackType.praise, message: 'E');
      expect(service.feedbacks, hasLength(3));
    });

    test('clear remove todos os feedbacks', () async {
      await service.submit(type: FeedbackType.praise, message: 'Ótimo app!');
      await service.clear();
      expect(service.feedbacks, isEmpty);
    });

    test('feedback contém screenContext quando informado', () async {
      await service.submit(
        type: FeedbackType.problem,
        message: 'Botão não funciona',
        screenContext: 'timeline_screen',
      );
      expect(service.feedbacks.first.screenContext, 'timeline_screen');
    });
  });
}
