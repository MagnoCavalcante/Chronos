import '../../../../core/utils/logger.dart';
import '../../domain/entities/knowledge_entities.dart';
import '../../domain/repositories/knowledge_repository.dart';
import '../datasources/knowledge_remote_datasource.dart';
import '../cache/knowledge_cache_service.dart';

/// Implementação do repositório de Knowledge Base com cache.
class KnowledgeRepositoryImpl implements KnowledgeRepository {
  static const String _tag = 'KnowledgeRepo';

  final KnowledgeRemoteDataSource _remote;
  final KnowledgeCacheService _cache;

  KnowledgeRepositoryImpl({
    required KnowledgeRemoteDataSource remote,
    required KnowledgeCacheService cache,
  })  : _remote = remote,
        _cache = cache;

  @override
  Future<KnowledgeEntry?> getEntry(String entityId, EntityType entityType) async {
    // Tentar cache primeiro
    final cached = _cache.getEntry(entityId);
    if (cached != null) {
      ChronosLogger.info('Cache hit para entry: $entityId', tag: _tag);
      return cached;
    }

    // Buscar do remote
    final data = await _remote.fetchEntry(entityId, entityType);
    if (data == null) return null;

    final entry = KnowledgeEntry.fromJson(data);
    _cache.putEntry(entityId, entry);
    return entry;
  }

  @override
  Future<List<KnowledgeRelation>> getRelations(String entityId) async {
    final cached = _cache.getRelations(entityId);
    if (cached != null) return cached;

    final data = await _remote.fetchRelations(entityId);
    final relations = data.map(KnowledgeRelation.fromJson).toList();
    _cache.putRelations(entityId, relations);
    return relations;
  }

  @override
  Future<List<KnowledgeRelation>> getReverseRelations(String entityId) async {
    final data = await _remote.fetchReverseRelations(entityId);
    return data.map(KnowledgeRelation.fromJson).toList();
  }

  @override
  Future<List<HistoricalSource>> getSources(String entityId) async {
    final data = await _remote.fetchSources(entityId);
    return data.map(HistoricalSource.fromJson).toList();
  }

  @override
  Future<List<HistoricalDebate>> getDebates(String entityId) async {
    final data = await _remote.fetchDebates(entityId);
    return data.map(HistoricalDebate.fromJson).toList();
  }

  @override
  Future<List<HistoricalCuriosity>> getCuriosities(String entityId) async {
    final data = await _remote.fetchCuriosities(entityId);
    return data.map(HistoricalCuriosity.fromJson).toList();
  }

  @override
  Future<List<KnowledgeEntry>> search(String query, {EntityType? type}) async {
    final data = await _remote.searchEntries(query, entityType: type?.name);
    return data.map(KnowledgeEntry.fromJson).toList();
  }
}
