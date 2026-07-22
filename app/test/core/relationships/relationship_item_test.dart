import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/relationships/relationship_item.dart';

void main() {
  group('RelatedItem', () {
    test('periodLabel formata ano a.C.', () {
      const item = RelatedItem(
        id: '1',
        slug: 'guerra',
        entityType: 'historical_event',
        title: 'Guerra Púnica',
        description: 'Conflito',
        year: -264,
        relationType: 'Evento',
        strength: 80,
      );
      expect(item.periodLabel, '264 a.C.');
    });

    test('periodLabel formata ano d.C.', () {
      const item = RelatedItem(
        id: '2',
        slug: 'roma',
        entityType: 'civilization',
        title: 'Roma',
        description: 'Império',
        year: 27,
        relationType: 'Civilização',
        strength: 95,
      );
      expect(item.periodLabel, '27 d.C.');
    });

    test('fromJson converte resposta da RPC corretamente', () {
      final json = {
        'id': '3',
        'slug': 'cleopatra',
        'entity_type': 'historical_character',
        'title': 'Cleópatra',
        'description': 'Rainha do Egito',
        'year': -69,
        'image_url': 'https://example.com/cleo.jpg',
        'color': '#D4AF37',
        'relation_type': 'Personagem Relacionado',
        'strength': 90,
      };
      final item = RelatedItem.fromJson(json);
      expect(item.title, 'Cleópatra');
      expect(item.relationStrength, RelationStrength.direct);
    });
  });

  group('RelationStrength', () {
    test('fromScore classifica direta, forte, média e fraca', () {
      expect(RelationStrength.fromScore(95), RelationStrength.direct);
      expect(RelationStrength.fromScore(75), RelationStrength.strong);
      expect(RelationStrength.fromScore(50), RelationStrength.medium);
      expect(RelationStrength.fromScore(20), RelationStrength.weak);
    });
  });
}
