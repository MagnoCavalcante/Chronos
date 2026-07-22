import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/relationships/relationship_engine.dart';
import 'package:chronos/presentation/controllers/relationship_controller.dart';

void main() {
  group('RelationshipController', () {
    testWidgets('inicia em estado idle sem dados', (tester) async {
      final controller = RelationshipController();
      expect(controller.status, RelationshipStateStatus.idle);
      expect(controller.groups, isEmpty);
      expect(controller.suggestions, isEmpty);
    });

    testWidgets('discover retorna vazio sem erro quando Supabase ausente', (tester) async {
      final controller = RelationshipController();
      await controller.discover(entityType: 'historical_character', entityId: '00000000-0000-0000-0000-000000000001');
      expect(controller.status, RelationshipStateStatus.loaded);
      expect(controller.hasError, false);
      expect(controller.groups, isEmpty);
    });

    testWidgets('refresh reinicia e mantém estado loaded', (tester) async {
      final controller = RelationshipController();
      await controller.discover(entityType: 'civilization', entityId: '00000000-0000-0000-0000-000000000001');
      expect(controller.hasData, true);
      await controller.refresh(entityType: 'civilization', entityId: '00000000-0000-0000-0000-000000000001');
      expect(controller.status, RelationshipStateStatus.loaded);
    });
  });

  group('RelationshipEngine', () {
    test('suggestions retorna lista vazia sem conexão', () async {
      final engine = RelationshipEngine();
      final suggestions = await engine.suggestions(
        entityType: 'historical_character',
        entityId: '00000000-0000-0000-0000-000000000001',
      );
      expect(suggestions, isEmpty);
    });
  });
}
