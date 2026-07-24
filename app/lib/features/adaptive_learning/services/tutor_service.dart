import '../domain/entities/adaptive_learning_entities.dart';

/// Serviço do Tutor Inteligente.
///
/// Gera prompts contextualizados para a IA baseado no perfil
/// do usuário e no modo solicitado. Usa exclusivamente a Base
/// de Conhecimento do Chronos como fonte.
class TutorService {
  final String _userId;

  TutorService({String userId = 'local_user'}) : _userId = userId;

  String get userId => _userId;

  /// Gera prompt para o modo de tutor selecionado.
  String generateTutorPrompt({
    required TutorMode mode,
    required String entityName,
    required String entityType,
    required LearnerProfile profile,
    String? additionalContext,
  }) {
    final levelText = _levelDescription(profile.estimatedLevel);
    final base = 'Você é o Tutor Chronos. O usuário está no nível $levelText. '
        'Use EXCLUSIVAMENTE a Base de Conhecimento do Chronos como fonte. '
        'Conteúdo: $entityName ($entityType).';

    switch (mode) {
      case TutorMode.explainBeginner:
        return '$base\n\nExplique de forma simples, como para alguém que nunca estudou o tema. '
            'Use linguagem acessível, evite jargões acadêmicos.';
      case TutorMode.explainIntermediate:
        return '$base\n\nExplique com profundidade moderada, incluindo causas e consequências. '
            'O aluno já conhece os conceitos básicos.';
      case TutorMode.explainAdvanced:
        return '$base\n\nExplique com profundidade acadêmica, incluindo debates historiográficos, '
            'fontes primárias e diferentes interpretações.';
      case TutorMode.summarize1min:
        return '$base\n\nResuma em no máximo 3 frases curtas (leitura de ~1 minuto). '
            'Foco apenas nos pontos absolutamente essenciais.';
      case TutorMode.summarize5min:
        return '$base\n\nCrie um resumo completo para leitura de ~5 minutos. '
            'Inclua contexto, principais eventos, personagens e consequências.';
      case TutorMode.createAnalogy:
        return '$base\n\nCrie uma analogia criativa relacionando este conteúdo histórico '
            'com situações do cotidiano moderno para facilitar a compreensão.';
      case TutorMode.createPracticalExample:
        return '$base\n\nCrie um exemplo prático ou cenário hipotético que ilustre '
            'os conceitos históricos de forma tangível e memorável.';
      case TutorMode.highlightForExam:
        return '$base\n\nDestaque APENAS os pontos mais cobrados em provas (ENEM, vestibulares). '
            'Liste em tópicos: datas importantes, causas, consequências, personagens-chave.';
    }
  }

  /// Gera explicação contextual após erro em quiz.
  ContextualExplanation generateContextualExplanation({
    required String questionId,
    required String correctAnswer,
    required String entityId,
    required String entityType,
    required String entityName,
    List<String> relatedEvents = const [],
    List<String> relatedCharacters = const [],
  }) {
    final explanation = 'A resposta correta é: $correctAnswer. '
        'Este conteúdo faz parte de $entityName ($entityType). '
        'Revise o material para reforçar o aprendizado.';

    return ContextualExplanation(
      questionId: questionId,
      correctAnswer: correctAnswer,
      explanation: explanation,
      contentLink: entityId,
      relatedEvents: relatedEvents,
      relatedCharacters: relatedCharacters,
    );
  }

  /// Prompt para revisão baseada em dificuldade detectada.
  String generateReviewPrompt({
    required String topic,
    required LearnerProfile profile,
    required double accuracy,
  }) {
    return 'O usuário (${_levelDescription(profile.estimatedLevel)}) tem dificuldade no tema "$topic" '
        '(taxa de acerto: ${(accuracy * 100).toStringAsFixed(0)}%). '
        'Crie uma explicação focada nos pontos que podem estar causando confusão. '
        'Use exemplos simples e destaque diferenças com temas similares.';
  }

  String _levelDescription(LearnerLevel level) {
    switch (level) {
      case LearnerLevel.beginner:
        return 'iniciante';
      case LearnerLevel.intermediate:
        return 'intermediário';
      case LearnerLevel.advanced:
        return 'avançado';
    }
  }
}
