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
      'nome': 'Test Name',
      'descricao': 'Test Description',
      'publication_status': 'published',
      'ativo': true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('should create model from json', () {
      final model = CivilizationModel.fromJson(jsonSample);

      expect(model.id, '123');
      expect(model.nome, 'Test Name');
      expect(model.publicationStatus, PublicationStatus.published);
    });

    test('should convert model to json', () {
      final model = CivilizationModel(
        id: '123',
        slug: 'test-slug',
        nome: 'Test Name',
        descricao: 'Test Description',
        publicationStatus: PublicationStatus.published,
        ativo: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['nome'], 'Test Name');
    });

    test('should support conversion from entity', () {
      final entity = Civilization(
        id: '123',
        slug: 'test-slug',
        nome: 'Test Name',
        descricao: 'Test Description',
        publicationStatus: PublicationStatus.published,
        ativo: true,
        createdAt: now,
        updatedAt: now,
      );

      final model = CivilizationModel.fromEntity(entity);

      expect(model.id, '123');
      expect(model.nome, 'Test Name');
    });
  });
}
