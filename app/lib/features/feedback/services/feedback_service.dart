import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';
import '../domain/entities/feedback_entities.dart';

/// Serviço central de Feedback do CHRONOS.
///
/// Permite que usuários enviem sugestões, problemas e elogios sem sair do app.
/// Armazena localmente e prepara arquitetura para integração futura com backend.
class FeedbackService {
  static const String _tag = 'FeedbackService';
  static const String _storageKey = 'chronos_user_feedback';

  final List<UserFeedback> _feedbacks = [];

  /// Lista de feedbacks enviados.
  List<UserFeedback> get feedbacks => List.unmodifiable(_feedbacks);

  /// Carrega feedbacks salvos.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;

      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _feedbacks.clear();
      _feedbacks.addAll(list.map(UserFeedback.fromJson));
    } catch (e) {
      ChronosLogger.error('Erro ao carregar feedbacks: $e', tag: _tag);
    }
  }

  /// Submete um novo feedback.
  Future<void> submit({
    required FeedbackType type,
    required String message,
    String? email,
    String? screenContext,
  }) async {
    final feedback = UserFeedback(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      message: message,
      email: email,
      screenContext: screenContext,
      createdAt: DateTime.now(),
      status: FeedbackStatus.pending,
    );

    _feedbacks.add(feedback);
    await _save();

    ChronosLogger.info('Feedback registrado: ${type.name}', tag: _tag);

    // Futuramente: enviar para API
    // await _sendToBackend(feedback);
  }

  /// Limpa todos os feedbacks enviados.
  Future<void> clear() async {
    _feedbacks.clear();
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_feedbacks.map((f) => f.toJson()).toList());
      await prefs.setString(_storageKey, data);
    } catch (e) {
      ChronosLogger.error('Erro ao salvar feedbacks: $e', tag: _tag);
    }
  }
}
