import 'relationship_item.dart';
import 'relationship_repository.dart';

/// Engine central de descoberta e classificação de relacionamentos históricos.
class RelationshipEngine {
  final RelationshipRepository _repository;
  final Map<String, List<RelatedItem>> _cache = {};

  RelationshipEngine({RelationshipRepository? repository})
      : _repository = repository ?? RelationshipRepository();

  String _cacheKey(String entityType, String entityId) => '$entityType:$entityId';

  /// Descobre e classifica relacionamentos para uma entidade.
  ///
  /// Agrupa itens por `relationType` e ordena por `strength` decrescente.
  Future<List<RelatedGroup>> discover({
    required String entityType,
    required String entityId,
    int limit = 100,
  }) async {
    final key = _cacheKey(entityType, entityId);
    if (_cache.containsKey(key)) {
      return _groupAndSort(_cache[key]!);
    }

    final items = await _repository.getRelated(
      entityType: entityType,
      entityId: entityId,
      limit: limit,
    );

    _cache[key] = items;
    return _groupAndSort(items);
  }

  /// Força uma nova descoberta, ignorando o cache local.
  Future<List<RelatedGroup>> refresh({
    required String entityType,
    required String entityId,
    int limit = 100,
  }) async {
    _cache.remove(_cacheKey(entityType, entityId));
    return discover(entityType: entityType, entityId: entityId, limit: limit);
  }

  /// Retorna sugestões "Você também pode gostar de..." com base nos relacionamentos.
  Future<List<RelatedItem>> suggestions({
    required String entityType,
    required String entityId,
    int count = 5,
  }) async {
    final groups = await discover(entityType: entityType, entityId: entityId);
    final all = groups.expand((g) => g.items).toList()
      ..sort((a, b) => b.strength.compareTo(a.strength));
    return all.take(count).toList();
  }

  /// Monta caminho de exploração entre duas entidades usando força bruta de 1 salto.
  Future<List<RelatedItem>> tracePath({
    required String entityType,
    required String entityId,
    required String targetType,
    required String targetId,
  }) async {
    final source = await discover(entityType: entityType, entityId: entityId);
    final items = source.expand((g) => g.items).toList();
    final direct = items.firstWhere(
      (i) => i.entityType == targetType && i.id == targetId,
      orElse: () => throw StateError('Caminho direto não encontrado entre as entidades'),
    );
    return [direct];
  }

  List<RelatedGroup> _groupAndSort(List<RelatedItem> items) {
    final groups = <String, RelatedGroup>{};
    for (final item in items) {
      groups.putIfAbsent(
        item.relationType,
        () => RelatedGroup(relationType: item.relationType, items: []),
      );
      groups[item.relationType]!.items.add(item);
    }

    final result = groups.values.toList();
    for (final group in result) {
      group.items.sort((a, b) => b.strength.compareTo(a.strength));
    }
    return result..sort((a, b) => _priority(a.relationType).compareTo(_priority(b.relationType)));
  }

  int _priority(String relationType) {
    const priorities = {
      'Civilização': 1,
      'Origem': 1,
      'Personagem': 2,
      'Personagem Relacionado': 2,
      'Personagem Envolvido': 2,
      'Evento': 3,
      'Evento Anterior': 3,
      'Evento Posterior': 3,
      'Localização': 4,
      'Artefato': 5,
      'Fonte': 6,
      'Contemporâneo': 99,
    };
    return priorities[relationType] ?? 50;
  }
}

/// Grupo de itens relacionados por tipo de relacionamento.
class RelatedGroup {
  final String relationType;
  final List<RelatedItem> items;

  RelatedGroup({required this.relationType, required this.items});
}
