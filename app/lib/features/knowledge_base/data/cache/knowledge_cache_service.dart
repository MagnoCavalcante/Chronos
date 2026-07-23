import '../../domain/entities/knowledge_entities.dart';

/// Cache em memória para a Knowledge Base.
///
/// TTL de 30 minutos para entradas individuais.
/// Suporta invalidação manual e automática.
class KnowledgeCacheService {
  static const Duration _ttl = Duration(minutes: 30);

  final Map<String, _CacheItem<KnowledgeEntry>> _entries = {};
  final Map<String, _CacheItem<List<KnowledgeRelation>>> _relations = {};

  /// Obtém entry do cache (null se expirado ou inexistente).
  KnowledgeEntry? getEntry(String entityId) {
    final item = _entries[entityId];
    if (item == null || item.isExpired) {
      _entries.remove(entityId);
      return null;
    }
    return item.data;
  }

  /// Salva entry no cache.
  void putEntry(String entityId, KnowledgeEntry entry) {
    _entries[entityId] = _CacheItem(data: entry, cachedAt: DateTime.now());
  }

  /// Obtém relações do cache.
  List<KnowledgeRelation>? getRelations(String entityId) {
    final item = _relations[entityId];
    if (item == null || item.isExpired) {
      _relations.remove(entityId);
      return null;
    }
    return item.data;
  }

  /// Salva relações no cache.
  void putRelations(String entityId, List<KnowledgeRelation> relations) {
    _relations[entityId] = _CacheItem(data: relations, cachedAt: DateTime.now());
  }

  /// Invalida cache de uma entidade específica.
  void invalidate(String entityId) {
    _entries.remove(entityId);
    _relations.remove(entityId);
  }

  /// Limpa todo o cache.
  void clear() {
    _entries.clear();
    _relations.clear();
  }

  /// Quantidade de itens em cache.
  int get size => _entries.length + _relations.length;
}

class _CacheItem<T> {
  final T data;
  final DateTime cachedAt;

  _CacheItem({required this.data, required this.cachedAt});

  bool get isExpired => DateTime.now().difference(cachedAt) > KnowledgeCacheService._ttl;
}
