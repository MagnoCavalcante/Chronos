import 'package:chronos/features/whats_new/services/whats_new_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WhatsNewService', () {
    late WhatsNewService service;

    setUp(() {
      service = WhatsNewService();
    });

    test('currentVersion não é vazio', () {
      expect(service.currentVersion, isNotEmpty);
    });

    test('currentRelease contém itens', () {
      expect(service.currentRelease.items, isNotEmpty);
    });

    test('dismiss marca como não mostrar', () async {
      await service.dismiss();
      expect(service.shouldShow, isFalse);
    });

    test('release notes contém features, improvements e fixes', () {
      final items = service.currentRelease.items;
      expect(items.any((i) => i.type.name == 'feature'), isTrue);
      expect(items.any((i) => i.type.name == 'improvement'), isTrue);
    });
  });
}
