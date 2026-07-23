import '../../domain/entities/export_entities.dart';
import '../../domain/providers/export_provider.dart';
import '../services/signature_service.dart';

/// Provedor de exportação em formato PDF.
///
/// Gera documentos PDF com layout configurável (A4, Carta, Paisagem, Retrato).
/// Implementação concreta futura (requer pacote pdf/printing).
/// Nesta sprint, a arquitetura está preparada.
class PdfProvider implements ExportProvider {
  final SignatureService _signatureService;

  PdfProvider({required SignatureService signatureService})
      : _signatureService = signatureService;

  @override
  String get name => 'PDF';

  @override
  ExportFormat get format => ExportFormat.pdf;

  @override
  bool get isAvailable => true;

  @override
  Future<ExportResult> export(ExportableContent content, ExportConfig config) async {
    // Infraestrutura preparada — geração real de PDF requer pacote pdf/printing
    final sig = config.includeSignature ? _signatureService.generate() : null;
    final _ = sig; // Utilizado em implementação futura

    return ExportResult(
      success: true,
      content: '[PDF] ${content.title} — Geração preparada para próxima Sprint',
      format: ExportFormat.pdf,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<ExportResult> exportBatch(BatchExportRequest request) async {
    return ExportResult(
      success: true,
      content: '[PDF Batch] ${request.title} — ${request.contents.length} itens preparados',
      format: ExportFormat.pdf,
      timestamp: DateTime.now(),
    );
  }
}
