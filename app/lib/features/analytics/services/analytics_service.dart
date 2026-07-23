import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';
import '../domain/entities/analytics_entities.dart';

/// Serviço de Analytics interno (100% local, sem envio externo).
///
/// Registra localmente:
/// - Quantidade de exportações
/// - Formato mais utilizado
/// - Conteúdo mais compartilhado
/// - Tempo médio de leitura
/// - Conteúdo mais favoritado
///
/// Dados servem apenas para melhorar a experiência do usuário.
class AnalyticsService {
  static const String _tag = 'AnalyticsService';
  static const String _storageKey = 'chronos_local_analytics';
  static const int _maxEvents = 1000;

  final List<AnalyticsEvent> _events = [];

  /// Todos os eventos registrados.
  List<AnalyticsEvent> get events => List.unmodifiable(_events);

  /// Carrega eventos do armazenamento local.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;

      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _events.clear();
      _events.addAll(list.map(AnalyticsEvent.fromJson));
      ChronosLogger.info('Analytics carregado: ${_events.length} eventos', tag: _tag);
    } catch (e) {
      ChronosLogger.error('Erro ao carregar analytics: $e', tag: _tag);
    }
  }

  /// Registra um evento analítico.
  Future<void> track({
    required AnalyticsEventType type,
    required String entityType,
    required String entityId,
    String? format,
    int? durationMs,
  }) async {
    final event = AnalyticsEvent(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_events.length}',
      type: type,
      entityType: entityType,
      entityId: entityId,
      format: format,
      timestamp: DateTime.now(),
      durationMs: durationMs,
    );

    _events.add(event);

    // Limitar tamanho do histórico
    if (_events.length > _maxEvents) {
      _events.removeRange(0, _events.length - _maxEvents);
    }

    await _save();
  }

  /// Gera resumo analítico.
  AnalyticsSummary getSummary() {
    final exports = _events.where((e) => e.type == AnalyticsEventType.export).toList();
    final shares = _events.where((e) => e.type == AnalyticsEventType.share).toList();
    final favorites = _events.where((e) => e.type == AnalyticsEventType.favorite).toList();
    final views = _events.where((e) => e.type == AnalyticsEventType.view).toList();

    // Formato mais usado
    final formatCounts = <String, int>{};
    for (final e in exports) {
      if (e.format != null) {
        formatCounts[e.format!] = (formatCounts[e.format!] ?? 0) + 1;
      }
    }
    String? mostUsedFormat;
    if (formatCounts.isNotEmpty) {
      mostUsedFormat = formatCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    // Conteúdo mais compartilhado
    final shareCounts = <String, int>{};
    for (final e in shares) {
      shareCounts[e.entityId] = (shareCounts[e.entityId] ?? 0) + 1;
    }
    String? mostShared;
    if (shareCounts.isNotEmpty) {
      mostShared = shareCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    // Conteúdo mais favoritado
    final favCounts = <String, int>{};
    for (final e in favorites) {
      favCounts[e.entityId] = (favCounts[e.entityId] ?? 0) + 1;
    }
    String? mostFavorited;
    if (favCounts.isNotEmpty) {
      mostFavorited = favCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    // Tempo médio de leitura
    final readTimes = views.where((e) => e.durationMs != null).map((e) => e.durationMs!).toList();
    final avgReading = readTimes.isNotEmpty
        ? (readTimes.reduce((a, b) => a + b) / readTimes.length).round()
        : 0;

    // Contagem por tipo de entidade
    final entityTypeCounts = <String, int>{};
    for (final e in _events) {
      entityTypeCounts[e.entityType] = (entityTypeCounts[e.entityType] ?? 0) + 1;
    }

    return AnalyticsSummary(
      totalExports: exports.length,
      mostUsedFormat: mostUsedFormat,
      mostSharedContent: mostShared,
      averageReadingTimeMs: avgReading,
      mostFavoritedContent: mostFavorited,
      formatCounts: formatCounts,
      entityTypeCounts: entityTypeCounts,
    );
  }

  /// Limpa todos os dados analíticos.
  Future<void> clear() async {
    _events.clear();
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_events.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, data);
    } catch (e) {
      ChronosLogger.error('Erro ao salvar analytics: $e', tag: _tag);
    }
  }
}
