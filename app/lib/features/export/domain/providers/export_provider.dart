import '../entities/export_entities.dart';

/// Interface abstrata que define o contrato de qualquer provedor de exportação.
///
/// Cada formato (PDF, Image, Markdown, HTML, PowerPoint) implementa esta interface.
/// O ExportEngine nunca depende de implementações concretas — apenas desta abstração.
abstract class ExportProvider {
  /// Nome identificador do provedor.
  String get name;

  /// Formato de exportação que este provedor suporta.
  ExportFormat get format;

  /// Indica se o provedor está disponível no ambiente atual.
  bool get isAvailable;

  /// Exporta um conteúdo individual.
  Future<ExportResult> export(ExportableContent content, ExportConfig config);

  /// Exporta um lote de conteúdos em um único arquivo.
  Future<ExportResult> exportBatch(BatchExportRequest request);
}
