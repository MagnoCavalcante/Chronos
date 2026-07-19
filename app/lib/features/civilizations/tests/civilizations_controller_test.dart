import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../presentation/controllers/civilizations_controller.dart';
import '../domain/entities/civilization.dart';
import '../domain/usecases/get_civilizations_usecase.dart';
import '../domain/repositories/civilization_repository.dart';

class FakeCivilizationRepository implements CivilizationRepository {
  final Result<List<Civilization>> result;

  FakeCivilizationRepository(this.result);

  @override
  Future<Result<List<Civilization>>> getAllCivilizations() async {
    return result;
  }
}

void main() {
  group('CivilizationsController Tests', () {
    final now = DateTime.now();
    final entitySample = Civilization(
      id: '1',
      slug: 'slug',
      nome: 'Nome',
      descricao: 'Desc',
      publicationStatus: PublicationStatus.published,
      ativo: true,
      createdAt: now,
      updatedAt: now,
    );

    test('should load items successfully', () async {
      final fakeRepo = FakeCivilizationRepository(Result.success([entitySample]));
      final useCase = GetCivilizationsUseCase(repository: fakeRepo);
      final controller = CivilizationsController(useCase: useCase);

      await controller.loadCivilizations();

      expect(controller.isLoading, false);
      expect(controller.items.length, 1);
      expect(controller.hasError, false);
    });

    test('should handle failures correctly', () async {
      final fakeRepo = FakeCivilizationRepository(
        const Result.failure(DatabaseFailure('Error loading data')),
      );
      final useCase = GetCivilizationsUseCase(repository: fakeRepo);
      final controller = CivilizationsController(useCase: useCase);

      await controller.loadCivilizations();

      expect(controller.isLoading, false);
      expect(controller.hasError, true);
      expect(controller.failure?.message, 'Error loading data');
    });
  });
}
