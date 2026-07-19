import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../domain/entities/historical_character.dart';

void main() {
  group('HistoricalCharacter Entity Tests', () {
    final now = DateTime.now();

    test('should support copyWith', () {
      final entity = HistoricalCharacter(
        id: '1',
        slug: 'slug',
        nome: 'Nome',
        descricao: 'Descricao',
        descricaoResumida: 'Descricao Resumida',
        dataNascimento: now,
        eraId: 'era-123',
        sexo: 'masculino',
        publicationStatus: PublicationStatus.published,
        ativo: true,
        createdAt: now,
        updatedAt: now,
      );

      final updated = entity.copyWith(nome: 'Novo Nome');

      expect(updated.nome, 'Novo Nome');
      expect(updated.id, '1');
    });

    test('should support value equality', () {
      final entity1 = HistoricalCharacter(
        id: '1',
        slug: 'slug',
        nome: 'Nome',
        descricao: 'Descricao',
        descricaoResumida: 'Descricao Resumida',
        dataNascimento: now,
        eraId: 'era-123',
        sexo: 'masculino',
        publicationStatus: PublicationStatus.published,
        ativo: true,
        createdAt: now,
        updatedAt: now,
      );

      final entity2 = HistoricalCharacter(
        id: '1',
        slug: 'slug',
        nome: 'Nome',
        descricao: 'Descricao',
        descricaoResumida: 'Descricao Resumida',
        dataNascimento: now,
        eraId: 'era-123',
        sexo: 'masculino',
        publicationStatus: PublicationStatus.published,
        ativo: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(entity1, equals(entity2));
    });
  });
}
