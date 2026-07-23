import 'package:chronos/features/export/data/providers/html_provider.dart';
import 'package:chronos/features/export/data/providers/markdown_provider.dart';
import 'package:chronos/features/export/data/services/signature_service.dart';
import 'package:chronos/features/export/domain/entities/export_entities.dart';
import 'package:chronos/features/export/services/export_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExportEngine', () {
    late ExportEngine engine;
    late SignatureService signatureService;

    setUp(() {
      signatureService = SignatureService();
      engine = ExportEngine(signatureService: signatureService);
      engine.registerProvider(MarkdownProvider(signatureService: signatureService));
      engine.registerProvider(HtmlProvider(signatureService: signatureService));
    });

    test('registra providers corretamente', () {
      expect(engine.availableFormats, contains(ExportFormat.markdown));
      expect(engine.availableFormats, contains(ExportFormat.html));
    });

    test('verifica disponibilidade de formato', () {
      expect(engine.isFormatAvailable(ExportFormat.markdown), isTrue);
      expect(engine.isFormatAvailable(ExportFormat.powerpoint), isFalse);
    });

    test('exporta conteúdo em Markdown', () async {
      final content = ExportableContent(
        id: '1',
        title: 'Império Romano',
        subtitle: 'Maior império da antiguidade',
        body: 'O Império Romano dominou o Mediterrâneo por séculos.',
        entityType: 'civilization',
        entityId: 'civ_1',
        year: -27,
      );

      final result = await engine.export(
        content: content,
        config: const ExportConfig(format: ExportFormat.markdown),
      );

      expect(result.success, isTrue);
      expect(result.content, contains('# Império Romano'));
      expect(result.content, contains('Ano: -27'));
      expect(result.content, contains('CHRONOS'));
    });

    test('exporta conteúdo em HTML', () async {
      final content = ExportableContent(
        id: '2',
        title: 'Alexandre Magno',
        body: 'Conquistador macedônio que criou um dos maiores impérios.',
        entityType: 'character',
        entityId: 'char_1',
      );

      final result = await engine.export(
        content: content,
        config: const ExportConfig(format: ExportFormat.html),
      );

      expect(result.success, isTrue);
      expect(result.content, contains('<!DOCTYPE html>'));
      expect(result.content, contains('Alexandre Magno'));
      expect(result.content, contains('CHRONOS'));
    });

    test('exportação em lote funciona', () async {
      final request = BatchExportRequest(
        title: 'Civilizações Antigas',
        contents: [
          const ExportableContent(
            id: '1',
            title: 'Roma',
            body: 'Civilização romana.',
            entityType: 'civilization',
            entityId: 'c1',
          ),
          const ExportableContent(
            id: '2',
            title: 'Grécia',
            body: 'Civilização grega.',
            entityType: 'civilization',
            entityId: 'c2',
          ),
        ],
        config: const ExportConfig(format: ExportFormat.markdown),
      );

      final result = await engine.exportBatch(request: request);
      expect(result.success, isTrue);
      expect(result.content, contains('Roma'));
      expect(result.content, contains('Grécia'));
    });

    test('retorna erro para formato não registrado', () async {
      final content = ExportableContent(
        id: '1',
        title: 'Teste',
        body: 'Corpo',
        entityType: 'event',
        entityId: 'e1',
      );

      final result = await engine.export(
        content: content,
        config: const ExportConfig(format: ExportFormat.powerpoint),
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('não disponível'));
    });

    test('gera deep link', () {
      final content = ExportableContent(
        id: '1',
        title: 'T',
        body: 'B',
        entityType: 'event',
        entityId: 'e1',
      );
      final link = engine.generateDeepLink(content);
      expect(link, contains('chronos.app/event/e1'));
    });

    test('gera QR data', () {
      final content = ExportableContent(
        id: '1',
        title: 'T',
        body: 'B',
        entityType: 'character',
        entityId: 'ch1',
      );
      final qr = engine.generateQrData(content);
      expect(qr, contains('chronos://content/character/ch1'));
    });
  });
}
