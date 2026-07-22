import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../presentation/controllers/historical_characters_controller.dart';
import '../domain/entities/historical_character.dart';
import '../domain/usecases/get_all_historical_characters.dart';
import '../domain/usecases/get_historical_character_by_id.dart';
import '../domain/usecases/get_historical_character_by_slug.dart';
import '../domain/repositories/historical_character_repository.dart';

class FakeHistoricalCharacterRepository implements HistoricalCharacterRepository {
  final Result<List<HistoricalCharacter>> result;

  FakeHistoricalCharacterRepository(this.result);

  @override
  Future<Result<List<HistoricalCharacter>>> getAllCharacters() async {
    return result;
  }

  @override
  Future<Result<HistoricalCharacter>> getCharacterById(String id) async {
    return result.fold(
      onSuccess: (data) => Result.success(data.firstWhere((char) => char.id == id)),
      onFailure: (fail) => Result.failure(fail),
    );
  }

  @override
  Future<Result<HistoricalCharacter>> getCharacterBySlug(String slug) async {
    return result.fold(
      onSuccess: (data) => Result.success(data.firstWhere((char) => char.slug == slug)),
      onFailure: (fail) => Result.failure(fail),
    );
  }
}

void main() {
  group('HistoricalCharactersController Tests', () {
    final now = DateTime.now();
    final entitySample = HistoricalCharacter(
      id: '1',
      slug: 'slug',
      nome: 'Nome',
      descricao: 'Desc',
      descricaoResumida: 'Resumo',
      dataNascimento: DateTime(1900),
      eraId: 'era-1',
      sexo: 'não informado',
      publicationStatus: PublicationStatus.published,
      ativo: true,
      createdAt: now,
      updatedAt: now,
    );

    test('should load items successfully', () async {
      final fakeRepo = FakeHistoricalCharacterRepository(Result.success([entitySample]));
      final useCase = GetAllHistoricalCharacters(repository: fakeRepo);
      final controller = HistoricalCharactersController(
        useCase: useCase,
        getByIdUseCase: GetHistoricalCharacterById(repository: fakeRepo),
        getBySlugUseCase: GetHistoricalCharacterBySlug(repository: fakeRepo),
      );

      await controller.loadHistoricalCharacters();

      expect(controller.isLoading, false);
      expect(controller.items.length, 1);
      expect(controller.hasError, false);
    });

    test('should handle failures correctly', () async {
      final fakeRepo = FakeHistoricalCharacterRepository(
        const Result.failure(DatabaseFailure('Error loading data')),
      );
      final useCase = GetAllHistoricalCharacters(repository: fakeRepo);
      final controller = HistoricalCharactersController(
        useCase: useCase,
        getByIdUseCase: GetHistoricalCharacterById(repository: fakeRepo),
        getBySlugUseCase: GetHistoricalCharacterBySlug(repository: fakeRepo),
      );

      await controller.loadHistoricalCharacters();

      expect(controller.isLoading, false);
      expect(controller.hasError, true);
      expect(controller.failure?.message, 'Error loading data');
    });
  });
}
