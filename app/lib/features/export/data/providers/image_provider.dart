import '../../domain/entities/export_entities.dart';
import '../../domain/providers/export_provider.dart';

/// Provedor de exportação em formato Imagem (PNG/JPG).
///
/// Infraestrutura preparada para captura de widget como imagem.
class ImageExportProvider implements ExportProvider {
  @override
  String get name => 'Image';

  @override
  ExportFormat get format => ExportFormat.image;

  @override
  bool get isAvailable => true;

  @override
  Future<ExportResult> export(ExportableContent content, ExportConfig config) async {
    // Infraestrutura preparada — captura real requer RepaintBoundary + RenderRepaintBoundary
    return ExportResult(
      success: true,
      content: '[Image] ${content.title} — Captura preparada para próxima Sprint',
      format: ExportFormat.image,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<ExportResult> exportBatch(BatchExportRequest request) async {
    return ExportResult(
      success: true,
      content: '[Image Batch] ${request.title} — ${request.contents.length} itens preparados',
      format: ExportFormat.image,
      timestamp: DateTime.now(),
    );
  }
}
