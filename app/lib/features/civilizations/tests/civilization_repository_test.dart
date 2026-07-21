import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../data/models/civilization_model.dart';
import '../data/repositories/civilization_repository_impl.dart';
import '../data/datasources/civilization_remote_datasource.dart';

class FakeCivilizationRemoteDataSource implements CivilizationRemoteDataSource {
  final List<CivilizationModel> items;
  final bool shouldThrow;

  FakeCivilizationRemoteDataSource({required this.items, this.shouldThrow = false});

  @override
  Future<List<CivilizationModel>> getAllCivilizations() async {
    if (shouldThrow) {
      throw const CivilizationDataSourceException(
        message: 'Database error',
        type: CivilizationDataSourceErrorType.database,
      );
    }
    return items;
  }

  @override
  Future<CivilizationModel> getById(String id) async {
    if (shouldThrow) {
      throw const CivilizationDataSourceException(
        message: 'Database error',
        type: CivilizationDataSourceErrorType.database,
      );
    }
    return items.firstWhere((item) => item.id == id);
  }

  @override
  Future<CivilizationModel> getBySlug(String slug) async {
    if (shouldThrow) {
      throw const CivilizationDataSourceException(
        message: 'Database error',
        type: CivilizationDataSourceErrorType.database,
      );
    }
    return items.firstWhere((item) => item.slug == slug);
  }
}

void main() {
  group('CivilizationRepositoryImpl Tests', () {
    const modelSample = CivilizationModel(
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

    test('should return success result on valid data source load', () async {
      final fakeDataSource = FakeCivilizationRemoteDataSource(items: [modelSample]);
      final repo = CivilizationRepositoryImpl(remoteDataSource: fakeDataSource);

      final result = await repo.getAllPublished();

      expect(result.isSuccess, true);
      expect(result.valueOrNull?.length, 1);
    });

    test('should return failure result on data source exception', () async {
      final fakeDataSource = FakeCivilizationRemoteDataSource(items: [], shouldThrow: true);
      final repo = CivilizationRepositoryImpl(remoteDataSource: fakeDataSource);

      final result = await repo.getAllPublished();

      expect(result.isFailure, true);
      expect(result.failureOrNull?.message, 'Database error');
    });
  });
}
