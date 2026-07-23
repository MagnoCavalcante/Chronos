import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';
import '../domain/entities/onboarding_entities.dart';

/// Serviço de Onboarding do CHRONOS.
///
/// Gerencia o fluxo de introdução ao aplicativo.
/// Permite pular, registra conclusão e persiste estado.
class OnboardingService extends ChangeNotifier {
  static const String _tag = 'OnboardingService';
  static const String _completedKey = 'chronos_onboarding_completed';
  static const String _lastStepKey = 'chronos_onboarding_last_step';

  bool _completed = false;
  int _currentStep = 0;

  /// Se o onboarding já foi concluído.
  bool get isCompleted => _completed;

  /// Passo atual.
  int get currentStep => _currentStep;

  /// Total de passos.
  int get totalSteps => steps.length;

  /// Progresso (0.0 - 1.0).
  double get progress => totalSteps > 0 ? _currentStep / (totalSteps - 1).clamp(1, double.infinity) : 0;

  /// Passos do onboarding.
  static const List<OnboardingStep> steps = [
    OnboardingStep(
      id: 'search',
      title: 'Pesquisa Inteligente',
      description: 'Encontre qualquer evento, personagem ou civilização da história em segundos.',
      iconAsset: 'search',
      feature: OnboardingFeature.search,
    ),
    OnboardingStep(
      id: 'timeline',
      title: 'Linha do Tempo',
      description: 'Visualize a história cronologicamente e explore conexões entre eventos.',
      iconAsset: 'timeline',
      feature: OnboardingFeature.timeline,
    ),
    OnboardingStep(
      id: 'map',
      title: 'Mapa Histórico',
      description: 'Explore onde os eventos aconteceram com marcadores inteligentes e camadas.',
      iconAsset: 'map',
      feature: OnboardingFeature.map,
    ),
    OnboardingStep(
      id: 'ai',
      title: 'Assistente IA',
      description: 'Tire dúvidas com a inteligência artificial especializada em história.',
      iconAsset: 'ai',
      feature: OnboardingFeature.ai,
    ),
    OnboardingStep(
      id: 'collections',
      title: 'Coleções',
      description: 'Organize seus conteúdos favoritos em coleções personalizadas.',
      iconAsset: 'collections',
      feature: OnboardingFeature.collections,
    ),
    OnboardingStep(
      id: 'gamification',
      title: 'Gamificação',
      description: 'Ganhe conquistas e suba de nível enquanto aprende história.',
      iconAsset: 'gamification',
      feature: OnboardingFeature.gamification,
    ),
    OnboardingStep(
      id: 'favorites',
      title: 'Favoritos',
      description: 'Salve seus conteúdos preferidos para acesso rápido.',
      iconAsset: 'favorites',
      feature: OnboardingFeature.favorites,
    ),
    OnboardingStep(
      id: 'study',
      title: 'Sistema de Estudos',
      description: 'Estude com flashcards, quizzes e revisão espaçada.',
      iconAsset: 'study',
      feature: OnboardingFeature.studySystem,
    ),
  ];

  /// Carrega o estado persistido.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _completed = prefs.getBool(_completedKey) ?? false;
      _currentStep = prefs.getInt(_lastStepKey) ?? 0;
      notifyListeners();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar onboarding: $e', tag: _tag);
    }
  }

  /// Avança para o próximo passo.
  Future<void> next() async {
    if (_currentStep < steps.length - 1) {
      _currentStep++;
      await _saveProgress();
      notifyListeners();
    } else {
      await complete();
    }
  }

  /// Volta para o passo anterior.
  void previous() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Pula o onboarding completamente.
  Future<void> skip() async {
    await complete();
    ChronosLogger.info('Onboarding pulado pelo usuário', tag: _tag);
  }

  /// Marca o onboarding como concluído.
  Future<void> complete() async {
    _completed = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_completedKey, true);
    } catch (e) {
      ChronosLogger.error('Erro ao salvar conclusão do onboarding: $e', tag: _tag);
    }
    ChronosLogger.info('Onboarding concluído', tag: _tag);
    notifyListeners();
  }

  /// Reseta o onboarding (para configurações).
  Future<void> reset() async {
    _completed = false;
    _currentStep = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_completedKey);
      await prefs.remove(_lastStepKey);
    } catch (e) {
      ChronosLogger.error('Erro ao resetar onboarding: $e', tag: _tag);
    }
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastStepKey, _currentStep);
    } catch (_) {}
  }
}
