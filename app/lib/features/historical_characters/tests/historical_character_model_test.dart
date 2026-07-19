import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../data/models/historical_character_model.dart';
import '../domain/entities/historical_character.dart';

void main() {
  group('HistoricalCharacterModel Tests', () {
    final now = DateTime.now();

    final jsonSample = {
      'id': '123',
      'slug': 'test-slug',
      'nome': 'Test Name',
      'nome_original': 'Original Name',
      'nome_alternativo': 'Alternative Name',
      'titulo': 'Emperor',
      'epiteto': 'The Great',
      'descricao': 'Test Description',
      'descricao_resumida': 'Short Description',
      'data_nascimento': now.toIso8601String(),
      'data_morte': now.toIso8601String(),
      'era_id': 'era-123',
      'local_nascimento_id': 'loc-1',
      'local_morte_id': 'loc-2',
      'sexo': 'masculino',
      'ocupacao_principal': 'ruler',
      'civilizacao_principal_id': 'civ-1',
      'imagem_principal': 'img.png',
      'cor_identificacao': '#ff0000',
      'publication_status': 'published',
      'ativo': true,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('should create model from json', () {
      final model = HistoricalCharacterModel.fromJson(jsonSample);

      expect(model.id, '123');
      expect(model.nome, 'Test Name');
      expect(model.publicationStatus, PublicationStatus.published);
    });

    test('should convert model to json', () {
      final model = HistoricalCharacterModel(
        id: '123',
        slug: 'test-slug',
        nome: 'Test Name',
        nomeOriginal: 'Original Name',
        nomeAlternativo: 'Alternative Name',
        titulo: 'Emperor',
        epiteto: 'The Great',
        descricao: 'Test Description',
        descricaoResumida: 'Short Description',
        dataNascimento: now,
        dataMorte: now,
        eraId: 'era-123',
        localNascimentoId: 'loc-1',
        localMorteId: 'loc-2',
        sexo: 'masculino',
        ocupacaoPrincipal: 'ruler',
        civilizacaoPrincipalId: 'civ-1',
        imagemPrincipal: 'img.png',
        corIdentificacao: '#ff0000',
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
      final entity = HistoricalCharacter(
        id: '123',
        slug: 'test-slug',
        nome: 'Test Name',
        nomeOriginal: 'Original Name',
        nomeAlternativo: 'Alternative Name',
        titulo: 'Emperor',
        epiteto: 'The Great',
        descricao: 'Test Description',
        descricaoResumida: 'Short Description',
        dataNascimento: now,
        dataMorte: now,
        eraId: 'era-123',
        localNascimentoId: 'loc-1',
        localMorteId: 'loc-2',
        sexo: 'masculino',
        ocupacaoPrincipal: 'ruler',
        civilizacaoPrincipalId: 'civ-1',
        imagemPrincipal: 'img.png',
        corIdentificacao: '#ff0000',
        publicationStatus: PublicationStatus.published,
        ativo: true,
        createdAt: now,
        updatedAt: now,
      );

      final model = HistoricalCharacterModel.fromEntity(entity);

      expect(model.id, '123');
      expect(model.nome, 'Test Name');
    });
  });
}
