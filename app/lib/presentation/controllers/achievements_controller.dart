import 'package:flutter/foundation.dart';
import '../../core/gamification/achievements_repository.dart';
import '../../core/gamification/gamification_models.dart';
import '../../core/utils/logger.dart';

/// Controller da tela de conquistas.
class AchievementsController extends ChangeNotifier {
  final AchievementsRepository _repository;

  AchievementsController({AchievementsRepository? repository}) : _repository = repository ?? AchievementsRepository();

  bool _isLoading = false;
  String? _error;
  List<UserAchievement> _achievements = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserAchievement> get achievements => _achievements;
  int get unlockedCount => _achievements.where((a) => a.isUnlocked).length;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _achievements = await _repository.getUserAchievements();
      _isLoading = false;
    } catch (e) {
      ChronosLogger.error('Erro ao carregar conquistas: $e', tag: 'AchievementsController', error: e);
      _error = 'Não foi possível carregar as conquistas.';
      _isLoading = false;
    }

    notifyListeners();
  }

  Future<void> refresh() => load();

  /// Atualiza progresso de uma conquista específica.
  Future<void> updateProgress(String achievementId, int progress) async {
    await _repository.updateProgress(achievementId, progress);
    await load();
  }
}
