import '../../domain/entities/export_entities.dart';
import '../../domain/providers/export_provider.dart';
import '../services/signature_service.dart';

/// Provedor de exportação em formato HTML responsivo.
///
/// Gera páginas HTML completas, prontas para publicação como mini site.
class HtmlProvider implements ExportProvider {
  final SignatureService _signatureService;

  HtmlProvider({required SignatureService signatureService})
      : _signatureService = signatureService;

  @override
  String get name => 'HTML';

  @override
  ExportFormat get format => ExportFormat.html;

  @override
  bool get isAvailable => true;

  @override
  Future<ExportResult> export(ExportableContent content, ExportConfig config) async {
    try {
      final html = _buildHtmlPage(
        title: content.title,
        body: _buildContentSection(content, config),
        signature: config.includeSignature ? _buildSignatureHtml() : '',
      );

      return ExportResult(
        success: true,
        content: html,
        format: ExportFormat.html,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return ExportResult(
        success: false,
        format: ExportFormat.html,
        errorMessage: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<ExportResult> exportBatch(BatchExportRequest request) async {
    try {
      final sections = StringBuffer();
      for (final content in request.contents) {
        sections.writeln(_buildContentSection(content, request.config));
        sections.writeln('<hr/>');
      }

      final html = _buildHtmlPage(
        title: request.title,
        body: sections.toString(),
        signature: request.config.includeSignature ? _buildSignatureHtml() : '',
      );

      return ExportResult(
        success: true,
        content: html,
        format: ExportFormat.html,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return ExportResult(
        success: false,
        format: ExportFormat.html,
        errorMessage: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  String _buildHtmlPage({required String title, required String body, required String signature}) {
    return '''<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>$title - CHRONOS</title>
  <style>
    :root { --primary: #E65100; --bg: #FAFAFA; --text: #212121; --muted: #757575; }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: var(--bg); color: var(--text); line-height: 1.6; padding: 2rem; max-width: 900px; margin: 0 auto; }
    h1 { color: var(--primary); margin-bottom: 1rem; font-size: 2rem; }
    h2 { color: var(--primary); margin: 1.5rem 0 0.5rem; font-size: 1.5rem; }
    p { margin-bottom: 1rem; }
    img { max-width: 100%; height: auto; border-radius: 8px; margin: 1rem 0; }
    .subtitle { color: var(--muted); font-size: 1.1rem; margin-bottom: 0.5rem; }
    .year { background: var(--primary); color: #fff; padding: 2px 8px; border-radius: 4px; font-size: 0.85rem; display: inline-block; margin-bottom: 1rem; }
    hr { border: none; border-top: 1px solid #E0E0E0; margin: 2rem 0; }
    .signature { margin-top: 3rem; padding-top: 1rem; border-top: 2px solid var(--primary); color: var(--muted); font-size: 0.85rem; text-align: center; }
    .signature a { color: var(--primary); text-decoration: none; }
    @media print { body { padding: 1cm; } .signature { page-break-inside: avoid; } }
    @media (max-width: 600px) { body { padding: 1rem; } h1 { font-size: 1.5rem; } }
  </style>
</head>
<body>
  <h1>$title</h1>
  $body
  $signature
</body>
</html>''';
  }

  String _buildContentSection(ExportableContent content, ExportConfig config) {
    final buffer = StringBuffer();
    buffer.writeln('<article>');
    buffer.writeln('  <h2>${_escapeHtml(content.title)}</h2>');
    if (content.subtitle != null) {
      buffer.writeln('  <p class="subtitle">${_escapeHtml(content.subtitle!)}</p>');
    }
    if (content.year != null) {
      buffer.writeln('  <span class="year">Ano: ${content.year}</span>');
    }
    if (config.includeImages && content.imageUrl != null) {
      buffer.writeln('  <img src="${content.imageUrl}" alt="${_escapeHtml(content.title)}"/>');
    }
    buffer.writeln('  <p>${_escapeHtml(content.body)}</p>');
    buffer.writeln('</article>');
    return buffer.toString();
  }

  String _buildSignatureHtml() {
    final sig = _signatureService.generate();
    return '''<div class="signature">
  <p>Exportado por <strong>${sig.appName}</strong> v${sig.version}</p>
  <p>Data: ${sig.exportDate.toIso8601String().split('T').first}</p>
  <p>${sig.copyright}</p>
  <p><a href="${sig.chronosUrl}">${sig.chronosUrl}</a></p>
</div>''';
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }
}
