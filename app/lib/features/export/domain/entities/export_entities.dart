/// Formato de exportação suportado.
enum ExportFormat {
  pdf,
  image,
  markdown,
  html,
  powerpoint,
}

/// Conteúdo exportável do Chronos.
class ExportableContent {
  final String id;
  final String title;
  final String? subtitle;
  final String body;
  final String entityType;
  final String entityId;
  final String? imageUrl;
  final int? year;
  final Map<String, dynamic>? metadata;

  const ExportableContent({
    required this.id,
    required this.title,
    this.subtitle,
    required this.body,
    required this.entityType,
    required this.entityId,
    this.imageUrl,
    this.year,
    this.metadata,
  });
}

/// Resultado de uma exportação.
class ExportResult {
  final bool success;
  final String? filePath;
  final String? content;
  final ExportFormat format;
  final String? errorMessage;
  final DateTime timestamp;

  const ExportResult({
    required this.success,
    this.filePath,
    this.content,
    required this.format,
    this.errorMessage,
    required this.timestamp,
  });
}

/// Configuração de exportação.
class ExportConfig {
  final ExportFormat format;
  final bool includeSignature;
  final bool includeQrCode;
  final bool includeImages;
  final PrintLayout? printLayout;
  final String? customFooter;

  const ExportConfig({
    required this.format,
    this.includeSignature = true,
    this.includeQrCode = true,
    this.includeImages = true,
    this.printLayout,
    this.customFooter,
  });
}

/// Layout de impressão.
class PrintLayout {
  final PageSize pageSize;
  final PageOrientation orientation;
  final bool economyMode;
  final double marginMm;

  const PrintLayout({
    this.pageSize = PageSize.a4,
    this.orientation = PageOrientation.portrait,
    this.economyMode = true,
    this.marginMm = 15.0,
  });
}

/// Tamanho de página.
enum PageSize { a4, letter }

/// Orientação da página.
enum PageOrientation { portrait, landscape }

/// Conteúdo para exportação em lote.
class BatchExportRequest {
  final String title;
  final List<ExportableContent> contents;
  final ExportConfig config;

  const BatchExportRequest({
    required this.title,
    required this.contents,
    required this.config,
  });
}

/// Assinatura digital incluída em toda exportação.
class ExportSignature {
  final String appName;
  final String version;
  final DateTime exportDate;
  final String? qrCodeData;
  final String copyright;
  final String chronosUrl;

  const ExportSignature({
    this.appName = 'CHRONOS',
    required this.version,
    required this.exportDate,
    this.qrCodeData,
    this.copyright = '© CHRONOS - Todos os direitos reservados',
    this.chronosUrl = 'https://chronos.app',
  });
}
