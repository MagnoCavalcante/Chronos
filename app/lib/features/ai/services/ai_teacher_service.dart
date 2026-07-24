import '../../../core/utils/logger.dart';
import '../../adaptive_learning/domain/entities/adaptive_learning_entities.dart';
import '../../adaptive_learning/domain/repositories/adaptive_learning_repository.dart';
import '../domain/entities/ai_entities.dart';
import '../domain/entities/ai_teacher_entities.dart';
import 'ai_service.dart';

/// Serviço do Tutor de IA (Chronos AI Teacher).
///
/// Transforma a IA do Chronos em professor particular de História.
/// Usa exclusivamente a Base de Conhecimento do Chronos como fonte.
/// Quando não há dados suficientes, informa claramente ao usuário.
///
/// Funcionalidades:
/// - Chat inteligente com contexto da página
/// - Explicações em 4 níveis (básico, intermediário, avançado, acadêmico)
/// - Comparações estruturadas em tabela
/// - Consultas de linha do tempo
/// - Relações históricas
/// - Sugestões automáticas pós-conteúdo
class AiTeacherService {
  final AiService _aiService;
  final AdaptiveLearningRepository _adaptiveRepo;
  final String _userId;

  static const _tag = 'AiTeacherService';

  static const _noDataResponse =
      'Ainda não possuo dados suficientes sobre este tema na Base de Conhecimento do Chronos.';

  AiTeacherService({
    required AiService aiService,
    required AdaptiveLearningRepository adaptiveRepository,
    String userId = 'local_user',
  })  : _aiService = aiService,
        _adaptiveRepo = adaptiveRepository,
        _userId = userId;

  // ============================================================
  // 1. Chat Inteligente
  // ============================================================

  /// Pergunta livre ao tutor.
  Future<AiResponse> ask(String question, {ExplanationLevel? level}) async {
    final mode = _levelToMode(level);
    ChronosLogger.info('Tutor ask: "$question" (level: ${level?.name ?? "auto"})', tag: _tag);
    return _aiService.ask(question, mode: mode);
  }

  // ============================================================
  // 2. IA Contextual (Perguntar ao Tutor na página)
  // ============================================================

  /// Pergunta contextualizada à página aberta.
  Future<AiResponse> askInContext({
    required String question,
    required PageContext context,
    ExplanationLevel? level,
  }) async {
    final contextPrompt = 'Contexto: O usuário está estudando "${context.entityName}" '
        '(${context.entityType}). ${context.summary}\n\n'
        'Responda usando EXCLUSIVAMENTE informações relacionadas a ${context.entityName} '
        'e suas referências na Base de Conhecimento do Chronos.\n\n'
        'Pergunta: $question';
    ChronosLogger.info('Tutor contextual: "${context.entityName}" → "$question"', tag: _tag);
    return _aiService.ask(contextPrompt, mode: _levelToMode(level));
  }

  // ============================================================
  // 3. Explicações em Níveis
  // ============================================================

  /// Gera explicação de um tema no nível especificado.
  Future<AiResponse> explain({
    required String topic,
    required ExplanationLevel level,
  }) async {
    final instruction = _levelInstruction(level);
    final prompt = '$instruction\n\nTema: $topic\n\n'
        'Use EXCLUSIVAMENTE a Base de Conhecimento do Chronos. '
        'Se não houver dados suficientes, informe: "$_noDataResponse"';
    return _aiService.ask(prompt, mode: _levelToMode(level));
  }

  // ============================================================
  // 4. Comparações
  // ============================================================

  /// Gera comparação entre duas entidades históricas.
  Future<AiResponse> compare({
    required String entityA,
    required String entityB,
  }) async {
    final prompt = 'Compare $entityA × $entityB.\n\n'
        'Gere uma comparação estruturada cobrindo: período, localização, '
        'conquistas, legado, causas, consequências.\n\n'
        'Use EXCLUSIVAMENTE a Base de Conhecimento do Chronos.';
    ChronosLogger.info('Tutor compare: $entityA × $entityB', tag: _tag);
    return _aiService.ask(prompt, mode: AiMode.comparison);
  }

  // ============================================================
  // 5. Linha do Tempo Inteligente
  // ============================================================

  /// Responde perguntas temporais.
  Future<AiResponse> askTimeline(String question) async {
    final prompt = 'Responda esta pergunta temporal usando a linha do tempo '
        'da Base de Conhecimento do Chronos:\n\n$question\n\n'
        'Organize cronologicamente. Se não houver dados: "$_noDataResponse"';
    return _aiService.ask(prompt, mode: AiMode.timeline);
  }

  // ============================================================
  // 6. Relações Históricas
  // ============================================================

  /// Mostra cadeia de influência entre duas entidades.
  Future<AiResponse> explainRelation({
    required String entityA,
    required String entityB,
  }) async {
    final prompt = 'Explique a relação histórica entre $entityA e $entityB.\n\n'
        'Mostre a cadeia completa de influência, eventos conectores e consequências.\n\n'
        'Use EXCLUSIVAMENTE a Base de Conhecimento do Chronos.';
    return _aiService.ask(prompt, mode: AiMode.detailed);
  }

  // ============================================================
  // 7. Sugestões Automáticas Pós-Conteúdo
  // ============================================================

  /// Gera sugestões após o usuário terminar um conteúdo.
  List<TutorSuggestion> getPostContentSuggestions(String entityName) {
    return [
      TutorSuggestion(
        type: TutorSuggestionType.summary,
        label: 'Quer um resumo?',
        description: 'Posso resumir $entityName para você.',
      ),
      TutorSuggestion(
        type: TutorSuggestionType.quiz,
        label: 'Quer um quiz?',
        description: 'Vou testar seu conhecimento sobre $entityName.',
      ),
      TutorSuggestion(
        type: TutorSuggestionType.deepen,
        label: 'Quer aprofundar?',
        description: 'Posso explorar $entityName em mais detalhes.',
      ),
      TutorSuggestion(
        type: TutorSuggestionType.nextContent,
        label: 'Estudar o próximo assunto?',
        description: 'Posso recomendar o que estudar em seguida.',
      ),
    ];
  }

  // ============================================================
  // 11. Recomendações pós-conversa
  // ============================================================

  /// Gera recomendações baseadas na conversa atual.
  Future<AiResponse> getPostConversationRecommendations(String topic) async {
    final prompt = 'Baseado no estudo de "$topic" na Base de Conhecimento do Chronos, '
        'recomende:\n'
        '- Personagens históricos relacionados\n'
        '- Eventos importantes conectados\n'
        '- Trilhas de aprendizagem relevantes\n'
        '- Quizzes sugeridos\n\n'
        'Use EXCLUSIVAMENTE a Base de Conhecimento do Chronos.';
    return _aiService.ask(prompt, mode: AiMode.normal);
  }

  // ============================================================
  // Helpers
  // ============================================================

  AiMode? _levelToMode(ExplanationLevel? level) {
    if (level == null) return null;
    switch (level) {
      case ExplanationLevel.basic:
        return AiMode.teacher;
      case ExplanationLevel.intermediate:
        return AiMode.normal;
      case ExplanationLevel.advanced:
        return AiMode.detailed;
      case ExplanationLevel.academic:
        return AiMode.detailed;
    }
  }

  String _levelInstruction(ExplanationLevel level) {
    switch (level) {
      case ExplanationLevel.basic:
        return 'Explique de forma simples, como para alguém de 12 anos. '
            'Use linguagem acessível, sem jargões.';
      case ExplanationLevel.intermediate:
        return 'Explique com profundidade moderada, incluindo causas e consequências.';
      case ExplanationLevel.advanced:
        return 'Explique com profundidade, incluindo debates historiográficos e múltiplas interpretações.';
      case ExplanationLevel.academic:
        return 'Explique em nível acadêmico, com referências a fontes primárias, '
            'debates entre historiadores e análise crítica.';
    }
  }
}
