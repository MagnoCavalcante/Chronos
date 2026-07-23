import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chronos/presentation/controllers/collections_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('CollectionsController', () {
    test('estado inicial é idle', () {
      final controller = CollectionsController();
      expect(controller.status, CollectionsStatus.idle);
      expect(controller.collections, isEmpty);
    });

    test('load carrega coleções e altera status', () async {
      final controller = CollectionsController();
      final future = controller.load();
      expect(controller.status, CollectionsStatus.loading);
      await future;
      expect(controller.status, CollectionsStatus.loaded);
    });

    test('create sem cliente retorna false sem quebrar', () async {
      final controller = CollectionsController();
      final result = await controller.create('Teste');
      expect(result, isFalse);
    });
  });
}
