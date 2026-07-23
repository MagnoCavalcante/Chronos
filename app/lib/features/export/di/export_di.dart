import '../../../core/di/service_locator.dart';
import '../data/providers/html_provider.dart';
import '../data/providers/image_provider.dart';
import '../data/providers/markdown_provider.dart';
import '../data/providers/pdf_provider.dart';
import '../data/services/ai_generation_service.dart';
import '../data/services/print_layout_service.dart';
import '../data/services/signature_service.dart';
import '../services/export_engine.dart';

/// Módulo de DI do sistema de exportação.
class ExportDI {
  static void register() {
    final sl = ServiceLocator.instance;

    // Serviços
    sl.registerLazySingleton<SignatureService>(() => SignatureService());
    sl.registerLazySingleton<PrintLayoutService>(() => PrintLayoutService());
    sl.registerLazySingleton<AiGenerationService>(() => AiGenerationService());

    // Providers
    sl.registerLazySingleton<MarkdownProvider>(
      () => MarkdownProvider(signatureService: sl.get<SignatureService>()),
    );
    sl.registerLazySingleton<HtmlProvider>(
      () => HtmlProvider(signatureService: sl.get<SignatureService>()),
    );
    sl.registerLazySingleton<PdfProvider>(
      () => PdfProvider(signatureService: sl.get<SignatureService>()),
    );
    sl.registerLazySingleton<ImageExportProvider>(() => ImageExportProvider());

    // Engine central
    sl.registerLazySingleton<ExportEngine>(() {
      final engine = ExportEngine(signatureService: sl.get<SignatureService>());
      engine.registerProvider(sl.get<MarkdownProvider>());
      engine.registerProvider(sl.get<HtmlProvider>());
      engine.registerProvider(sl.get<PdfProvider>());
      engine.registerProvider(sl.get<ImageExportProvider>());
      return engine;
    });
  }
}
