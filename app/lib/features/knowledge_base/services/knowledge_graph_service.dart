import 'package:flutter/foundation.dart';

import '../domain/entities/knowledge_entities.dart';
import '../domain/repositories/knowledge_repository.dart';

/// Serviço do Grafo de Conhecimento.
///
/// Fornece relações bidirecionais, traversal, cadeia de acontecimentos,
/// sugestões de estudo, e breadcrumb hierárquico.
/// Preparado para milhões de relações sem alterações estruturais.
class KnowledgeGraphService extends ChangeNotifier {
  final KnowledgeRepository _repository;

  KnowledgeGraphService({required KnowledgeRepository repository})
      : _repository = repository;

  /// Obtém relações bidirecionais de uma entidade.
  /// Busca tanto source→target quanto target→source (relações inversas).
  Future<List<KnowledgeRelation>> getBidirectionalRelations(String entityId) async {
    final outgoing = await _repository.getRelations(entityId);

    // Buscar relações inversas (onde a entidade é target)
    final incoming = await _repository.getReverseRelations(entityId);

    // Combinar sem duplicatas
    final ids = <String>{};
    final result = <KnowledgeRelation>[];
    for (final r in [...outgoing, ...incoming]) {
      if (ids.add(r.id)) {
        result.add(r);
      }
    }
    return result;
  }

  /// Obtém sugestões "Continue estudando" baseadas nas relações.
  /// Prioriza: personagens relacionados, civilizações, eventos, localizações.
  Future<List<KnowledgeRelation>> getContinueStudying(String entityId, {int limit = 5}) async {
    final relations = await getBidirectionalRelations(entityId);
    if (relations.isEmpty) return [];

    // Priorização: characters > civilizations > events > locations > artifacts > eras
    final priority = {
      EntityType.character: 0,
      EntityType.civilization: 1,
      EntityType.event: 2,
      EntityType.location: 3,
      EntityType.artifact: 4,
      EntityType.era: 5,
    };

    final sorted = List<KnowledgeRelation>.from(relations)
      ..sort((a, b) =>
          (priority[a.targetType] ?? 99).compareTo(priority[b.targetType] ?? 99));

    return sorted.take(limit).toList();
  }

  /// Obtém sugestões "Talvez você também queira estudar" (descoberta inteligente).
  /// Busca relações de segundo nível (relações das relações).
  Future<List<KnowledgeRelation>> getDiscoverySuggestions(String entityId, {int limit = 5}) async {
    final directRelations = await getBidirectionalRelations(entityId);
    final directIds = {entityId, ...directRelations.map((r) => r.targetId)};

    final suggestions = <KnowledgeRelation>[];
    final seenIds = <String>{};

    // Para cada relação direta, buscar suas relações (segundo nível)
    for (final direct in directRelations.take(5)) {
      final secondLevel = await _repository.getRelations(direct.targetId);
      for (final r in secondLevel) {
        // Não sugerir a entidade original nem relações já diretas
        if (!directIds.contains(r.targetId) && seenIds.add(r.targetId)) {
          suggestions.add(r);
          if (suggestions.length >= limit) return suggestions;
        }
      }
    }
    return suggestions;
  }

  /// Obtém cadeia cronológica de eventos.
  /// antecedentes → evento atual → consequências → eventos posteriores
  Future<EventChainData> getEventChain(String entityId) async {
    final relations = await getBidirectionalRelations(entityId);

    final before = <KnowledgeRelation>[];
    final after = <KnowledgeRelation>[];
    final during = <KnowledgeRelation>[];

    for (final r in relations) {
      switch (r.relationType) {
        case 'antecedente':
        case 'causa':
        case 'precedido_por':
          before.add(r);
          break;
        case 'consequencia':
        case 'sucedido_por':
        case 'resultado':
          after.add(r);
          break;
        case 'contemporaneo':
        case 'durante':
        case 'paralelo':
          during.add(r);
          break;
        default:
          if (r.targetType == EntityType.event) {
            during.add(r);
          }
      }
    }

    return EventChainData(
      before: before,
      during: during,
      after: after,
    );
  }

  /// Constrói breadcrumb hierárquico para uma entidade.
  /// História → Era → Civilização → Entidade
  Future<List<BreadcrumbItem>> getBreadcrumb(KnowledgeEntry entry) async {
    final items = <BreadcrumbItem>[
      const BreadcrumbItem(label: 'História', entityId: null, entityType: null),
    ];

    if (entry.periodoHistorico != null) {
      items.add(BreadcrumbItem(
        label: entry.periodoHistorico!,
        entityId: null,
        entityType: EntityType.era,
      ));
    }

    if (entry.civilizacao != null) {
      // Tentar encontrar a civilização no grafo
      final relations = await _repository.getRelations(entry.entityId);
      final civRelation = relations.where((r) => r.targetType == EntityType.civilization).toList();
      items.add(BreadcrumbItem(
        label: entry.civilizacao!,
        entityId: civRelation.isNotEmpty ? civRelation.first.targetId : null,
        entityType: EntityType.civilization,
      ));
    }

    items.add(BreadcrumbItem(
      label: entry.nome,
      entityId: entry.entityId,
      entityType: entry.entityType,
    ));

    return items;
  }

  /// Obtém localizações associadas a uma entidade (para mapa contextual).
  Future<List<MapLocationData>> getMapLocations(KnowledgeEntry entry) async {
    final locations = <MapLocationData>[];

    if (entry.localNascimento != null) {
      locations.add(MapLocationData(
        label: 'Nascimento',
        location: entry.localNascimento!,
        tipo: 'nascimento',
      ));
    }

    if (entry.localMorte != null) {
      locations.add(MapLocationData(
        label: 'Morte',
        location: entry.localMorte!,
        tipo: 'morte',
      ));
    }

    // Buscar locais relacionados
    final relations = await getBidirectionalRelations(entry.entityId);
    for (final r in relations.where((r) => r.targetType == EntityType.location)) {
      locations.add(MapLocationData(
        label: r.targetName,
        location: r.targetName,
        tipo: r.relationType,
        entityId: r.targetId,
      ));
    }

    return locations;
  }

  /// Busca agrupada por tipo de entidade.
  Future<GroupedSearchResult> searchGrouped(String query) async {
    final results = await _repository.search(query);

    final grouped = <EntityType, List<KnowledgeEntry>>{};
    for (final entry in results) {
      grouped.putIfAbsent(entry.entityType, () => []).add(entry);
    }

    return GroupedSearchResult(
      query: query,
      groups: grouped,
      totalCount: results.length,
    );
  }

  /// Obtém pessoas relacionadas a uma entidade (para card visual de relações).
  Future<List<KnowledgeRelation>> getRelatedPeople(String entityId) async {
    final relations = await getBidirectionalRelations(entityId);
    return relations.where((r) => r.targetType == EntityType.character).toList();
  }

  /// Obtém informações de uma civilização (governantes, eventos, artefatos, etc.).
  Future<CivilizationData> getCivilizationData(String civilizationId) async {
    final relations = await getBidirectionalRelations(civilizationId);

    return CivilizationData(
      governantes: relations.where((r) =>
          r.targetType == EntityType.character &&
          (r.relationType == 'governante' || r.relationType == 'lider')).toList(),
      personagens: relations.where((r) =>
          r.targetType == EntityType.character &&
          r.relationType != 'governante' && r.relationType != 'lider').toList(),
      eventos: relations.where((r) => r.targetType == EntityType.event).toList(),
      artefatos: relations.where((r) => r.targetType == EntityType.artifact).toList(),
      localizacoes: relations.where((r) => r.targetType == EntityType.location).toList(),
    );
  }
}

/// Dados de cadeia cronológica de eventos.
class EventChainData {
  final List<KnowledgeRelation> before;
  final List<KnowledgeRelation> during;
  final List<KnowledgeRelation> after;

  const EventChainData({
    this.before = const [],
    this.during = const [],
    this.after = const [],
  });

  bool get isEmpty => before.isEmpty && during.isEmpty && after.isEmpty;
}

/// Item de breadcrumb.
class BreadcrumbItem {
  final String label;
  final String? entityId;
  final EntityType? entityType;

  const BreadcrumbItem({
    required this.label,
    this.entityId,
    this.entityType,
  });
}

/// Localização para mapa contextual.
class MapLocationData {
  final String label;
  final String location;
  final String tipo;
  final String? entityId;

  const MapLocationData({
    required this.label,
    required this.location,
    required this.tipo,
    this.entityId,
  });
}

/// Resultado de busca agrupada.
class GroupedSearchResult {
  final String query;
  final Map<EntityType, List<KnowledgeEntry>> groups;
  final int totalCount;

  const GroupedSearchResult({
    required this.query,
    required this.groups,
    required this.totalCount,
  });

  bool get isEmpty => totalCount == 0;
}

/// Dados de civilização.
class CivilizationData {
  final List<KnowledgeRelation> governantes;
  final List<KnowledgeRelation> personagens;
  final List<KnowledgeRelation> eventos;
  final List<KnowledgeRelation> artefatos;
  final List<KnowledgeRelation> localizacoes;

  const CivilizationData({
    this.governantes = const [],
    this.personagens = const [],
    this.eventos = const [],
    this.artefatos = const [],
    this.localizacoes = const [],
  });
}
