import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/logger.dart';
import '../domain/entities/presentation_entities.dart';

/// Estado do Modo Apresentação.
enum PresentationState { idle, active, paused }

/// Controller central do Modo Apresentação.
///
/// Gerencia navegação entre slides via gestos, teclado e controle remoto Bluetooth.
/// Funciona para Timeline, Personagens, Eventos, Civilizações, Mapa e Coleções.
///
/// Infraestrutura de transmissão (Chromecast, AirPlay, HDMI) preparada mas não implementada.
class PresentationController extends ChangeNotifier {
  static const String _tag = 'PresentationController';

  PresentationSession? _session;
  int _currentIndex = 0;
  PresentationState _state = PresentationState.idle;
  Timer? _autoAdvanceTimer;
  CastConfig? _castConfig;

  /// Sessão ativa.
  PresentationSession? get session => _session;

  /// Índice do slide atual.
  int get currentIndex => _currentIndex;

  /// Slide atual.
  PresentationSlide? get currentSlide =>
      _session != null && _currentIndex < _session!.slides.length
          ? _session!.slides[_currentIndex]
          : null;

  /// Estado da apresentação.
  PresentationState get state => _state;

  /// Progresso (0.0 a 1.0).
  double get progress {
    if (_session == null || _session!.slides.isEmpty) return 0;
    return _currentIndex / (_session!.slides.length - 1).clamp(1, double.infinity);
  }

  /// Configuração de cast atual.
  CastConfig? get castConfig => _castConfig;

  /// Inicia uma sessão de apresentação.
  void startSession(PresentationSession session) {
    _session = session;
    _currentIndex = 0;
    _state = PresentationState.active;

    if (session.config.fullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }

    if (session.config.autoAdvanceEnabled) {
      _startAutoAdvance();
    }

    ChronosLogger.info('Apresentação iniciada: ${session.title} (${session.totalSlides} slides)', tag: _tag);
    notifyListeners();
  }

  /// Finaliza a sessão.
  void endSession() {
    _stopAutoAdvance();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _state = PresentationState.idle;
    _session = null;
    _currentIndex = 0;
    ChronosLogger.info('Apresentação finalizada', tag: _tag);
    notifyListeners();
  }

  /// Pausa a apresentação.
  void pause() {
    _stopAutoAdvance();
    _state = PresentationState.paused;
    notifyListeners();
  }

  /// Retoma a apresentação.
  void resume() {
    _state = PresentationState.active;
    if (_session?.config.autoAdvanceEnabled == true) {
      _startAutoAdvance();
    }
    notifyListeners();
  }

  /// Avança para o próximo slide.
  void next() {
    if (_session == null) return;
    if (_currentIndex < _session!.slides.length - 1) {
      _currentIndex++;
      _resetAutoAdvance();
      notifyListeners();
    }
  }

  /// Volta para o slide anterior.
  void previous() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _resetAutoAdvance();
      notifyListeners();
    }
  }

  /// Pula para um slide específico.
  void goToSlide(int index) {
    if (_session == null) return;
    if (index >= 0 && index < _session!.slides.length) {
      _currentIndex = index;
      _resetAutoAdvance();
      notifyListeners();
    }
  }

  /// Processa evento de teclado para navegação.
  ///
  /// Teclas suportadas: Seta Direita/Espaço (avançar), Seta Esquerda (voltar), Escape (sair).
  bool handleKeyEvent(KeyEvent event) {
    if (_session?.config.keyboardNavigation != true) return false;
    if (event is! KeyDownEvent) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.pageDown:
        next();
        return true;
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.pageUp:
        previous();
        return true;
      case LogicalKeyboardKey.escape:
        endSession();
        return true;
      case LogicalKeyboardKey.home:
        goToSlide(0);
        return true;
      case LogicalKeyboardKey.end:
        goToSlide((_session?.slides.length ?? 1) - 1);
        return true;
      default:
        return false;
    }
  }

  /// Processa gesto de swipe horizontal para navegação.
  void handleSwipe(SwipeDirection direction) {
    if (_session?.config.gestureNavigation != true) return;
    switch (direction) {
      case SwipeDirection.left:
        next();
        break;
      case SwipeDirection.right:
        previous();
        break;
    }
  }

  /// Prepara conexão com dispositivo de cast (infraestrutura futura).
  void prepareCast(CastOutputType type) {
    _castConfig = CastConfig(outputType: type, isConnected: false);
    ChronosLogger.info('Cast preparado para: ${type.name} (não implementado)', tag: _tag);
    notifyListeners();
  }

  /// Desconecta dispositivo de cast.
  void disconnectCast() {
    _castConfig = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopAutoAdvance();
    super.dispose();
  }

  // ─── Private ───────────────────────────────────────────────

  void _startAutoAdvance() {
    _stopAutoAdvance();
    _autoAdvanceTimer = Timer.periodic(
      _session!.config.autoAdvanceInterval,
      (_) => next(),
    );
  }

  void _stopAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = null;
  }

  void _resetAutoAdvance() {
    if (_session?.config.autoAdvanceEnabled == true && _state == PresentationState.active) {
      _startAutoAdvance();
    }
  }
}

/// Direção de swipe para navegação por gestos.
enum SwipeDirection { left, right }
