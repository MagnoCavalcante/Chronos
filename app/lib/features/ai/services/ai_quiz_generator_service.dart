import '../../../core/utils/logger.dart';
import '../domain/entities/ai_entities.dart';
import '../domain/entities/ai_teacher_entities.dart';
import 'ai_service.dart';

/// Serviço de Quiz Inteligente gerado pela IA.
///
/// Gera automaticamente quizzes de diferentes tipos
/// baseados no conteúdo estudado na Base de Conhecimento.
class AiQuizGeneratorService {
  final AiService _aiService;

  static const _tag = 'AiQuizGenerator';

  AiQuizGeneratorService({required AiService aiService}) : _aiService = aiService;

  /// Gera quiz de múltipla escolha.
  Future<AiResponse> generateMultipleChoice({
    required String entityName,
    required String entityType,
    int count = 5,
    ExplanationLevel difficulty = ExplanationLevel.intermediate,
  }) async {
    final prompt = _buildQuizPrompt(
      type: AiQuizType.multipleChoice,
      entityName: entityName,
      entityType: entityType,
      count: count,
      difficulty: difficulty,
    );
    ChronosLogger.info('Gerando quiz MC: $entityName ($count perguntas)', tag: _tag);
    return _aiService.ask(prompt, mode: AiMode.teacher);
  }

  /// Gera quiz verdadeiro ou falso.
  Future<AiResponse> generateTrueFalse({
    required String entityName,
    required String entityType,
    int count = 5,
  }) async {
    final prompt = _buildQuizPrompt(
      type: AiQuizType.trueFalse,
      entityName: entityName,
      entityType: entityType,
      count: count,
    );
    ChronosLogger.info('Gerando quiz V/F: $entityName ($count perguntas)', tag: _tag);
    return _aiService.ask(prompt, mode: AiMode.teacher);
  }

  /// Gera quiz de resposta curta.
  Future<AiResponse> generateShortAnswer({
    required String entityName,
    required String entityType,
    int count = 3,
  }) async {
    final prompt = _buildQuizPrompt(
      type: AiQuizType.shortAnswer,
      entityName: entityName,
      entityType: entityType,
      count: count,
    );
    ChronosLogger.info('Gerando quiz curta: $entityName ($count perguntas)', tag: _tag);
    return _aiService.ask(prompt, mode: AiMode.teacher);
  }

  /// Gera perguntas discursivas.
  Future<AiResponse> generateDiscursive({
    required String entityName,
    required String entityType,
    int count = 2,
  }) async {
    final prompt = _buildQuizPrompt(
      type: AiQuizType.discursive,
      entityName: entityName,
      entityType: entityType,
      count: count,
    );
    ChronosLogger.info('Gerando quiz discursiva: $entityName ($count perguntas)', tag: _tag);
    return _aiService.ask(prompt, mode: AiMode.detailed);
  }

  /// Gera quiz misto (combina todos os tipos).
  Future<AiResponse> generateMixed({
    required String entityName,
    required String entityType,
  }) async {
    final prompt = 'Gere um quiz completo sobre "$entityName" ($entityType) '
        'usando EXCLUSIVAMENTE a Base de Conhecimento do Chronos.\n\n'
        'Inclua:\n'
        '- 3 perguntas de múltipla escolha (4 opções cada, marque a correta)\n'
        '- 3 perguntas de verdadeiro ou falso (com justificativa)\n'
        '- 2 perguntas de resposta curta (com resposta esperada)\n'
        '- 1 pergunta discursiva (com pontos esperados na resposta)\n\n'
        'Se não houver dados suficientes, informe claramente.';
    ChronosLogger.info('Gerando quiz misto: $entityName', tag: _tag);
    return _aiService.ask(prompt, mode: AiMode.teacher);
  }

  /// Corrige resposta do usuário.
  Future<AiResponse> evaluateAnswer({
    required String question,
    required String userAnswer,
    required String entityName,
  }) async {
    final prompt = 'O aluno respondeu a seguinte pergunta sobre "$entityName":\n\n'
        'Pergunta: $question\n'
        'Resposta do aluno: $userAnswer\n\n'
        'Avalie a resposta:\n'
        '1. A resposta está correta? (Sim/Parcial/Não)\n'
        '2. O que está correto?\n'
        '3. O que está incorreto ou faltando?\n'
        '4. Explicação completa da resposta correta.\n\n'
        'Use EXCLUSIVAMENTE a Base de Conhecimento do Chronos.';
    return _aiService.ask(prompt, mode: AiMode.teacher);
  }

  String _buildQuizPrompt({
    required AiQuizType type,
    required String entityName,
    required String entityType,
    int count = 5,
    ExplanationLevel difficulty = ExplanationLevel.intermediate,
  }) {
    final typeLabel = type.label;
    final diffLabel = difficulty.label;

    return 'Gere $count perguntas do tipo "$typeLabel" sobre "$entityName" ($entityType).\n\n'
        'Nível de dificuldade: $diffLabel.\n\n'
        '${_typeInstructions(type)}\n\n'
        'Use EXCLUSIVAMENTE a Base de Conhecimento do Chronos como fonte.\n'
        'Se não houver dados suficientes, informe claramente:\n'
        '"Ainda não possuo dados suficientes sobre este tema na Base de Conhecimento do Chronos."';
  }

  String _typeInstructions(AiQuizType type) {
    switch (type) {
      case AiQuizType.multipleChoice:
        return 'Para cada pergunta, forneça 4 opções (A, B, C, D) e indique a correta. '
            'Inclua explicação breve de por que a resposta está correta.';
      case AiQuizType.trueFalse:
        return 'Para cada afirmação, indique se é Verdadeiro ou Falso '
            'e forneça justificativa.';
      case AiQuizType.shortAnswer:
        return 'Para cada pergunta, forneça a resposta esperada (1-2 frases) '
            'e palavras-chave que devem estar presentes.';
      case AiQuizType.discursive:
        return 'Para cada pergunta, forneça os pontos esperados na resposta '
            'e um modelo de resposta completa.';
    }
  }
}
