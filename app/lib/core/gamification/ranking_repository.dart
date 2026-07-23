import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'gamification_models.dart';

/// Repositório de preparação para ranking futuro.
///
/// Ainda não expõe ranking online, mas já persiste entradas locais
/// e oferece a interface necessária para futuras integrações.
class RankingRepository {
  final SupabaseClient? _providedClient;

  RankingRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try {
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  String? get _userId => _client?.auth.currentUser?.id;

  /// Retorna entradas de ranking do usuário (preparação).
  Future<List<RankingEntry>> getUserEntries() async {
    final client = _client;
    if (client == null) return [];
    try {
      final userId = _userId;
      if (userId == null) return [];
      final response = await client.from('ranking_entries')
          .select()
          .eq('user_id', userId)
          .order('period', ascending: true);
      return response.map((e) => RankingEntry.fromJson(e)).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar ranking', error: e);
      return [];
    }
  }

  /// Atualiza entrada de ranking do usuário para um período.
  Future<RankingEntry?> upsertEntry({required String period, required int totalXp, int? rank}) async {
    final client = _client;
    if (client == null) return null;
    try {
      final userId = _userId;
      if (userId == null) return null;
      final response = await client.from('ranking_entries')
          .upsert({
            'user_id': userId,
            'period': period,
            'total_xp': totalXp,
            'rank': rank,
            'updated_at': DateTime.now().toIso8601String(),
          }, onConflict: 'user_id,period')
          .select()
          .single();
      return RankingEntry.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar ranking', error: e);
      return null;
    }
  }
}
