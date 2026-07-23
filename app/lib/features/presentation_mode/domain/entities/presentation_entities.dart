/// Tipo de conteúdo apresentável no Modo Apresentação.
enum PresentableContentType {
  timeline,
  character,
  event,
  civilization,
  historicalMap,
  collection,
}

/// Item individual de uma apresentação.
class PresentationSlide {
  final String id;
  final String title;
  final String? subtitle;
  final String? bodyText;
  final String? imageUrl;
  final PresentableContentType contentType;
  final String entityId;
  final Map<String, dynamic>? metadata;

  const PresentationSlide({
    required this.id,
    required this.title,
    this.subtitle,
    this.bodyText,
    this.imageUrl,
    required this.contentType,
    required this.entityId,
    this.metadata,
  });
}

/// Sessão de apresentação contendo slides ordenados.
class PresentationSession {
  final String id;
  final String title;
  final List<PresentationSlide> slides;
  final PresentationConfig config;
  final DateTime createdAt;

  const PresentationSession({
    required this.id,
    required this.title,
    required this.slides,
    this.config = const PresentationConfig(),
    required this.createdAt,
  });

  int get totalSlides => slides.length;
}

/// Configurações do Modo Apresentação.
class PresentationConfig {
  final bool fullscreen;
  final bool hideMenus;
  final bool gestureNavigation;
  final bool keyboardNavigation;
  final bool bluetoothRemoteNavigation;
  final Duration autoAdvanceInterval;
  final bool autoAdvanceEnabled;
  final PresentationTransition transition;

  const PresentationConfig({
    this.fullscreen = true,
    this.hideMenus = true,
    this.gestureNavigation = true,
    this.keyboardNavigation = true,
    this.bluetoothRemoteNavigation = true,
    this.autoAdvanceInterval = const Duration(seconds: 10),
    this.autoAdvanceEnabled = false,
    this.transition = PresentationTransition.fade,
  });
}

/// Tipos de transição entre slides.
enum PresentationTransition {
  fade,
  slide,
  scale,
  none,
}

/// Tipo de saída de transmissão (infraestrutura futura).
enum CastOutputType {
  chromecast,
  airplay,
  hdmi,
}

/// Configuração de transmissão (infraestrutura apenas).
class CastConfig {
  final CastOutputType outputType;
  final bool isConnected;
  final String? deviceName;

  const CastConfig({
    required this.outputType,
    this.isConnected = false,
    this.deviceName,
  });
}
