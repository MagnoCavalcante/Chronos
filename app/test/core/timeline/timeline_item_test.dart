import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/timeline/timeline_item.dart';

void main() {
  group('TimelineDisplayItem', () {
    test('periodLabel formata anos antes de Cristo', () {
      const item = TimelineDisplayItem(
        id: '1',
        slug: 'guerra-punica',
        entityType: 'historical_event',
        title: 'Guerra Púnica',
        description: 'Conflito entre Roma e Cartago',
        year: -264,
      );
      expect(item.periodLabel, '264 a.C.');
    });

    test('periodLabel formata anos depois de Cristo', () {
      const item = TimelineDisplayItem(
        id: '2',
        slug: 'roma',
        entityType: 'civilization',
        title: 'Roma Antiga',
        description: 'Civilização da Antiguidade',
        year: 753,
      );
      expect(item.periodLabel, '753 d.C.');
    });

    test('fromJson converte resposta do Supabase corretamente', () {
      final json = {
        'id': '3',
        'slug': 'alejandro',
        'entity_type': 'historical_character',
        'title': 'Alexandre, o Grande',
        'description': 'Conquistador macedônico',
        'year': -356,
        'image_url': 'https://example.com/image.jpg',
        'color': '#0000FF',
      };
      final item = TimelineDisplayItem.fromJson(json);
      expect(item.title, 'Alexandre, o Grande');
      expect(item.year, -356);
      expect(item.type, TimelineItemType.historicalCharacter);
    });
  });

  group('TimelineItemType', () {
    test('fromString mapeia tipos conhecidos', () {
      expect(TimelineItemType.fromString('artifact'), TimelineItemType.artifact);
      expect(TimelineItemType.fromString('historical_location'), TimelineItemType.historicalLocation);
    });

    test('fromString retorna all para tipo desconhecido', () {
      expect(TimelineItemType.fromString('unknown'), TimelineItemType.all);
    });
  });
}
