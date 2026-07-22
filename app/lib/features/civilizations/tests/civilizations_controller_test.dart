import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/core/errors/failure.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../presentation/controllers/civilizations_controller.dart';
import 'package:chronos/domain/entities/civilization.dart';
import '../domain/usecases/get_all_civilizations.dart';
import '../domain/repositories/civilization_repository.dart';

class FakeCivilizationRepository extends CivilizationRepository {
  final Result<List<Civilization>> result;

  FakeCivilizationRepository(this.result);

  @override
  Future<Result<List<Civilization>>> getAllPublished() async {
    return result;
  }

  @override
  Future<Result<Civilization>> getById(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<Civilization>> getBySlug(String slug) async {
    throw UnimplementedError();
  }
}

void main() {
  group('CivilizationsController Tests', () {
    const entitySample = Civilization(
      id: '1',
      slug: 'slug',
      name: 'Nome',
      shortName: 'Short',
      description: 'Desc',
      summary: 'Summ',
      startYear: 100,
      endYear: 200,
      publicationStatus: PublicationStatus.published,
    );

    test('should load items successfully', () async {
      final fakeRepo = FakeCivilizationRepository(Result.success([entitySample]));
      final useCase = GetAllCivilizations(fakeRepo);
      final controller = CivilizationsController(getAllCivilizations: useCase);

      await controller.loadCivilizations();

      expect(controller.isLoading, false);
      expect(controller.items.length, 1);
      expect(controller.hasError, false);
    });

    test('should handle failures correctly', () async {
      final fakeRepo = FakeCivilizationRepository(
        const Result.failure(DatabaseFailure('Error loading data')),
      );
      final useCase = GetAllCivilizations(fakeRepo);
      final controller = CivilizationsController(getAllCivilizations: useCase);

      await controller.loadCivilizations();

      expect(controller.isLoading, false);
      expect(controller.hasError, true);
      expect(controller.failure?.message, 'Error loading data');
    });
  });
}
