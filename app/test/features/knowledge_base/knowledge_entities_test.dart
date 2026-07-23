import 'package:chronos/features/knowledge_base/domain/entities/knowledge_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KnowledgeEntry', () {
    test('fromJson cria entry válida', () {
      final json = {
        'entity_id': 'char_cleopatra',
        'entity_type': 'character',
        'nome': 'Cleópatra VII',
        'nome_original': 'Κλεοπάτρα',
        'periodo_historico': '69 a.C. – 30 a.C.',
        'civilizacao': 'Egito Ptolemaico',
        'resumo': 'Última faraó do Egito.',
        'conteudo_completo': 'Biografia completa...',
        'principais_feitos': [
          {'id': 'f1', 'conteudo': 'Manteve independência', 'confiabilidade': 'fact', 'source_ids': []},
        ],
        'fontes': [
          {'id': 's1', 'autor': 'Plutarco', 'titulo': 'Vidas Paralelas', 'confiabilidade': 'fact'},
        ],
        'debates': [
          {'id': 'd1', 'titulo': 'Causa da morte', 'descricao': 'Como morreu?', 'posicoes': ['Cobra', 'Veneno'], 'status_atual': 'disputed'},
        ],
        'curiosidades': [
          {'id': 'c1', 'titulo': 'Não era egípcia', 'conteudo': 'Era macedônia.', 'tipo': 'curiosidade', 'confiabilidade': 'fact'},
        ],
        'relacoes': [
          {'id': 'r1', 'target_id': 'char_cesar', 'target_type': 'character', 'target_name': 'Júlio César', 'relation_type': 'aliado'},
        ],
        'linha_do_tempo': [
          {'id': 'tl1', 'ano': -69, 'titulo': 'Nascimento', 'confiabilidade': 'fact'},
        ],
        'consenso': {'resumo': 'Líder competente.', 'nivel': 'fact', 'source_ids': []},
      };

      final entry = KnowledgeEntry.fromJson(json);
      expect(entry.entityId, 'char_cleopatra');
      expect(entry.entityType, EntityType.character);
      expect(entry.nome, 'Cleópatra VII');
      expect(entry.nomeOriginal, 'Κλεοπάτρα');
      expect(entry.resumo, 'Última faraó do Egito.');
      expect(entry.principaisFeitos, hasLength(1));
      expect(entry.fontes, hasLength(1));
      expect(entry.debates, hasLength(1));
      expect(entry.curiosidades, hasLength(1));
      expect(entry.relacoes, hasLength(1));
      expect(entry.linhaDoTempo, hasLength(1));
      expect(entry.consenso, isNotNull);
    });

    test('toJson e fromJson são simétricos', () {
      final entry = KnowledgeEntry(
        entityId: 'test_1',
        entityType: EntityType.event,
        nome: 'Evento Teste',
        resumo: 'Um resumo.',
        fontes: [
          HistoricalSource(id: 's1', autor: 'Autor', titulo: 'Livro'),
        ],
      );

      final json = entry.toJson();
      final restored = KnowledgeEntry.fromJson(json);
      expect(restored.entityId, entry.entityId);
      expect(restored.entityType, entry.entityType);
      expect(restored.nome, entry.nome);
      expect(restored.fontes.first.autor, 'Autor');
    });
  });

  group('ReliabilityLevel', () {
    test('todos os níveis estão definidos', () {
      expect(ReliabilityLevel.values, hasLength(4));
      expect(ReliabilityLevel.fact.name, 'fact');
      expect(ReliabilityLevel.theory.name, 'theory');
      expect(ReliabilityLevel.hypothesis.name, 'hypothesis');
      expect(ReliabilityLevel.disputed.name, 'disputed');
    });
  });

  group('HistoricalSource', () {
    test('fromJson parseia corretamente', () {
      final json = {
        'id': 'src_1',
        'autor': 'Plutarco',
        'titulo': 'Vidas Paralelas',
        'livro': 'Vidas Paralelas',
        'ano_publicacao': 75,
        'confiabilidade': 'fact',
      };
      final source = HistoricalSource.fromJson(json);
      expect(source.autor, 'Plutarco');
      expect(source.livro, 'Vidas Paralelas');
      expect(source.anoPublicacao, 75);
      expect(source.confiabilidade, ReliabilityLevel.fact);
    });
  });

  group('HistoricalDebate', () {
    test('fromJson parseia posições', () {
      final json = {
        'id': 'deb_1',
        'titulo': 'Morte de Alexandre',
        'descricao': 'Causa debatida.',
        'posicoes': ['Febre tifoide', 'Envenenamento'],
        'status_atual': 'disputed',
      };
      final debate = HistoricalDebate.fromJson(json);
      expect(debate.posicoes, hasLength(2));
      expect(debate.statusAtual, ReliabilityLevel.disputed);
    });
  });

  group('KnowledgeRelation', () {
    test('fromJson parseia tipo de entidade', () {
      final json = {
        'id': 'rel_1',
        'target_id': 'civ_roma',
        'target_type': 'civilization',
        'target_name': 'Império Romano',
        'relation_type': 'governante',
      };
      final rel = KnowledgeRelation.fromJson(json);
      expect(rel.targetType, EntityType.civilization);
      expect(rel.targetName, 'Império Romano');
    });
  });

  group('TimelineEntry', () {
    test('anos negativos representam a.C.', () {
      final entry = TimelineEntry(id: 'tl1', ano: -69, titulo: 'Nascimento');
      expect(entry.ano, -69);
    });
  });

  group('EntityType', () {
    test('todos os tipos estão definidos', () {
      expect(EntityType.values, hasLength(6));
    });
  });
}
