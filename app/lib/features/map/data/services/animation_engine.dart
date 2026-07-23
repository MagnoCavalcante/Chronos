import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/map_entities.dart';
import '../../domain/providers/map_provider.dart';

/// Status de reprodução de uma animação histórica.
enum AnimationPlaybackState { idle, playing, paused, completed }

/// Infraestrutura para reprodução de animações históricas sincronizadas com a Timeline.
///
/// Nesta sprint, apenas a arquitetura é preparada. As animações concretas
/// (expansão do Império Romano, campanhas de Alexandre, etc.) serão adicionadas futuramente.
///
/// O [AnimationEngine] controla:
/// - reprodução sequencial de keyframes;
/// - pausa e retomada;
/// - velocidade de reprodução;
/// - sincronização com o ano atual da Timeline;
/// - notificação de listeners a cada frame.
class AnimationEngine extends ChangeNotifier {
  static const String _tag = 'AnimationEngine';

  final MapProvider _mapProvider;

  HistoricalAnimation? _currentAnimation;
  int _currentKeyframeIndex = 0;
  AnimationPlaybackState _playbackState = AnimationPlaybackState.idle;
  double _speed = 1.0;
  Timer? _playbackTimer;

  AnimationEngine({required MapProvider mapProvider}) : _mapProvider = mapProvider;

  /// Animação atualmente carregada.
  HistoricalAnimation? get currentAnimation => _currentAnimation;

  /// Índice do keyframe atual.
  int get currentKeyframeIndex => _currentKeyframeIndex;

  /// Frame atual ou null se não há animação.
  AnimationKeyframe? get currentKeyframe =>
      _currentAnimation != null && _currentKeyframeIndex < _currentAnimation!.keyframes.length
          ? _currentAnimation!.keyframes[_currentKeyframeIndex]
          : null;

  /// Estado de reprodução.
  AnimationPlaybackState get playbackState => _playbackState;

  /// Velocidade de reprodução (1.0 = normal, 2.0 = dobro).
  double get speed => _speed;

  /// Ano corrente correspondente ao keyframe ativo.
  int? get currentYear => currentKeyframe?.year;

  /// Progresso (0.0 a 1.0) da animação.
  double get progress {
    if (_currentAnimation == null || _currentAnimation!.keyframes.isEmpty) return 0;
    return _currentKeyframeIndex / (_currentAnimation!.keyframes.length - 1);
  }

  /// Carrega uma animação para reprodução.
  void load(HistoricalAnimation animation) {
    stop();
    _currentAnimation = animation;
    _currentKeyframeIndex = 0;
    _playbackState = AnimationPlaybackState.idle;
    ChronosLogger.info('Animação carregada: ${animation.title}', tag: _tag);
    notifyListeners();
  }

  /// Inicia ou retoma a reprodução.
  void play() {
    if (_currentAnimation == null) return;
    if (_playbackState == AnimationPlaybackState.completed) {
      _currentKeyframeIndex = 0;
    }
    _playbackState = AnimationPlaybackState.playing;
    _scheduleNextFrame();
    notifyListeners();
  }

  /// Pausa a reprodução.
  void pause() {
    _playbackTimer?.cancel();
    _playbackState = AnimationPlaybackState.paused;
    notifyListeners();
  }

  /// Para a reprodução e volta ao início.
  void stop() {
    _playbackTimer?.cancel();
    _currentKeyframeIndex = 0;
    _playbackState = AnimationPlaybackState.idle;
    notifyListeners();
  }

  /// Avança para o próximo keyframe.
  void next() {
    if (_currentAnimation == null) return;
    if (_currentKeyframeIndex < _currentAnimation!.keyframes.length - 1) {
      _currentKeyframeIndex++;
      _applyKeyframe();
      notifyListeners();
    }
  }

  /// Retrocede para o keyframe anterior.
  void previous() {
    if (_currentKeyframeIndex > 0) {
      _currentKeyframeIndex--;
      _applyKeyframe();
      notifyListeners();
    }
  }

  /// Pula para um keyframe específico pelo índice.
  void seekTo(int index) {
    if (_currentAnimation == null) return;
    if (index >= 0 && index < _currentAnimation!.keyframes.length) {
      _currentKeyframeIndex = index;
      _applyKeyframe();
      notifyListeners();
    }
  }

  /// Pula para o keyframe mais próximo do [year] fornecido.
  void seekToYear(int year) {
    if (_currentAnimation == null) return;
    int closest = 0;
    int minDiff = (year - _currentAnimation!.keyframes[0].year).abs();
    for (int i = 1; i < _currentAnimation!.keyframes.length; i++) {
      final diff = (year - _currentAnimation!.keyframes[i].year).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = i;
      }
    }
    seekTo(closest);
  }

  /// Define a velocidade de reprodução.
  void setSpeed(double value) {
    _speed = value.clamp(0.25, 4.0);
    if (_playbackState == AnimationPlaybackState.playing) {
      _playbackTimer?.cancel();
      _scheduleNextFrame();
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  // ─── Private ───────────────────────────────────────────────────────

  void _scheduleNextFrame() {
    if (_currentAnimation == null) return;
    final frame = currentKeyframe;
    if (frame == null) return;

    final adjustedDuration = Duration(
      milliseconds: (frame.duration.inMilliseconds / _speed).round(),
    );

    _playbackTimer = Timer(adjustedDuration, () {
      if (_currentKeyframeIndex < _currentAnimation!.keyframes.length - 1) {
        _currentKeyframeIndex++;
        _applyKeyframe();
        notifyListeners();
        _scheduleNextFrame();
      } else {
        _playbackState = AnimationPlaybackState.completed;
        notifyListeners();
      }
    });
  }

  void _applyKeyframe() {
    final frame = currentKeyframe;
    if (frame == null) return;
    _mapProvider.moveCamera(frame.center, zoom: frame.zoom);
  }
}
