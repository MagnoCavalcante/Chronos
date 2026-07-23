import 'package:chronos/features/export/data/services/signature_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignatureService', () {
    late SignatureService service;

    setUp(() {
      service = SignatureService();
    });

    test('gera assinatura com nome do app', () {
      final sig = service.generate();
      expect(sig.appName, 'CHRONOS');
    });

    test('gera assinatura com versão', () {
      final sig = service.generate();
      expect(sig.version, isNotEmpty);
    });

    test('gera assinatura com data atual', () {
      final sig = service.generate();
      final now = DateTime.now();
      expect(sig.exportDate.day, now.day);
      expect(sig.exportDate.month, now.month);
      expect(sig.exportDate.year, now.year);
    });

    test('gera QR data com formato correto', () {
      final sig = service.generate();
      expect(sig.qrCodeData, startsWith('chronos://export'));
      expect(sig.qrCodeData, contains('app=CHRONOS'));
    });

    test('inclui copyright e URL', () {
      final sig = service.generate();
      expect(sig.copyright, contains('CHRONOS'));
      expect(sig.chronosUrl, contains('chronos.app'));
    });
  });
}
