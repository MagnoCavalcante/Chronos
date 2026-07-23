import 'package:chronos/features/knowledge_base/domain/entities/knowledge_entities.dart';
import 'package:chronos/features/knowledge_base/domain/repositories/knowledge_repository.dart';
import 'package:chronos/features/knowledge_base/services/knowledge_graph_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock repository para testes do graph service.
class MockKnowledgeRepository implements KnowledgeRepository {
  final Map<String, List<KnowledgeRelation>> _relations = {};
  final Map<String, List<KnowledgeRelation>> _reverseRelations = {};
  final Map<String, KnowledgeEntry> _entries = {};

  void addRelation(String entityId, KnowledgeRelation relation) {
    _relations.putIfAbsent(entityId, () => []).add(relation);
  }

  void addReverseRelation(String entityId, KnowledgeRelation relation) {
    _reverseRelations.putIfAbsent(entityId, () => []).add(relation);
  }

  void addEntry(KnowledgeEntry entry) {
    _entries[entry.entityId] = entry;
  }

  @override
  Future<List<KnowledgeRelation>> getRelations(String entityId) async {
    return _relations[entityId] ?? [];
  }

  @override
  Future<List<KnowledgeRelation>> getReverseRelations(String entityId) async {
    return _reverseRelations[entityId] ?? [];
  }

  @override
  Future<KnowledgeEntry?> getEntry(String entityId, EntityType entityType) async {
    return _entries[entityId];
  }

  @override
  Future<List<HistoricalSource>> getSources(String entityId) async => [];

  @override
  Future<List<HistoricalDebate>> getDebates(String entityId) async => [];

  @override
  Future<List<HistoricalCuriosity>> getCuriosities(String entityId) async => [];

  @override
  Future<List<KnowledgeEntry>> search(String query, {EntityType? type}) async {
    return _entries.values.where((e) => e.nome.toLowerCase().contains(query.toLowerCase())).toList();
  }
}

void main() {
  group('KnowledgeGraphService', () {
    late MockKnowledgeRepository repo;
    late KnowledgeGraphService service;

    setUp(() {
      repo = MockKnowledgeRepository();
      service = KnowledgeGraphService(repository: repo);
    });

    test('getBidirectionalRelations combina outgoing e incoming', () async {
      repo.addRelation('A', const KnowledgeRelation(
        id: 'r1', targetId: 'B', targetType: EntityType.character,
        targetName: 'B', relationType: 'aliado',
      ));
      repo.addReverseRelation('A', const KnowledgeRelation(
        id: 'r2', targetId: 'C', targetType: EntityType.event,
        targetName: 'C', relationType: 'participou',
      ));

      final result = await service.getBidirectionalRelations('A');
      expect(result, hasLength(2));
    });

    test('getBidirectionalRelations remove duplicatas', () async {
      const rel = KnowledgeRelation(
        id: 'r1', targetId: 'B', targetType: EntityType.character,
        targetName: 'B', relationType: 'aliado',
      );
      repo.addRelation('A', rel);
      repo.addReverseRelation('A', rel);

      final result = await service.getBidirectionalRelations('A');
      expect(result, hasLength(1));
    });

    test('getContinueStudying prioriza personagens', () async {
      repo.addRelation('A', const KnowledgeRelation(
        id: 'r1', targetId: 'evt1', targetType: EntityType.event,
        targetName: 'Evento', relationType: 'participou',
      ));
      repo.addRelation('A', const KnowledgeRelation(
        id: 'r2', targetId: 'char1', targetType: EntityType.character,
        targetName: 'Personagem', relationType: 'aliado',
      ));

      final result = await service.getContinueStudying('A');
      expect(result.first.targetType, EntityType.character);
    });

    test('getContinueStudying respeita limite', () async {
      for (int i = 0; i < 10; i++) {
        repo.addRelation('A', KnowledgeRelation(
          id: 'r$i', targetId: 'char_$i', targetType: EntityType.character,
          targetName: 'Person $i', relationType: 'aliado',
        ));
      }

      final result = await service.getContinueStudying('A', limit: 3);
      expect(result, hasLength(3));
    });

    test('getDiscoverySuggestions retorna segundo nível', () async {
      // A → B
      repo.addRelation('A', const KnowledgeRelation(
        id: 'r1', targetId: 'B', targetType: EntityType.character,
        targetName: 'B', relationType: 'aliado',
      ));
      // B → C (segundo nível de A)
      repo.addRelation('B', const KnowledgeRelation(
        id: 'r2', targetId: 'C', targetType: EntityType.event,
        targetName: 'C', relationType: 'participou',
      ));

      final result = await service.getDiscoverySuggestions('A');
      expect(result, hasLength(1));
      expect(result.first.targetId, 'C');
    });

    test('getDiscoverySuggestions exclui relações diretas', () async {
      repo.addRelation('A', const KnowledgeRelation(
        id: 'r1', targetId: 'B', targetType: EntityType.character,
        targetName: 'B', relationType: 'aliado',
      ));
      // B → A (de volta ao original — não deve sugerir)
      repo.addRelation('B', const KnowledgeRelation(
        id: 'r2', targetId: 'A', targetType: EntityType.character,
        targetName: 'A', relationType: 'aliado',
      ));

      final result = await service.getDiscoverySuggestions('A');
      expect(result, isEmpty);
    });

    test('getEventChain categoriza relações cronológicas', () async {
      repo.addRelation('A', const KnowledgeRelation(
        id: 'r1', targetId: 'before1', targetType: EntityType.event,
        targetName: 'Antecedente', relationType: 'antecedente',
      ));
      repo.addRelation('A', const KnowledgeRelation(
        id: 'r2', targetId: 'after1', targetType: EntityType.event,
        targetName: 'Consequência', relationType: 'consequencia',
      ));
      repo.addRelation('A', const KnowledgeRelation(
        id: 'r3', targetId: 'during1', targetType: EntityType.event,
        targetName: 'Contemporâneo', relationType: 'contemporaneo',
      ));

      final chain = await service.getEventChain('A');
      expect(chain.before, hasLength(1));
      expect(chain.after, hasLength(1));
      expect(chain.during, hasLength(1));
      expect(chain.isEmpty, isFalse);
    });

    test('getEventChain retorna vazio quando sem relações', () async {
      final chain = await service.getEventChain('sem_relacoes');
      expect(chain.isEmpty, isTrue);
    });

    test('getBreadcrumb constrói hierarquia', () async {
      final entry = KnowledgeEntry(
        entityId: 'char_cleo',
        entityType: EntityType.character,
        nome: 'Cleópatra VII',
        resumo: 'Resumo.',
        periodoHistorico: 'Antiguidade',
        civilizacao: 'Egito Ptolemaico',
      );

      final breadcrumb = await service.getBreadcrumb(entry);
      expect(breadcrumb.length, greaterThanOrEqualTo(3));
      expect(breadcrumb.first.label, 'História');
      expect(breadcrumb.last.label, 'Cleópatra VII');
    });

    test('getMapLocations inclui nascimento e morte', () async {
      final entry = KnowledgeEntry(
        entityId: 'char_test',
        entityType: EntityType.character,
        nome: 'Teste',
        resumo: 'Resumo.',
        localNascimento: 'Alexandria',
        localMorte: 'Roma',
      );

      final locations = await service.getMapLocations(entry);
      expect(locations, hasLength(2));
      expect(locations[0].tipo, 'nascimento');
      expect(locations[1].tipo, 'morte');
    });

    test('getMapLocations inclui locais das relações', () async {
      final entry = KnowledgeEntry(
        entityId: 'char_test',
        entityType: EntityType.character,
        nome: 'Teste',
        resumo: 'Resumo.',
      );
      repo.addRelation('char_test', const KnowledgeRelation(
        id: 'r1', targetId: 'loc_roma', targetType: EntityType.location,
        targetName: 'Roma', relationType: 'capital',
      ));

      final locations = await service.getMapLocations(entry);
      expect(locations, hasLength(1));
      expect(locations.first.location, 'Roma');
    });

    test('searchGrouped agrupa resultados por tipo', () async {
      repo.addEntry(KnowledgeEntry(
        entityId: 'char_1', entityType: EntityType.character,
        nome: 'Roma Personagem', resumo: 'R',
      ));
      repo.addEntry(KnowledgeEntry(
        entityId: 'loc_1', entityType: EntityType.location,
        nome: 'Roma Local', resumo: 'R',
      ));

      final result = await service.searchGrouped('Roma');
      expect(result.totalCount, 2);
      expect(result.groups.keys, contains(EntityType.character));
      expect(result.groups.keys, contains(EntityType.location));
    });

    test('getRelatedPeople filtra apenas personagens', () async {
      repo.addRelation('A', const KnowledgeRelation(
        id: 'r1', targetId: 'char_1', targetType: EntityType.character,
        targetName: 'Pessoa', relationType: 'aliado',
      ));
      repo.addRelation('A', const KnowledgeRelation(
        id: 'r2', targetId: 'evt_1', targetType: EntityType.event,
        targetName: 'Evento', relationType: 'participou',
      ));

      final result = await service.getRelatedPeople('A');
      expect(result, hasLength(1));
      expect(result.first.targetType, EntityType.character);
    });

    test('getCivilizationData separa por tipo', () async {
      repo.addRelation('civ_1', const KnowledgeRelation(
        id: 'r1', targetId: 'char_1', targetType: EntityType.character,
        targetName: 'Rei', relationType: 'governante',
      ));
      repo.addRelation('civ_1', const KnowledgeRelation(
        id: 'r2', targetId: 'evt_1', targetType: EntityType.event,
        targetName: 'Batalha', relationType: 'evento',
      ));
      repo.addRelation('civ_1', const KnowledgeRelation(
        id: 'r3', targetId: 'loc_1', targetType: EntityType.location,
        targetName: 'Capital', relationType: 'capital',
      ));

      final data = await service.getCivilizationData('civ_1');
      expect(data.governantes, hasLength(1));
      expect(data.eventos, hasLength(1));
      expect(data.localizacoes, hasLength(1));
    });
  });
}
