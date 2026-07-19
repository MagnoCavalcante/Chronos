import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../data/models/civilization_model.dart';
import '../domain/entities/civilization.dart';

void main() {
  group('CivilizationModel Tests', () {
    final now = DateTime.now();

    final jsonSample = {
      'id': '123',
      'slug': 'test-slug',
      'name': 'Test Name',
      'short_name': 'TN',
      'description': 'Test Description',
      'summary': 'Test Summary',
      'publication_status': 'published',
      'active': true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('should create model from json', () {
      final model = CivilizationModel.fromJson(jsonSample);

      expect(model.id, '123');
      expect(model.name, 'Test Name');
      expect(model.publicationStatus, PublicationStatus.published);
    });

    test('should convert model to json', () {
      final model = CivilizationModel(
        id: '123',
        slug: 'test-slug',
        name: 'Test Name',
        shortName: 'TN',
        description: 'Test Description',
        summary: 'Test Summary',
        publicationStatus: PublicationStatus.published,
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Test Name');
    });

    test('should support conversion from entity', () {
      final entity = Civilization(
        id: '123',
        slug: 'test-slug',
        name: 'Test Name',
        shortName: 'TN',
        description: 'Test Description',
        summary: 'Test Summary',
        publicationStatus: PublicationStatus.published,
        active: true,
        createdAt: now,
        updatedAt: now,
      );

      final model = CivilizationModel.fromEntity(entity);

      expect(model.id, '123');
      expect(model.name, 'Test Name');
    });
  });
}
