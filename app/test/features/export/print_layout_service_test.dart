import 'package:chronos/features/export/data/services/print_layout_service.dart';
import 'package:chronos/features/export/domain/entities/export_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PrintLayoutService', () {
    late PrintLayoutService service;

    setUp(() {
      service = PrintLayoutService();
    });

    test('A4 retrato tem dimensões corretas', () {
      const layout = PrintLayout(pageSize: PageSize.a4, orientation: PageOrientation.portrait);
      final dims = service.getEffectiveDimensions(layout);
      expect(dims.widthMm, 210);
      expect(dims.heightMm, 297);
    });

    test('A4 paisagem inverte dimensões', () {
      const layout = PrintLayout(pageSize: PageSize.a4, orientation: PageOrientation.landscape);
      final dims = service.getEffectiveDimensions(layout);
      expect(dims.widthMm, 297);
      expect(dims.heightMm, 210);
    });

    test('Carta retrato tem dimensões corretas', () {
      const layout = PrintLayout(pageSize: PageSize.letter, orientation: PageOrientation.portrait);
      final dims = service.getEffectiveDimensions(layout);
      expect(dims.widthMm, 216);
      expect(dims.heightMm, 279);
    });

    test('content dimensions descontam margens', () {
      const layout = PrintLayout(pageSize: PageSize.a4, marginMm: 20.0);
      final dims = service.getEffectiveDimensions(layout);
      expect(dims.contentWidthMm, 170); // 210 - 40
      expect(dims.contentHeightMm, 257); // 297 - 40
    });

    test('generatePrintCss inclui @media print', () {
      const layout = PrintLayout(economyMode: true);
      final css = service.generatePrintCss(layout);
      expect(css, contains('@media print'));
      expect(css, contains('@page'));
    });

    test('economy mode inclui regras de economia', () {
      const layout = PrintLayout(economyMode: true);
      final css = service.generatePrintCss(layout);
      expect(css, contains('color: #000'));
      expect(css, contains('grayscale'));
    });
  });
}
