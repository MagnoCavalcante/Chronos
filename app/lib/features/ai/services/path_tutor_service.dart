import '../../../core/utils/logger.dart';
import '../../learning_paths/domain/entities/learning_path_entities.dart';
import '../../learning_paths/domain/repositories/learning_paths_repository.dart';
import '../domain/entities/ai_entities.dart';
import '../domain/entities/ai_teacher_entities.dart';
import 'ai_service.dart';

/// Serviço do Tutor da Trilha.
///
/// Dentro das Trilhas de Aprendizagem, o tutor pode:
/// - Explicar módulos
/// - Revisar conteúdo com o aluno
/// - Propor exercícios práticos
class PathTutorService {
  final AiService _aiService;
  final LearningPathsRepository _pathsRepo;

  static const _tag = 'PathTutorService';

  PathTutorService({
    required AiService aiService,
    required LearningPathsRepository pathsRepository,
  })  : _aiService = aiService,
        _pathsRepo = pathsRepository;

  /// Explica um módulo da trilha.
  Future<AiResponse> explainModule({
    required String pathId,
    required String moduleId,
    ExplanationLevel level = ExplanationLevel.intermediate,
  }) async {
    final path = await _pathsRepo.getPath(pathId);
    final modules = await _pathsRepo.getModules(pathId);
    final module = modules.firstWhere(
      (m) => m.id == moduleId,
      orElse: () => modules.first,
    );

    final prompt = 'Trilha: ${path?.name ?? "Trilha"}\n'
        'Módulo: ${module.title}\n'
        'Descrição: ${module.description}\n\n'
        '${_levelInstruction(level)}\n\n'
        'Explique este módulo de forma clara e estruturada. '
        'Use EXCLUSIVAMENTE a Base de Conhecimento do Chronos.';

    ChronosLogger.info('Path tutor explain: ${module.title}', tag: _tag);
    return _aiService.ask(prompt, mode: AiMode.teacher);
  }

  /// Revisa um módulo com o aluno.
  Future<AiResponse> reviewModule({
    required String pathId,
    required String moduleId,
  }) async {
    final modules = await _pathsRepo.getModules(pathId);
    final module = modules.firstWhere(
      (m) => m.id == moduleId,
      orElse: () => modules.first,
    );
    final contents = await _pathsRepo.getModuleContents(moduleId);
    final contentNames = contents.map((c) => c.entityName).join(', ');

    final prompt = 'Vamos revisar o módulo "${module.title}".\n'
        'Conteúdos abordados: $contentNames.\n\n'
        'Faça uma revisão estruturada:\n'
        '1. Resumo dos pontos principais\n'
        '2. Conceitos-chave que o aluno deve lembrar\n'
        '3. Conexões com outros temas\n'
        '4. Uma pergunta de revisão\n\n'
        'Use EXCLUSIVAMENTE a Base de Conhecimento do Chronos.';

    ChronosLogger.info('Path tutor review: ${module.title}', tag: _tag);
    return _aiService.ask(prompt, mode: AiMode.teacher);
  }

  /// Propõe exercícios práticos sobre o módulo.
  Future<AiResponse> practiceModule({
    required String pathId,
    required String moduleId,
  }) async {
    final modules = await _pathsRepo.getModules(pathId);
    final module = modules.firstWhere(
      (m) => m.id == moduleId,
      orElse: () => modules.first,
    );

    final prompt = 'Vamos praticar o módulo "${module.title}".\n\n'
        'Crie 5 exercícios variados:\n'
        '- 2 perguntas de múltipla escolha\n'
        '- 1 verdadeiro ou falso\n'
        '- 1 pergunta de associação\n'
        '- 1 pergunta discursiva breve\n\n'
        'Use EXCLUSIVAMENTE a Base de Conhecimento do Chronos.';

    ChronosLogger.info('Path tutor practice: ${module.title}', tag: _tag);
    return _aiService.ask(prompt, mode: AiMode.teacher);
  }

  /// Retorna sugestões do tutor para o módulo atual.
  List<TutorSuggestion> getModuleSuggestions(String moduleName) {
    return [
      TutorSuggestion(
        type: TutorSuggestionType.summary,
        label: 'Posso explicar este módulo.',
        description: 'Vou explicar "$moduleName" de forma clara.',
      ),
      TutorSuggestion(
        type: TutorSuggestionType.quiz,
        label: 'Posso revisar com você.',
        description: 'Vamos revisar o que aprendemos em "$moduleName".',
      ),
      TutorSuggestion(
        type: TutorSuggestionType.deepen,
        label: 'Vamos praticar?',
        description: 'Exercícios sobre "$moduleName" para fixar.',
      ),
    ];
  }

  String _levelInstruction(ExplanationLevel level) {
    switch (level) {
      case ExplanationLevel.basic:
        return 'Explique de forma simples, como para alguém de 12 anos.';
      case ExplanationLevel.intermediate:
        return 'Explique com profundidade moderada, incluindo causas e consequências.';
      case ExplanationLevel.advanced:
        return 'Explique em profundidade com múltiplas perspectivas historiográficas.';
      case ExplanationLevel.academic:
        return 'Explique em nível acadêmico, com fontes primárias e debates.';
    }
  }
}
