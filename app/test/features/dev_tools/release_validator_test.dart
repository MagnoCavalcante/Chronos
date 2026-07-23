import 'package:chronos/features/dev_tools/services/release_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReleaseValidator', () {
    late ReleaseValidator validator;

    setUp(() {
      validator = ReleaseValidator();
    });

    test('report aprovado quando todos os checks passam', () {
      final report = validator.validate(
        analyzeClean: true,
        testsPass: true,
        noCriticalWarnings: true,
        noOrphanScreens: true,
        noBrokenRoutes: true,
        noPlaceholders: true,
        noMissingAssets: true,
        androidBuildOk: true,
        iosPrepared: true,
      );
      expect(report.isApproved, isTrue);
      expect(report.score, 100.0);
      expect(report.passedCount, 9);
    });

    test('report reprovado quando algum check falha', () {
      final report = validator.validate(
        analyzeClean: true,
        testsPass: false,
        noCriticalWarnings: true,
        noOrphanScreens: true,
        noBrokenRoutes: true,
        noPlaceholders: true,
        noMissingAssets: true,
        androidBuildOk: true,
        iosPrepared: true,
      );
      expect(report.isApproved, isFalse);
      expect(report.failedCount, 1);
    });

    test('generateMarkdown gera relatório legível', () {
      final report = validator.validate(
        analyzeClean: true,
        testsPass: true,
        noCriticalWarnings: true,
        noOrphanScreens: true,
        noBrokenRoutes: true,
        noPlaceholders: true,
        noMissingAssets: true,
        androidBuildOk: true,
        iosPrepared: true,
      );
      final md = validator.generateMarkdown(report);
      expect(md, contains('APROVADO'));
      expect(md, contains('100.0%'));
      expect(md, contains('9/9'));
    });

    test('report contém versão correta', () {
      final report = validator.validate(
        analyzeClean: true,
        testsPass: true,
        noCriticalWarnings: true,
        noOrphanScreens: true,
        noBrokenRoutes: true,
        noPlaceholders: true,
        noMissingAssets: true,
        androidBuildOk: true,
        iosPrepared: true,
      );
      expect(report.version, '1.0.0');
    });
  });
}
