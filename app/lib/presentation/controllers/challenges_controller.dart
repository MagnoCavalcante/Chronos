import 'package:flutter/foundation.dart';
import '../../core/gamification/challenges_repository.dart';
import '../../core/gamification/gamification_models.dart';
import '../../core/utils/logger.dart';

/// Controller da tela de desafios.
class ChallengesController extends ChangeNotifier {
  final ChallengesRepository _repository;

  ChallengesController({ChallengesRepository? repository}) : _repository = repository ?? ChallengesRepository();

  bool _isLoading = false;
  String? _error;
  List<Challenge> _challenges = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Challenge> get challenges => _challenges;

  List<Challenge> get daily => _challenges.where((c) => c.type == ChallengeType.daily).toList();
  List<Challenge> get weekly => _challenges.where((c) => c.type == ChallengeType.weekly).toList();
  List<Challenge> get monthly => _challenges.where((c) => c.type == ChallengeType.monthly).toList();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _challenges = await _repository.getActiveChallenges();
      _isLoading = false;
    } catch (e) {
      ChronosLogger.error('Erro ao carregar desafios: $e', tag: 'ChallengesController', error: e);
      _error = 'Não foi possível carregar os desafios.';
      _isLoading = false;
    }

    notifyListeners();
  }

  Future<void> refresh() => load();

  /// Incrementa progresso de desafios pelo critério.
  Future<void> progress(ChallengeCriteriaType criteria, int increment) async {
    await _repository.progressChallenge(criteria, increment);
    await load();
  }
}
