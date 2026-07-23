import '../../domain/entities/export_entities.dart';
import '../../domain/providers/export_provider.dart';
import '../services/signature_service.dart';

/// Provedor de exportação em formato Markdown.
///
/// Gera conteúdo compatível com Obsidian, Notion, GitHub, blogs e documentações.
class MarkdownProvider implements ExportProvider {
  final SignatureService _signatureService;

  MarkdownProvider({required SignatureService signatureService})
      : _signatureService = signatureService;

  @override
  String get name => 'Markdown';

  @override
  ExportFormat get format => ExportFormat.markdown;

  @override
  bool get isAvailable => true;

  @override
  Future<ExportResult> export(ExportableContent content, ExportConfig config) async {
    try {
      final buffer = StringBuffer();
      _writeHeader(buffer, content);
      _writeBody(buffer, content);

      if (config.includeImages && content.imageUrl != null) {
        buffer.writeln('\n![${content.title}](${content.imageUrl})');
      }

      if (config.includeSignature) {
        _writeSignature(buffer);
      }

      return ExportResult(
        success: true,
        content: buffer.toString(),
        format: ExportFormat.markdown,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return ExportResult(
        success: false,
        format: ExportFormat.markdown,
        errorMessage: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<ExportResult> exportBatch(BatchExportRequest request) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('# ${request.title}\n');
      buffer.writeln('---\n');

      for (int i = 0; i < request.contents.length; i++) {
        final content = request.contents[i];
        _writeHeader(buffer, content, level: 2);
        _writeBody(buffer, content);

        if (request.config.includeImages && content.imageUrl != null) {
          buffer.writeln('\n![${content.title}](${content.imageUrl})');
        }

        if (i < request.contents.length - 1) {
          buffer.writeln('\n---\n');
        }
      }

      if (request.config.includeSignature) {
        buffer.writeln('\n---\n');
        _writeSignature(buffer);
      }

      return ExportResult(
        success: true,
        content: buffer.toString(),
        format: ExportFormat.markdown,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return ExportResult(
        success: false,
        format: ExportFormat.markdown,
        errorMessage: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  void _writeHeader(StringBuffer buffer, ExportableContent content, {int level = 1}) {
    final prefix = '#' * level;
    buffer.writeln('$prefix ${content.title}\n');
    if (content.subtitle != null) {
      buffer.writeln('**${content.subtitle}**\n');
    }
    if (content.year != null) {
      buffer.writeln('> Ano: ${content.year}\n');
    }
  }

  void _writeBody(StringBuffer buffer, ExportableContent content) {
    buffer.writeln(content.body);
  }

  void _writeSignature(StringBuffer buffer) {
    final sig = _signatureService.generate();
    buffer.writeln('\n---');
    buffer.writeln('*Exportado por ${sig.appName} v${sig.version}*');
    buffer.writeln('*Data: ${sig.exportDate.toIso8601String().split('T').first}*');
    buffer.writeln('*${sig.copyright}*');
    buffer.writeln('[${sig.chronosUrl}](${sig.chronosUrl})');
  }
}
