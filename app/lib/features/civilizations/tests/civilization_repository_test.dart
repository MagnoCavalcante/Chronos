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
}

void main() {
  group('CivilizationRepositoryImpl Tests', () {
    final now = DateTime.now();
    final modelSample = CivilizationModel(
      id: '1',
      slug: 'slug',
      nome: 'Nome',
      descricao: 'Desc',
      publicationStatus: PublicationStatus.published,
      ativo: true,
      createdAt: now,
      updatedAt: now,
    );

    test('should return success result on valid data source load', () async {
      final fakeDataSource = FakeCivilizationRemoteDataSource(items: [modelSample]);
      final repo = CivilizationRepositoryImpl(remoteDataSource: fakeDataSource);

      final result = await repo.getAllCivilizations();

      expect(result.isSuccess, true);
      expect(result.valueOrNull?.length, 1);
    });

    test('should return failure result on data source exception', () async {
      final fakeDataSource = FakeCivilizationRemoteDataSource(items: [], shouldThrow: true);
      final repo = CivilizationRepositoryImpl(remoteDataSource: fakeDataSource);

      final result = await repo.getAllCivilizations();

      expect(result.isFailure, true);
      expect(result.failureOrNull?.message, 'Database error');
    });
  });
}
