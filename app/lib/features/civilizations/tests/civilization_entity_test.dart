import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../domain/entities/civilization.dart';

void main() {
  group('Civilization Entity Tests', () {
    test('should support value equality', () {
      const entity1 = Civilization(
        id: '1',
        slug: 'roman-empire',
        name: 'Roman Empire',
        shortName: 'Rome',
        description: 'The Roman Empire was the post-Republican period of ancient Rome.',
        summary: 'Ancient Roman civilization.',
        startYear: -27,
        endYear: 476,
        publicationStatus: PublicationStatus.published,
      );

      const entity2 = Civilization(
        id: '1',
        slug: 'roman-empire',
        name: 'Roman Empire',
        shortName: 'Rome',
        description: 'The Roman Empire was the post-Republican period of ancient Rome.',
        summary: 'Ancient Roman civilization.',
        startYear: -27,
        endYear: 476,
        publicationStatus: PublicationStatus.published,
      );

      expect(entity1, equals(entity2));
      expect(entity1.hashCode, equals(entity2.hashCode));
    });
  });
}
