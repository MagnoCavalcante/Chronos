import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'gamification_cache_service.dart';
import 'gamification_models.dart';
import 'level_calculator.dart';
import 'profile_repository.dart';

/// Repositório responsável por eventos de XP e atualização do perfil.
class XpRepository {
  final SupabaseClient? _providedClient;
  final GamificationCacheService _cache = GamificationCacheService();

  XpRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try {
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient? get client => _client;

  String? get _userId => _client?.auth.currentUser?.id;

  /// Adiciona XP ao usuário, registra o evento e retorna o perfil atualizado.
  Future<XpResult> addXp({
    required int amount,
    required XpSource source,
    String? referenceId,
    String? description,
  }) async {
    if (amount <= 0) return XpResult.noChange();

    final client = _client;
    if (client == null) {
      return await _updateCacheOnly(amount, source, referenceId, description);
    }

    final userId = _userId;
    if (userId == null) return XpResult.noChange();

    try {
      final eventResponse = await client.from('xp_events')
          .insert({
            'user_id': userId,
            'amount': amount,
            'source': source.apiValue,
            'reference_id': referenceId,
            'description': description,
          })
          .select()
          .single();
      final event = XpEvent.fromJson(eventResponse);

      final totalXp = await _fetchTotalXp(client, userId);
      final level = LevelCalculator.levelFromXp(totalXp);

      await client.from('user_profiles')
          .update({
            'total_xp': totalXp,
            'current_level': level,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      final profile = await ProfileRepository(client: client).getProfile();
      final previousLevel = profile?.currentLevel ?? 1;
      final leveledUp = level > previousLevel;

      await _cache.cacheXpEvents([...(await _cache.getXpEvents()), event]);

      return XpResult(
        event: event,
        totalXp: totalXp,
        currentLevel: level,
        leveledUp: leveledUp,
        newLevel: leveledUp ? level : null,
      );
    } catch (e) {
      ChronosLogger.error('Erro ao adicionar XP', error: e);
      return XpResult.noChange();
    }
  }

  Future<int> _fetchTotalXp(SupabaseClient client, String userId) async {
    final response = await client.from('xp_events')
        .select('amount')
        .eq('user_id', userId);
    final list = response as List<dynamic>;
    return list.fold<int>(0, (sum, e) => sum + ((e as Map<String, dynamic>)['amount'] as int? ?? 0));
  }

  Future<XpResult> _updateCacheOnly(int amount, XpSource source, String? referenceId, String? description) async {
    final event = XpEvent(
      id: '',
      userId: _userId ?? '',
      amount: amount,
      source: source,
      referenceId: referenceId,
      description: description,
      createdAt: DateTime.now(),
    );
    final events = [...(await _cache.getXpEvents()), event];
    await _cache.cacheXpEvents(events);

    final profile = await _cache.getProfile();
    if (profile != null) {
      final totalXp = profile.totalXp + amount;
      final level = LevelCalculator.levelFromXp(totalXp);
      await ProfileRepository().updateXpAndLevel(totalXp, level, null);
      return XpResult(
        event: event,
        totalXp: totalXp,
        currentLevel: level,
        leveledUp: level > profile.currentLevel,
      );
    }
    return XpResult(event: event, totalXp: amount, currentLevel: 1);
  }

  Future<List<XpEvent>> getRecentEvents({int limit = 50}) async {
    final client = _client;
    if (client == null) return _cache.getXpEvents();
    try {
      final userId = _userId;
      if (userId == null) return _cache.getXpEvents();
      final response = await client.from('xp_events')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      final list = response.map((e) => XpEvent.fromJson(e)).toList();
      await _cache.cacheXpEvents(list);
      return list;
    } catch (e) {
      ChronosLogger.error('Erro ao carregar eventos de XP', error: e);
      return _cache.getXpEvents();
    }
  }

  Future<int> getTotalXp() async {
    final client = _client;
    if (client == null) {
      final profile = await _cache.getProfile();
      return profile?.totalXp ?? 0;
    }
    try {
      final userId = _userId;
      if (userId == null) return 0;
      return await _fetchTotalXp(client, userId);
    } catch (e) {
      ChronosLogger.error('Erro ao carregar XP total', error: e);
      final profile = await _cache.getProfile();
      return profile?.totalXp ?? 0;
    }
  }
}

/// Resultado de uma operação de ganho de XP.
class XpResult {
  final XpEvent? event;
  final int totalXp;
  final int currentLevel;
  final bool leveledUp;
  final int? newLevel;

  const XpResult({
    this.event,
    this.totalXp = 0,
    this.currentLevel = 1,
    this.leveledUp = false,
    this.newLevel,
  });

  factory XpResult.noChange() => const XpResult();
}
