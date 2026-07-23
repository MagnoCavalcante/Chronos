import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'gamification_cache_service.dart';
import 'gamification_models.dart';

/// Repositório de desafios diários, semanais e mensais.
class ChallengesRepository {
  final SupabaseClient? _providedClient;
  final GamificationCacheService _cache = GamificationCacheService();

  ChallengesRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try {
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  String? get _userId => _client?.auth.currentUser?.id;

  static final _templates = [
    _ChallengeTemplate(ChallengeType.daily, 'study_minutes', 'Estudar 20 minutos', 'Dedique 20 minutos aos estudos hoje.', 20, 20),
    _ChallengeTemplate(ChallengeType.daily, 'view_count', 'Ler 5 personagens', 'Visualize 5 personagens históricos.', 5, 10),
    _ChallengeTemplate(ChallengeType.daily, 'complete_count', 'Concluir 2 eventos', 'Complete o estudo de 2 eventos.', 2, 10),
    _ChallengeTemplate(ChallengeType.daily, 'search_count', 'Pesquisar 10 vezes', 'Realize 10 pesquisas.', 10, 15),
    _ChallengeTemplate(ChallengeType.weekly, 'study_minutes', 'Estudar 2 horas', 'Acumule 120 minutos de estudo na semana.', 120, 100),
    _ChallengeTemplate(ChallengeType.weekly, 'view_count', 'Explorar 30 conteúdos', 'Visualize 30 conteúdos diferentes.', 30, 75),
    _ChallengeTemplate(ChallengeType.monthly, 'create_collection', 'Criar uma coleção', 'Monte uma nova coleção de estudos.', 1, 50),
  ];

  Future<List<Challenge>> getActiveChallenges() async {
    final client = _client;
    if (client == null) return _cache.getChallenges();
    try {
      final userId = _userId;
      if (userId == null) return _cache.getChallenges();

      final now = DateTime.now().toUtc();
      final response = await client.from('challenges')
          .select()
          .eq('user_id', userId)
          .gte('ends_at', now.toIso8601String())
          .order('created_at', ascending: true);

      var list = response.map((e) => Challenge.fromJson(e)).toList();
      list = await _ensureChallenges(client, userId, list);
      await _cache.cacheChallenges(list);
      return list;
    } catch (e) {
      ChronosLogger.error('Erro ao carregar desafios', error: e);
      return _cache.getChallenges();
    }
  }

  Future<List<Challenge>> _ensureChallenges(SupabaseClient client, String userId, List<Challenge> existing) async {
    final now = DateTime.now();
    final ranges = _dateRanges(now);
    final neededTypes = {ChallengeType.daily, ChallengeType.weekly, ChallengeType.monthly};
    final presentTypes = existing.map((c) => c.type).toSet();

    final created = <Challenge>[];
    for (final type in neededTypes.difference(presentTypes)) {
      final range = ranges[type]!;
      final templates = _templates.where((t) => t.type == type).toList();
      if (templates.isEmpty) continue;
      final template = templates[now.day % templates.length];
      final newChallenge = await _createChallenge(client, userId, template, range.$1, range.$2);
      if (newChallenge != null) created.add(newChallenge);
    }
    return [...existing, ...created];
  }

  Future<Challenge?> _createChallenge(
    SupabaseClient client,
    String userId,
    _ChallengeTemplate template,
    DateTime startsAt,
    DateTime endsAt,
  ) async {
    try {
      final response = await client.from('challenges').insert({
        'user_id': userId,
        'type': template.type.apiValue,
        'title': template.title,
        'description': template.description,
        'criteria_type': template.criteriaType,
        'target_value': template.targetValue,
        'current_value': 0,
        'reward_xp': template.rewardXp,
        'starts_at': startsAt.toUtc().toIso8601String(),
        'ends_at': endsAt.toUtc().toIso8601String(),
      }).select().single();
      return Challenge.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao criar desafio', error: e);
      return null;
    }
  }

  Map<ChallengeType, (DateTime, DateTime)> _dateRanges(DateTime now) {
    final local = DateTime(now.year, now.month, now.day);
    final dailyEnd = local.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    final weekStart = local.subtract(Duration(days: now.weekday % 7));
    final weekEnd = weekStart.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));
    final monthEnd = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));
    return {
      ChallengeType.daily: (local, dailyEnd),
      ChallengeType.weekly: (weekStart, weekEnd),
      ChallengeType.monthly: (DateTime(now.year, now.month, 1), monthEnd),
    };
  }

  /// Incrementa o progresso de desafios ativos de acordo com o critério.
  Future<List<Challenge>> progressChallenge(ChallengeCriteriaType criteriaType, int increment) async {
    final client = _client;
    if (client == null) return _cache.getChallenges();
    try {
      final userId = _userId;
      if (userId == null) return _cache.getChallenges();
      final challenges = await getActiveChallenges();
      final updated = <Challenge>[];
      for (final challenge in challenges) {
        if (challenge.criteriaType != criteriaType || challenge.completed) continue;
        final newValue = (challenge.currentValue + increment).clamp(0, challenge.targetValue);
        final completed = newValue >= challenge.targetValue;
        await client.from('challenges')
            .update({
              'current_value': newValue,
              'completed': completed,
              'completed_at': completed ? DateTime.now().toIso8601String() : null,
            })
            .eq('id', challenge.id);
        updated.add(challenge);
      }
      return getActiveChallenges();
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar progresso de desafio', error: e);
      return _cache.getChallenges();
    }
  }
}

/// Template interno de desafio.
class _ChallengeTemplate {
  final ChallengeType type;
  final String criteriaType;
  final String title;
  final String description;
  final int targetValue;
  final int rewardXp;

  const _ChallengeTemplate(this.type, this.criteriaType, this.title, this.description, this.targetValue, this.rewardXp);
}
