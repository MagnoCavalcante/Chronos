import 'package:chronos/features/knowledge_base/data/cache/knowledge_cache_service.dart';
import 'package:chronos/features/knowledge_base/domain/entities/knowledge_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KnowledgeCacheService', () {
    late KnowledgeCacheService cache;

    setUp(() {
      cache = KnowledgeCacheService();
    });

    test('getEntry retorna null se vazio', () {
      expect(cache.getEntry('abc'), isNull);
    });

    test('putEntry e getEntry funcionam', () {
      final entry = KnowledgeEntry(
        entityId: 'test_1',
        entityType: EntityType.character,
        nome: 'Teste',
        resumo: 'Resumo teste.',
      );
      cache.putEntry('test_1', entry);
      final retrieved = cache.getEntry('test_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.nome, 'Teste');
    });

    test('putRelations e getRelations funcionam', () {
      final relations = [
        KnowledgeRelation(
          id: 'r1',
          targetId: 't1',
          targetType: EntityType.event,
          targetName: 'Evento',
          relationType: 'participou',
        ),
      ];
      cache.putRelations('entity_1', relations);
      final retrieved = cache.getRelations('entity_1');
      expect(retrieved, hasLength(1));
    });

    test('invalidate remove entry específica', () {
      final entry = KnowledgeEntry(
        entityId: 'test_2',
        entityType: EntityType.civilization,
        nome: 'Civ',
        resumo: 'Resumo.',
      );
      cache.putEntry('test_2', entry);
      cache.invalidate('test_2');
      expect(cache.getEntry('test_2'), isNull);
    });

    test('clear remove tudo', () {
      cache.putEntry('a', KnowledgeEntry(entityId: 'a', entityType: EntityType.era, nome: 'A', resumo: 'R'));
      cache.putEntry('b', KnowledgeEntry(entityId: 'b', entityType: EntityType.era, nome: 'B', resumo: 'R'));
      cache.clear();
      expect(cache.size, 0);
    });

    test('size retorna contagem correta', () {
      cache.putEntry('x', KnowledgeEntry(entityId: 'x', entityType: EntityType.artifact, nome: 'X', resumo: 'R'));
      cache.putRelations('x', []);
      expect(cache.size, 2);
    });
  });
}
