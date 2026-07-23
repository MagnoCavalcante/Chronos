import '../domain/entities/learning_entities.dart';
import '../domain/repositories/learning_repository.dart';

/// Serviço de Metas de Estudo.
///
/// Permite criar, acompanhar e concluir metas como:
/// - Estudar 20 minutos por dia
/// - Ler 3 personagens
/// - Concluir 1 civilização
/// - Estudar 5 eventos
class GoalsService {
  final LearningRepository _repository;
  final String _userId;

  GoalsService({
    required LearningRepository repository,
    String userId = 'local_user',
  })  : _repository = repository,
        _userId = userId;

  /// Obtém todas as metas do usuário.
  Future<List<StudyGoal>> getGoals() async {
    return _repository.getGoals(_userId);
  }

  /// Obtém metas ativas (não concluídas).
  Future<List<StudyGoal>> getActiveGoals() async {
    final all = await getGoals();
    return all.where((g) => !g.completed).toList();
  }

  /// Obtém metas concluídas.
  Future<List<StudyGoal>> getCompletedGoals() async {
    final all = await getGoals();
    return all.where((g) => g.completed).toList();
  }

  /// Cria uma nova meta.
  Future<void> createGoal({
    required String title,
    required GoalType type,
    required int targetValue,
    String description = '',
    DateTime? deadline,
  }) async {
    final goal = StudyGoal(
      id: '',
      userId: _userId,
      title: title,
      description: description,
      type: type,
      targetValue: targetValue,
      createdAt: DateTime.now(),
      deadline: deadline,
    );
    await _repository.createGoal(goal);
  }

  /// Atualiza progresso de uma meta.
  Future<void> updateProgress(String goalId, int currentValue) async {
    await _repository.updateGoalProgress(goalId, currentValue);
  }

  /// Incrementa progresso de metas por tipo (chamado automaticamente).
  Future<void> incrementByType(GoalType type, {int amount = 1}) async {
    final goals = await getActiveGoals();
    for (final goal in goals.where((g) => g.type == type)) {
      final newValue = goal.currentValue + amount;
      await _repository.updateGoalProgress(goal.id, newValue);
      if (newValue >= goal.targetValue) {
        await _repository.completeGoal(goal.id);
      }
    }
  }

  /// Marca meta como concluída manualmente.
  Future<void> completeGoal(String goalId) async {
    await _repository.completeGoal(goalId);
  }

  /// Cria metas padrão para um novo usuário.
  Future<void> createDefaultGoals() async {
    final existing = await getGoals();
    if (existing.isNotEmpty) return;

    await createGoal(
      title: 'Estudar 20 minutos por dia',
      type: GoalType.dailyMinutes,
      targetValue: 20,
      description: 'Dedique 20 minutos diários ao estudo de História.',
    );
    await createGoal(
      title: 'Ler 3 personagens históricos',
      type: GoalType.readCharacters,
      targetValue: 3,
      description: 'Explore a vida de 3 personagens diferentes.',
    );
    await createGoal(
      title: 'Estudar 5 eventos',
      type: GoalType.readEvents,
      targetValue: 5,
      description: 'Conheça 5 eventos que mudaram a história.',
    );
  }
}
