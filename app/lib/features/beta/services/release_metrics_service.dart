import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';

/// Métricas de uma versão para comparação.
class VersionMetrics {
  final String version;
  final int coldStartMs;
  final int warmStartMs;
  final int avgSearchMs;
  final int memoryUsageMb;
  final int errorCount;
  final int queryCount;
  final DateTime recordedAt;

  const VersionMetrics({
    required this.version,
    required this.coldStartMs,
    required this.warmStartMs,
    required this.avgSearchMs,
    required this.memoryUsageMb,
    required this.errorCount,
    required this.queryCount,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'coldStartMs': coldStartMs,
        'warmStartMs': warmStartMs,
        'avgSearchMs': avgSearchMs,
        'memoryUsageMb': memoryUsageMb,
        'errorCount': errorCount,
        'queryCount': queryCount,
        'recordedAt': recordedAt.millisecondsSinceEpoch,
      };

  factory VersionMetrics.fromJson(Map<String, dynamic> json) => VersionMetrics(
        version: json['version'] as String,
        coldStartMs: json['coldStartMs'] as int? ?? 0,
        warmStartMs: json['warmStartMs'] as int? ?? 0,
        avgSearchMs: json['avgSearchMs'] as int? ?? 0,
        memoryUsageMb: json['memoryUsageMb'] as int? ?? 0,
        errorCount: json['errorCount'] as int? ?? 0,
        queryCount: json['queryCount'] as int? ?? 0,
        recordedAt: DateTime.fromMillisecondsSinceEpoch(json['recordedAt'] as int? ?? 0),
      );
}

/// Resultado de comparação entre versões.
class MetricsComparison {
  final VersionMetrics? previous;
  final VersionMetrics current;

  const MetricsComparison({this.previous, required this.current});

  /// Variação percentual do cold start.
  double? get coldStartDelta => _delta(previous?.coldStartMs, current.coldStartMs);

  /// Variação percentual do warm start.
  double? get warmStartDelta => _delta(previous?.warmStartMs, current.warmStartMs);

  /// Variação percentual de memória.
  double? get memoryDelta => _delta(previous?.memoryUsageMb, current.memoryUsageMb);

  /// Variação percentual de erros.
  double? get errorDelta => _delta(previous?.errorCount, current.errorCount);

  double? _delta(int? prev, int curr) {
    if (prev == null || prev == 0) return null;
    return ((curr - prev) / prev) * 100;
  }

  /// Resumo textual da comparação.
  String get summary {
    if (previous == null) return 'Primeira medição (sem comparação anterior)';
    final buffer = StringBuffer();
    buffer.writeln('Comparação: ${previous!.version} → ${current.version}');
    if (coldStartDelta != null) {
      buffer.writeln('  Cold Start: ${coldStartDelta! > 0 ? '+' : ''}${coldStartDelta!.toStringAsFixed(1)}%');
    }
    if (memoryDelta != null) {
      buffer.writeln('  Memória: ${memoryDelta! > 0 ? '+' : ''}${memoryDelta!.toStringAsFixed(1)}%');
    }
    if (errorDelta != null) {
      buffer.writeln('  Erros: ${errorDelta! > 0 ? '+' : ''}${errorDelta!.toStringAsFixed(1)}%');
    }
    return buffer.toString();
  }
}

/// Serviço de Release Metrics do CHRONOS Beta.
///
/// Compara automaticamente métricas entre versões.
class ReleaseMetricsService {
  static const String _tag = 'ReleaseMetrics';
  static const String _storageKey = 'chronos_release_metrics';

  final List<VersionMetrics> _history = [];

  /// Histórico de métricas.
  List<VersionMetrics> get history => List.unmodifiable(_history);

  /// Carrega histórico.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _history.clear();
      _history.addAll(list.map(VersionMetrics.fromJson));
    } catch (e) {
      ChronosLogger.error('Erro ao carregar metrics: $e', tag: _tag);
    }
  }

  /// Registra métricas da versão atual.
  Future<void> record(VersionMetrics metrics) async {
    _history.add(metrics);
    await _save();
    ChronosLogger.info('Métricas registradas: ${metrics.version}', tag: _tag);
  }

  /// Compara versão atual com a anterior.
  MetricsComparison compare() {
    if (_history.isEmpty) {
      return MetricsComparison(
        current: VersionMetrics(
          version: '1.0.0-beta.1',
          coldStartMs: 0,
          warmStartMs: 0,
          avgSearchMs: 0,
          memoryUsageMb: 0,
          errorCount: 0,
          queryCount: 0,
          recordedAt: DateTime.now(),
        ),
      );
    }
    final current = _history.last;
    final previous = _history.length > 1 ? _history[_history.length - 2] : null;
    return MetricsComparison(previous: previous, current: current);
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_history.map((m) => m.toJson()).toList());
      await prefs.setString(_storageKey, data);
    } catch (e) {
      ChronosLogger.error('Erro ao salvar metrics: $e', tag: _tag);
    }
  }
}
