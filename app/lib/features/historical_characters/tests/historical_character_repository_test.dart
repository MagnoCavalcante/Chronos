import 'package:flutter_test/flutter_test.dart';
import 'package:chronos/core/utils/result.dart';
import 'package:chronos/domain/entities/publication_status.dart';
import '../data/models/historical_character_model.dart';
import '../data/repositories/historical_character_repository_impl.dart';
import '../data/datasources/historical_character_remote_datasource.dart';

class FakeHistoricalCharacterRemoteDataSource implements HistoricalCharacterRemoteDataSource {
  final List<HistoricalCharacterModel> items;
  final bool shouldThrow;

  FakeHistoricalCharacterRemoteDataSource({required this.items, this.shouldThrow = false});

  @override
  Future<List<HistoricalCharacterModel>> getAllCharacters() async {
    if (shouldThrow) {
      throw const HistoricalCharacterDataSourceException(
        message: 'Database error',
        type: HistoricalCharacterDataSourceErrorType.database,
      );
    }
    return items;
  }

  @override
  Future<HistoricalCharacterModel> getCharacterById(String id) async {
    if (shouldThrow) {
      throw const HistoricalCharacterDataSourceException(
        message: 'Database error',
        type: HistoricalCharacterDataSourceErrorType.database,
      );
    }
    return items.firstWhere(
      (item) => item.id == id,
      orElse: () => throw const HistoricalCharacterDataSourceException.emptyResponse('Not found'),
    );
  }

  @override
  Future<HistoricalCharacterModel> getCharacterBySlug(String slug) async {
    if (shouldThrow) {
      throw const HistoricalCharacterDataSourceException(
        message: 'Database error',
        type: HistoricalCharacterDataSourceErrorType.database,
      );
    }
    return items.firstWhere(
      (item) => item.slug == slug,
      orElse: () => throw const HistoricalCharacterDataSourceException.emptyResponse('Not found'),
    );
  }
}

void main() {
  group('HistoricalCharacterRepositoryImpl Tests', () {
    final now = DateTime.now();
    final modelSample = HistoricalCharacterModel(
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
      final fakeDataSource = FakeHistoricalCharacterRemoteDataSource(items: [modelSample]);
      final repo = HistoricalCharacterRepositoryImpl(remoteDataSource: fakeDataSource);

      final result = await repo.getAllCharacters();

      expect(result.isSuccess, true);
      expect(result.valueOrNull?.length, 1);
    });

    test('should return failure result on data source exception', () async {
      final fakeDataSource = FakeHistoricalCharacterRemoteDataSource(items: [], shouldThrow: true);
      final repo = HistoricalCharacterRepositoryImpl(remoteDataSource: fakeDataSource);

      final result = await repo.getAllCharacters();

      expect(result.isFailure, true);
      expect(result.failureOrNull?.message, 'Database error');
    });

    test('should return success on getCharacterById', () async {
      final fakeDataSource = FakeHistoricalCharacterRemoteDataSource(items: [modelSample]);
      final repo = HistoricalCharacterRepositoryImpl(remoteDataSource: fakeDataSource);

      final result = await repo.getCharacterById('1');

      expect(result.isSuccess, true);
      expect(result.valueOrNull?.id, '1');
    });

    test('should return success on getCharacterBySlug', () async {
      final fakeDataSource = FakeHistoricalCharacterRemoteDataSource(items: [modelSample]);
      final repo = HistoricalCharacterRepositoryImpl(remoteDataSource: fakeDataSource);

      final result = await repo.getCharacterBySlug('slug');

      expect(result.isSuccess, true);
      expect(result.valueOrNull?.slug, 'slug');
    });
  });
}
