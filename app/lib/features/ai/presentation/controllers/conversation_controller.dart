import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/ai_entities.dart';
import '../../services/ai_service.dart';

/// Estado reativo da tela de conversa com o Chronos AI.
class ConversationState {
  final List<ConversationMessage> messages;
  final bool isLoading;
  final String? error;
  final AiMode currentMode;
  final List<String> suggestions;
  final String? currentQuestion;

  const ConversationState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.currentMode = AiMode.normal,
    this.suggestions = const [],
    this.currentQuestion,
  });

  ConversationState copyWith({
    List<ConversationMessage>? messages,
    bool? isLoading,
    String? error,
    bool clearError = false,
    AiMode? currentMode,
    List<String>? suggestions,
    String? currentQuestion,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      currentMode: currentMode ?? this.currentMode,
      suggestions: suggestions ?? this.suggestions,
      currentQuestion: currentQuestion ?? this.currentQuestion,
    );
  }
}

/// Controller da conversa do Chronos AI.
///
/// Gerencia histórico, modos de resposta, favoritar, fixar e sugestões.
class ConversationController extends ChangeNotifier {
  final AiService _aiService;

  static const _tag = 'ConversationController';

  ConversationState _state = const ConversationState();
  bool _initialized = false;

  ConversationController({required AiService aiService}) : _aiService = aiService;

  ConversationState get state => _state;
  bool get isLoading => _state.isLoading;
  List<ConversationMessage> get messages => _state.messages;
  List<String> get suggestions => _state.suggestions;
  AiMode get currentMode => _state.currentMode;
  String? get error => _state.error;
  bool get isInitialized => _initialized;

  /// Inicializa o controller carregando histórico e sugestões.
  Future<void> initialize() async {
    if (_initialized) return;
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final messages = await _aiService.getHistory();
      _state = _state.copyWith(
        messages: messages,
        isLoading: false,
        suggestions: _defaultSuggestions(),
      );
      _initialized = true;
    } catch (e) {
      ChronosLogger.error('Erro ao inicializar conversa: $e', tag: _tag, error: e);
      _state = _state.copyWith(
        isLoading: false,
        error: 'Não foi possível carregar o histórico de conversas.',
      );
    }

    notifyListeners();
  }

  /// Envia uma pergunta para o assistente.
  Future<void> ask(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return;

    _state = _state.copyWith(isLoading: true, clearError: true, currentQuestion: trimmed);
    notifyListeners();

    try {
      final response = await _aiService.ask(trimmed, mode: _state.currentMode);
      _state = _state.copyWith(
        isLoading: false,
        currentQuestion: null,
        suggestions: response.suggestedQuestions.isNotEmpty
            ? response.suggestedQuestions
            : _defaultSuggestions(),
      );
      await _refreshHistory();
    } catch (e) {
      ChronosLogger.error('Erro ao perguntar ao Chronos AI: $e', tag: _tag, error: e);
      _state = _state.copyWith(
        isLoading: false,
        error: 'Não foi possível obter uma resposta. Tente novamente.',
      );
    }

    notifyListeners();
  }

  /// Define o modo de resposta atual (estudo, resumo, etc.).
  void setMode(AiMode mode) {
    if (_state.currentMode == mode) return;
    _state = _state.copyWith(currentMode: mode);
    notifyListeners();
  }

  /// Seleciona uma sugestão como pergunta.
  Future<void> selectSuggestion(String suggestion) => ask(suggestion);

  /// Alterna o estado de favorito de uma mensagem.
  Future<void> toggleFavorite(String id) async {
    try {
      await _aiService.toggleFavorite(id);
      await _refreshHistory();
    } catch (e) {
      ChronosLogger.error('Erro ao favoritar mensagem: $e', tag: _tag, error: e);
    }
  }

  /// Alterna o estado de fixado de uma mensagem.
  Future<void> togglePin(String id) async {
    try {
      await _aiService.togglePin(id);
      await _refreshHistory();
    } catch (e) {
      ChronosLogger.error('Erro ao fixar mensagem: $e', tag: _tag, error: e);
    }
  }

  /// Remove uma mensagem do histórico.
  Future<void> deleteMessage(String id) async {
    try {
      await _aiService.deleteMessage(id);
      await _refreshHistory();
    } catch (e) {
      ChronosLogger.error('Erro ao excluir mensagem: $e', tag: _tag, error: e);
    }
  }

  /// Limpa todo o histórico.
  Future<void> clearHistory() async {
    try {
      await _aiService.clearHistory();
      _state = _state.copyWith(messages: []);
      notifyListeners();
    } catch (e) {
      ChronosLogger.error('Erro ao limpar histórico: $e', tag: _tag, error: e);
    }
  }

  Future<void> _refreshHistory() async {
    try {
      final messages = await _aiService.getHistory();
      _state = _state.copyWith(messages: messages);
      notifyListeners();
    } catch (e) {
      ChronosLogger.warn('Falha ao atualizar histórico: $e', tag: _tag, error: e);
    }
  }

  List<String> _defaultSuggestions() => const [
        'Quem foi Alexandre?',
        'O que causou a queda de Roma?',
        'Explique a Guerra Fria',
        'Quais civilizações existiam em 500 a.C.?',
      ];

  @override
  void dispose() {
    _state = const ConversationState();
    super.dispose();
  }
}
