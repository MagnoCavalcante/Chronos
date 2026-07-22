import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../data/models/civilization_model.dart';
import '../domain/entities/civilization.dart';

void main() {
  group('CivilizationModel Tests', () {
    final jsonSample = {
      'id': '123',
      'slug': 'test-slug',
      'name': 'Test Name',
      'short_name': 'Test Short Name',
      'description': 'Test Description',
      'summary': 'Test Summary',
      'start_year': -3000,
      'end_year': -146,
      'publication_status': 'published',
    };

    test('should create model from json', () {
      final model = CivilizationModel.fromJson(jsonSample);

      expect(model.id, '123');
      expect(model.name, 'Test Name');
      expect(model.shortName, 'Test Short Name');
      expect(model.description, 'Test Description');
      expect(model.summary, 'Test Summary');
      expect(model.startYear, -3000);
      expect(model.endYear, -146);
      expect(model.publicationStatus, PublicationStatus.published);
    });

    test('should convert model to json', () {
      const model = CivilizationModel(
        id: '123',
        slug: 'test-slug',
        name: 'Test Name',
        shortName: 'Test Short Name',
        description: 'Test Description',
        summary: 'Test Summary',
        startYear: -3000,
        endYear: -146,
        publicationStatus: PublicationStatus.published,
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Test Name');
      expect(json['short_name'], 'Test Short Name');
      expect(json['start_year'], -3000);
    });

    test('should support conversion from entity', () {
      const entity = Civilization(
        id: '123',
        slug: 'test-slug',
        name: 'Test Name',
        shortName: 'Test Short Name',
        description: 'Test Description',
        summary: 'Test Summary',
        startYear: -3000,
        endYear: -146,
        publicationStatus: PublicationStatus.published,
      );

      final model = CivilizationModel.fromEntity(entity);

      expect(model.id, '123');
      expect(model.name, 'Test Name');
    });
  });
}
