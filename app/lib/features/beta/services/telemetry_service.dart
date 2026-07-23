import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';

/// Dados de telemetria local do CHRONOS Beta.
class TelemetrySnapshot {
  final int totalSessionsCount;
  final int totalSearches;
  final int totalCrashes;
  final int totalErrors;
  final Duration totalUsageTime;
  final Map<String, int> featureUsage;
  final DateTime lastUpdated;

  const TelemetrySnapshot({
    this.totalSessionsCount = 0,
    this.totalSearches = 0,
    this.totalCrashes = 0,
    this.totalErrors = 0,
    this.totalUsageTime = Duration.zero,
    this.featureUsage = const {},
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'totalSessionsCount': totalSessionsCount,
        'totalSearches': totalSearches,
        'totalCrashes': totalCrashes,
        'totalErrors': totalErrors,
        'totalUsageTimeMs': totalUsageTime.inMilliseconds,
        'featureUsage': featureUsage,
        'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      };

  factory TelemetrySnapshot.fromJson(Map<String, dynamic> json) => TelemetrySnapshot(
        totalSessionsCount: json['totalSessionsCount'] as int? ?? 0,
        totalSearches: json['totalSearches'] as int? ?? 0,
        totalCrashes: json['totalCrashes'] as int? ?? 0,
        totalErrors: json['totalErrors'] as int? ?? 0,
        totalUsageTime: Duration(milliseconds: json['totalUsageTimeMs'] as int? ?? 0),
        featureUsage: (json['featureUsage'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as int),
            ) ??
            {},
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['lastUpdated'] as int? ?? 0),
      );
}

/// Serviço de Telemetria Local do CHRONOS Beta.
///
/// Registra métricas de uso 100% locais sem envio externo.
/// Preserva privacidade total do usuário.
class TelemetryService extends ChangeNotifier {
  static const String _tag = 'TelemetryService';
  static const String _storageKey = 'chronos_telemetry';

  int _sessions = 0;
  int _searches = 0;
  int _crashes = 0;
  int _errors = 0;
  Duration _usageTime = Duration.zero;
  final Map<String, int> _featureUsage = {};
  DateTime? _sessionStart;

  /// Snapshot atual da telemetria.
  TelemetrySnapshot get snapshot => TelemetrySnapshot(
        totalSessionsCount: _sessions,
        totalSearches: _searches,
        totalCrashes: _crashes,
        totalErrors: _errors,
        totalUsageTime: _usageTime,
        featureUsage: Map.unmodifiable(_featureUsage),
        lastUpdated: DateTime.now(),
      );

  /// Carrega telemetria salva.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;

      final data = TelemetrySnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _sessions = data.totalSessionsCount;
      _searches = data.totalSearches;
      _crashes = data.totalCrashes;
      _errors = data.totalErrors;
      _usageTime = data.totalUsageTime;
      _featureUsage.addAll(data.featureUsage);
    } catch (e) {
      ChronosLogger.error('Erro ao carregar telemetria: $e', tag: _tag);
    }
  }

  /// Registra início de sessão.
  void startSession() {
    _sessions++;
    _sessionStart = DateTime.now();
    _save();
  }

  /// Registra fim de sessão e calcula tempo.
  void endSession() {
    if (_sessionStart != null) {
      _usageTime += DateTime.now().difference(_sessionStart!);
      _sessionStart = null;
      _save();
    }
  }

  /// Registra uma pesquisa.
  void trackSearch() {
    _searches++;
    _save();
    notifyListeners();
  }

  /// Registra uso de uma funcionalidade.
  void trackFeature(String featureName) {
    _featureUsage[featureName] = (_featureUsage[featureName] ?? 0) + 1;
    _save();
    notifyListeners();
  }

  /// Registra um crash.
  void trackCrash() {
    _crashes++;
    _save();
    notifyListeners();
  }

  /// Registra um erro não-fatal.
  void trackError() {
    _errors++;
    _save();
    notifyListeners();
  }

  /// Reseta toda a telemetria.
  Future<void> reset() async {
    _sessions = 0;
    _searches = 0;
    _crashes = 0;
    _errors = 0;
    _usageTime = Duration.zero;
    _featureUsage.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(snapshot.toJson()));
    } catch (_) {}
  }
}
