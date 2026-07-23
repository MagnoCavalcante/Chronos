import '../../../core/utils/logger.dart';
import '../data/services/signature_service.dart';
import '../domain/entities/export_entities.dart';
import '../domain/providers/export_provider.dart';

/// Módulo central de exportação do CHRONOS.
///
/// Responsável por integrar:
/// - ExportProvider (interface)
/// - PdfProvider
/// - ImageProvider
/// - MarkdownProvider
/// - HtmlProvider
/// - PowerPointProvider (futuro)
/// - ShareService
/// - QrCodeService
/// - DeepLinkService
///
/// Nenhuma tela exporta diretamente. Toda exportação passa pelo ExportEngine.
class ExportEngine {
  static const String _tag = 'ExportEngine';

  final Map<ExportFormat, ExportProvider> _providers = {};
  final SignatureService _signatureService;

  ExportEngine({required SignatureService signatureService})
      : _signatureService = signatureService;

  /// Registra um provedor de exportação.
  void registerProvider(ExportProvider provider) {
    _providers[provider.format] = provider;
    ChronosLogger.info('Provider registrado: ${provider.name}', tag: _tag);
  }

  /// Retorna os formatos disponíveis.
  List<ExportFormat> get availableFormats =>
      _providers.entries.where((e) => e.value.isAvailable).map((e) => e.key).toList();

  /// Verifica se um formato está disponível.
  bool isFormatAvailable(ExportFormat format) =>
      _providers.containsKey(format) && _providers[format]!.isAvailable;

  /// Exporta um conteúdo individual no formato especificado.
  Future<ExportResult> export({
    required ExportableContent content,
    required ExportConfig config,
  }) async {
    final provider = _providers[config.format];
    if (provider == null || !provider.isAvailable) {
      return ExportResult(
        success: false,
        format: config.format,
        errorMessage: 'Formato ${config.format.name} não disponível',
        timestamp: DateTime.now(),
      );
    }

    ChronosLogger.info(
      'Exportando "${content.title}" em ${provider.name}',
      tag: _tag,
    );

    final result = await provider.export(content, config);

    if (result.success) {
      ChronosLogger.info('Exportação concluída com sucesso', tag: _tag);
    } else {
      ChronosLogger.error('Falha na exportação: ${result.errorMessage}', tag: _tag);
    }

    return result;
  }

  /// Exporta um lote de conteúdos.
  Future<ExportResult> exportBatch({required BatchExportRequest request}) async {
    final provider = _providers[request.config.format];
    if (provider == null || !provider.isAvailable) {
      return ExportResult(
        success: false,
        format: request.config.format,
        errorMessage: 'Formato ${request.config.format.name} não disponível',
        timestamp: DateTime.now(),
      );
    }

    ChronosLogger.info(
      'Exportação em lote: "${request.title}" (${request.contents.length} itens) em ${provider.name}',
      tag: _tag,
    );

    return await provider.exportBatch(request);
  }

  /// Gera assinatura digital para inclusão manual em exportações customizadas.
  ExportSignature generateSignature() => _signatureService.generate();

  /// Gera dados para QR Code da exportação.
  String generateQrData(ExportableContent content) {
    return 'chronos://content/${content.entityType}/${content.entityId}';
  }

  /// Gera deep link para o conteúdo.
  String generateDeepLink(ExportableContent content) {
    return 'https://chronos.app/${content.entityType}/${content.entityId}';
  }
}
