import '../../../core/utils/logger.dart';
import '../domain/entities/ai_entities.dart';
import '../domain/entities/ai_teacher_entities.dart';
import '../domain/repositories/ai_teacher_repository.dart';
import 'ai_service.dart';

/// Serviço de Sessão de Estudos Guiada.
///
/// A IA conduz uma aula completa: explicação → pergunta →
/// resposta do aluno → correção → próximo assunto.
class StudySessionService {
  final AiService _aiService;
  final AiTeacherRepository _repository;
  final String _userId;

  static const _tag = 'StudySessionService';

  StudySessionService({
    required AiService aiService,
    required AiTeacherRepository repository,
    String userId = 'local_user',
  })  : _aiService = aiService,
        _repository = repository,
        _userId = userId;

  /// Inicia sessão de estudo sobre um tema.
  Future<TutorSession> startSession({
    required String topic,
    ExplanationLevel level = ExplanationLevel.intermediate,
  }) async {
    final session = TutorSession(
      id: '${DateTime.now().millisecondsSinceEpoch}_$_userId',
      userId: _userId,
      topic: topic,
      level: level,
      startedAt: DateTime.now(),
    );

    // Gerar explicação inicial
    final prompt = 'Hoje vamos estudar "$topic".\n\n'
        '${_levelInstruction(level)}\n\n'
        'Comece explicando o tema de forma clara e estruturada. '
        'Use EXCLUSIVAMENTE a Base de Conhecimento do Chronos.\n'
        'Ao final, faça uma pergunta sobre o conteúdo explicado.';

    final response = await _aiService.ask(prompt, mode: AiMode.teacher);

    final step = SessionStep(
      type: SessionStepType.explanation,
      content: response.text,
      timestamp: DateTime.now(),
    );

    final updated = session.copyWith(steps: [step]);
    await _repository.saveSession(updated);
    ChronosLogger.info('Sessão iniciada: $topic (${level.name})', tag: _tag);
    return updated;
  }

  /// Envia resposta do aluno e recebe correção + próxima etapa.
  Future<TutorSession> submitAnswer({
    required String sessionId,
    required String answer,
  }) async {
    final session = await _repository.getSession(sessionId);
    if (session == null) throw Exception('Sessão não encontrada');

    // Registrar resposta
    final answerStep = SessionStep(
      type: SessionStepType.question,
      content: 'Resposta do aluno',
      userResponse: answer,
      timestamp: DateTime.now(),
    );

    // Gerar correção
    final lastExplanation = session.steps
        .lastWhere((s) => s.type == SessionStepType.explanation,
            orElse: () => session.steps.last)
        .content;

    final prompt = 'Contexto do estudo: "${session.topic}"\n\n'
        'Última explicação:\n$lastExplanation\n\n'
        'Resposta do aluno: $answer\n\n'
        'Avalie a resposta:\n'
        '1. Está correta? (Sim/Parcial/Não)\n'
        '2. Corrija eventuais erros.\n'
        '3. Explique um novo tópico relacionado.\n'
        '4. Faça uma nova pergunta sobre o novo tópico.\n\n'
        'Use EXCLUSIVAMENTE a Base de Conhecimento do Chronos.';

    final response = await _aiService.ask(prompt, mode: AiMode.teacher);

    final correctionStep = SessionStep(
      type: SessionStepType.correction,
      content: response.text,
      timestamp: DateTime.now(),
    );

    final updatedSteps = [...session.steps, answerStep, correctionStep];
    final updated = session.copyWith(steps: updatedSteps);
    await _repository.saveSession(updated);
    return updated;
  }

  /// Finaliza a sessão de estudo.
  Future<TutorSession> endSession(String sessionId) async {
    final session = await _repository.getSession(sessionId);
    if (session == null) throw Exception('Sessão não encontrada');

    final updated = session.copyWith(
      status: StudySessionStatus.completed,
      endedAt: DateTime.now(),
    );
    await _repository.saveSession(updated);
    ChronosLogger.info('Sessão finalizada: ${session.topic}', tag: _tag);
    return updated;
  }

  /// Obtém sessão ativa (se existir).
  Future<TutorSession?> getActiveSession() async {
    return _repository.getActiveSession(_userId);
  }

  /// Obtém histórico de sessões.
  Future<List<TutorSession>> getSessionHistory({int limit = 10}) async {
    return _repository.getSessions(_userId, limit: limit);
  }

  String _levelInstruction(ExplanationLevel level) {
    switch (level) {
      case ExplanationLevel.basic:
        return 'Explique como para alguém de 12 anos.';
      case ExplanationLevel.intermediate:
        return 'Explique com profundidade moderada.';
      case ExplanationLevel.advanced:
        return 'Explique em profundidade com múltiplas perspectivas.';
      case ExplanationLevel.academic:
        return 'Explique em nível acadêmico com fontes e debates historiográficos.';
    }
  }
}
