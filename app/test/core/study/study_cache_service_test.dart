import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chronos/core/study/study_cache_service.dart';
import 'package:chronos/core/study/study_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('StudyCacheService', () {
    test('armazena e recupera coleções', () async {
      final service = StudyCacheService();
      final collections = [
        Collection(
          id: 'c1',
          userId: 'u1',
          slug: 'roma',
          title: 'Roma Antiga',
          description: null,
          coverUrl: null,
          isPublic: false,
          ativo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      await service.cacheCollections(collections);
      final cached = await service.getCollections();
      expect(cached.length, 1);
      expect(cached.first.title, 'Roma Antiga');
    });

    test('registra última sincronização', () async {
      final service = StudyCacheService();
      await service.cacheCollections([]);
      final lastSync = await service.getLastSync();
      expect(lastSync, isNotNull);
    });

    test('limpa cache corretamente', () async {
      final service = StudyCacheService();
      await service.cacheCollections([
        Collection(
          id: 'c1',
          userId: 'u1',
          slug: 'roma',
          title: 'Roma',
          description: null,
          coverUrl: null,
          isPublic: false,
          ativo: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);
      await service.clear();
      final cached = await service.getCollections();
      expect(cached, isEmpty);
    });
  });
}
