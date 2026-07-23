import 'package:chronos/features/knowledge_base/data/cache/knowledge_cache_service.dart';
import 'package:chronos/features/knowledge_base/data/datasources/knowledge_remote_datasource.dart';
import 'package:chronos/features/knowledge_base/data/repositories/knowledge_repository_impl.dart';
import 'package:chronos/features/knowledge_base/domain/entities/knowledge_entities.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock do DataSource que retorna dados em memória.
class MockKnowledgeRemoteDataSource implements KnowledgeRemoteDataSource {
  final Map<String, Map<String, dynamic>> entries = {};

  @override
  Future<Map<String, dynamic>?> fetchEntry(String entityId, EntityType entityType) async {
    return entries[entityId];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRelations(String entityId) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchReverseRelations(String entityId) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchSources(String entityId) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchDebates(String entityId) async => [];

  @override
  Future<List<Map<String, dynamic>>> fetchCuriosities(String entityId) async => [];

  @override
  Future<List<Map<String, dynamic>>> searchEntries(String query, {String? entityType}) async => [];
}

void main() {
  group('KnowledgeRepositoryImpl', () {
    late MockKnowledgeRemoteDataSource mockDataSource;
    late KnowledgeCacheService cache;
    late KnowledgeRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockKnowledgeRemoteDataSource();
      cache = KnowledgeCacheService();
      repository = KnowledgeRepositoryImpl(remote: mockDataSource, cache: cache);
    });

    test('getEntry retorna null quando não existe', () async {
      final result = await repository.getEntry('inexistente', EntityType.character);
      expect(result, isNull);
    });

    test('getEntry retorna entry quando existe no remote', () async {
      mockDataSource.entries['char_test'] = {
        'entity_id': 'char_test',
        'entity_type': 'character',
        'nome': 'Personagem Teste',
        'resumo': 'Um resumo.',
      };

      final result = await repository.getEntry('char_test', EntityType.character);
      expect(result, isNotNull);
      expect(result!.nome, 'Personagem Teste');
    });

    test('getEntry usa cache na segunda chamada', () async {
      mockDataSource.entries['char_cached'] = {
        'entity_id': 'char_cached',
        'entity_type': 'character',
        'nome': 'Cached',
        'resumo': 'Cached.',
      };

      // Primeira chamada - vai ao remote
      await repository.getEntry('char_cached', EntityType.character);

      // Remove do remote
      mockDataSource.entries.remove('char_cached');

      // Segunda chamada - deve vir do cache
      final result = await repository.getEntry('char_cached', EntityType.character);
      expect(result, isNotNull);
      expect(result!.nome, 'Cached');
    });

    test('getRelations retorna lista vazia quando não há', () async {
      final result = await repository.getRelations('sem_relacoes');
      expect(result, isEmpty);
    });

    test('search retorna lista vazia para mock', () async {
      final result = await repository.search('teste');
      expect(result, isEmpty);
    });
  });
}
