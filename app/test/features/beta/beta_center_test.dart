import 'package:chronos/features/beta/services/beta_center_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BetaCenterService', () {
    late BetaCenterService service;

    setUp(() {
      service = BetaCenterService();
    });

    test('isBetaMode retorna true para versão beta', () {
      expect(service.isBetaMode, isTrue);
    });

    test('version retorna versão correta', () {
      expect(service.version, '1.0.0-beta.1');
    });

    test('buildNumber retorna 2', () {
      expect(service.buildNumber, 2);
    });

    test('info contém dados válidos', () {
      final info = service.info;
      expect(info.version, '1.0.0-beta.1');
      expect(info.buildNumber, 2);
      expect(info.isBetaMode, isTrue);
    });

    test('checkStatus executa sem crash', () async {
      await service.checkStatus();
      // Em ambiente de teste sem SharedPreferences mockado, cai no catch → offline
      expect(service.info.apiStatus, isNotNull);
    });
  });
}
