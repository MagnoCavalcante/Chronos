import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../domain/entities/civilization.dart';

void main() {
  group('Civilization Entity Tests', () {
    final now = DateTime.now();

    test('should support copyWith', () {
      final entity = Civilization(
        id: '1',
        slug: 'slug',
        name: 'Nome',
        shortName: 'N',
        description: 'Descricao',
        summary: 'Resumo',
        publicationStatus: PublicationStatus.published,
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      final updated = entity.copyWith(name: 'Novo Nome');

      expect(updated.name, 'Novo Nome');
      expect(updated.id, '1');
    });

    test('should support value equality', () {
      final entity1 = Civilization(
        id: '1',
        slug: 'slug',
        name: 'Nome',
        shortName: 'N',
        description: 'Descricao',
        summary: 'Resumo',
        publicationStatus: PublicationStatus.published,
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      final entity2 = Civilization(
        id: '1',
        slug: 'slug',
        name: 'Nome',
        shortName: 'N',
        description: 'Descricao',
        summary: 'Resumo',
        publicationStatus: PublicationStatus.published,
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(entity1, equals(entity2));
    });
  });
}
