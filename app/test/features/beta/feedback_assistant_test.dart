import 'package:chronos/features/beta/services/feedback_assistant_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedbackAssistantService', () {
    late FeedbackAssistantService service;

    setUp(() {
      service = FeedbackAssistantService();
    });

    test('inicia sem reports', () {
      expect(service.reports, isEmpty);
      expect(service.totalReports, 0);
    });

    test('captureError registra erro', () async {
      await service.captureError(
        error: Exception('Null pointer'),
        screenContext: 'timeline_page',
      );
      expect(service.totalReports, 1);
      expect(service.reports.first.screenContext, 'timeline_page');
    });

    test('addUserDescription adiciona descrição', () async {
      await service.captureError(error: Exception('Crash'));
      final id = service.reports.first.id;
      await service.addUserDescription(id, 'O app travou ao clicar no botão');
      expect(service.reports.first.userDescription, 'O app travou ao clicar no botão');
    });

    test('clear remove todos os reports', () async {
      await service.captureError(error: Exception('E1'));
      await service.captureError(error: Exception('E2'));
      await service.clear();
      expect(service.reports, isEmpty);
    });
  });
}
