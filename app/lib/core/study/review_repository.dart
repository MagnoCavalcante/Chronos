import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'study_models.dart';

/// Repositório para itens marcados para revisão futura.
class ReviewRepository {
  final SupabaseClient? _providedClient;
  ReviewRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try { return SupabaseConfig.client; } catch (_) { return null; }
  }

  String? get _userId => _client?.auth.currentUser?.id;

  Future<List<ReviewItem>> getPendingReviews({DateTime? date}) async {
    final client = _client;
    if (client == null || _userId == null) return [];
    try {
      final target = date ?? DateTime.now();
      final dateStr = '${target.year}-${target.month.toString().padLeft(2, '0')}-${target.day.toString().padLeft(2, '0')}';
      final response = await client.from('review_items')
          .select()
          .eq('user_id', _userId!)
          .lte('review_date', dateStr)
          .filter('reviewed_at', 'is', null)
          .order('review_date', ascending: true);
      return response.map((e) => ReviewItem.fromJson(e)).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar revisões', error: e);
      return [];
    }
  }

  Future<ReviewItem?> scheduleReview({
    required String entityType,
    required String entityId,
    required int intervalDays,
  }) async {
    final client = _client;
    if (client == null || _userId == null) return null;
    try {
      final reviewDate = DateTime.now().add(Duration(days: intervalDays));
      final response = await client.from('review_items').insert({
        'user_id': _userId!,
        'entity_type': entityType,
        'entity_id': entityId,
        'review_date': reviewDate.toIso8601String(),
        'interval_days': intervalDays,
      }).select().single();
      return ReviewItem.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao agendar revisão', error: e);
      return null;
    }
  }

  Future<bool> markReviewed(String reviewId) async {
    final client = _client;
    if (client == null || _userId == null) return false;
    try {
      await client.from('review_items').update({'reviewed_at': DateTime.now().toIso8601String()}).eq('id', reviewId);
      return true;
    } catch (e) {
      ChronosLogger.error('Erro ao marcar revisão', error: e);
      return false;
    }
  }
}
