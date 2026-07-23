import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'study_models.dart';

/// Repositório para planos de estudo cronológicos.
class StudyPlanRepository {
  final SupabaseClient? _providedClient;
  StudyPlanRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try { return SupabaseConfig.client; } catch (_) { return null; }
  }

  String? get _userId => _client?.auth.currentUser?.id;

  Future<List<StudyPlan>> getPlans() async {
    final client = _client;
    if (client == null || _userId == null) return [];
    try {
      final response = await client.from('study_plans').select().eq('user_id', _userId!).order('created_at', ascending: false);
      return response.map((e) => StudyPlan.fromJson(e)).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar planos', error: e);
      return [];
    }
  }

  Future<StudyPlan?> createPlan({
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final client = _client;
    if (client == null || _userId == null) return null;
    try {
      final response = await client.from('study_plans').insert({
        'user_id': _userId!,
        'title': title,
        'description': description,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      }).select().single();
      return StudyPlan.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao criar plano', error: e);
      return null;
    }
  }

  Future<List<StudyPlanItem>> getItems(String planId) async {
    final client = _client;
    if (client == null) return [];
    try {
      final response = await client.from('study_plan_items').select().eq('plan_id', planId).order('day_number');
      return response.map((e) => StudyPlanItem.fromJson(e)).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar itens do plano', error: e);
      return [];
    }
  }

  Future<StudyPlanItem?> addItem({
    required String planId,
    required int dayNumber,
    required String title,
    String? entityType,
    String? entityId,
  }) async {
    final client = _client;
    if (client == null) return null;
    try {
      final response = await client.from('study_plan_items').insert({
        'plan_id': planId,
        'day_number': dayNumber,
        'title': title,
        'entity_type': entityType,
        'entity_id': entityId,
      }).select().single();
      return StudyPlanItem.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao adicionar item no plano', error: e);
      return null;
    }
  }

  Future<bool> toggleItemComplete(String itemId, bool completed) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('study_plan_items').update({'completed': completed}).eq('id', itemId);
      return true;
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar item do plano', error: e);
      return false;
    }
  }

  Future<bool> deletePlan(String id) async {
    final client = _client;
    if (client == null || _userId == null) return false;
    try {
      await client.from('study_plans').delete().eq('id', id);
      return true;
    } catch (e) {
      ChronosLogger.error('Erro ao excluir plano', error: e);
      return false;
    }
  }
}
