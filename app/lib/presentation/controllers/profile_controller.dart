import 'package:flutter/foundation.dart';
import '../../core/gamification/achievements_repository.dart';
import '../../core/gamification/challenges_repository.dart';
import '../../core/gamification/gamification_models.dart';
import '../../core/gamification/gamification_service.dart';
import '../../core/gamification/titles_repository.dart';
import '../../core/gamification/weekly_summary_repository.dart';
import '../../core/utils/logger.dart';

/// Estado da tela de perfil gamificado.
class ProfileState {
  final bool isLoading;
  final String? error;
  final UserProfile? profile;
  final List<UserAchievement> achievements;
  final List<Title> titles;
  final List<Challenge> challenges;
  final WeeklySummary? weeklySummary;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.profile,
    this.achievements = const [],
    this.titles = const [],
    this.challenges = const [],
    this.weeklySummary,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    UserProfile? profile,
    List<UserAchievement>? achievements,
    List<Title>? titles,
    List<Challenge>? challenges,
    WeeklySummary? weeklySummary,
    bool clearError = false,
  }) => ProfileState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        profile: profile ?? this.profile,
        achievements: achievements ?? this.achievements,
        titles: titles ?? this.titles,
        challenges: challenges ?? this.challenges,
        weeklySummary: weeklySummary ?? this.weeklySummary,
      );

  int get unlockedAchievements => achievements.where((a) => a.isUnlocked).length;
  int get completedChallenges => challenges.where((c) => c.completed).length;
}

/// Controller da tela de perfil.
class ProfileController extends ChangeNotifier {
  final GamificationService _service;
  final AchievementsRepository _achievementsRepository;
  final TitlesRepository _titlesRepository;
  final ChallengesRepository _challengesRepository;
  final WeeklySummaryRepository _weeklySummaryRepository;

  ProfileState _state = const ProfileState();

  ProfileController({
    GamificationService? service,
    AchievementsRepository? achievementsRepository,
    TitlesRepository? titlesRepository,
    ChallengesRepository? challengesRepository,
    WeeklySummaryRepository? weeklySummaryRepository,
  })  : _service = service ?? GamificationService(),
        _achievementsRepository = achievementsRepository ?? AchievementsRepository(),
        _titlesRepository = titlesRepository ?? TitlesRepository(),
        _challengesRepository = challengesRepository ?? ChallengesRepository(),
        _weeklySummaryRepository = weeklySummaryRepository ?? WeeklySummaryRepository();

  ProfileState get state => _state;

  Future<void> load() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getOrCreateProfile(),
        _achievementsRepository.getUserAchievements(),
        _titlesRepository.getUnlockedTitles(),
        _challengesRepository.getActiveChallenges(),
        _weeklySummaryRepository.getCurrentWeekSummary(),
      ]);

      _state = _state.copyWith(
        isLoading: false,
        profile: results[0] as UserProfile?,
        achievements: results[1] as List<UserAchievement>,
        titles: results[2] as List<Title>,
        challenges: results[3] as List<Challenge>,
        weeklySummary: results[4] as WeeklySummary?,
      );
    } catch (e) {
      ChronosLogger.error('Erro ao carregar perfil: $e', tag: 'ProfileController', error: e);
      _state = _state.copyWith(isLoading: false, error: 'Não foi possível carregar o perfil.');
    }

    notifyListeners();
  }

  Future<void> refresh() => load();

  /// Recalcula nível e título manualmente.
  Future<void> recalculateLevel() async {
    final profile = _state.profile;
    if (profile == null) return;
    final titles = await _titlesRepository.getCatalog();
    await _service.getOrCreateProfile();
    final updated = await _service.getOrCreateProfile();
    if (updated != null) {
      _state = _state.copyWith(profile: updated, titles: titles);
      notifyListeners();
    }
  }
}
