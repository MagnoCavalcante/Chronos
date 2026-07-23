import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';

/// Relatório de erro capturado pelo Feedback Assistant.
class ErrorReport {
  final String id;
  final String errorMessage;
  final String? stackTrace;
  final String? userDescription;
  final String? screenContext;
  final DateTime timestamp;

  const ErrorReport({
    required this.id,
    required this.errorMessage,
    this.stackTrace,
    this.userDescription,
    this.screenContext,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'errorMessage': errorMessage,
        'stackTrace': stackTrace,
        'userDescription': userDescription,
        'screenContext': screenContext,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory ErrorReport.fromJson(Map<String, dynamic> json) => ErrorReport(
        id: json['id'] as String,
        errorMessage: json['errorMessage'] as String,
        stackTrace: json['stackTrace'] as String?,
        userDescription: json['userDescription'] as String?,
        screenContext: json['screenContext'] as String?,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      );
}

/// Feedback Assistant do CHRONOS Beta.
///
/// Quando ocorre um erro inesperado, oferece ao usuário:
/// - Enviar relatório
/// - Descrever o problema
/// - Anexar captura de tela (preparação)
class FeedbackAssistantService extends ChangeNotifier {
  static const String _tag = 'FeedbackAssistant';
  static const String _storageKey = 'chronos_error_reports';

  final List<ErrorReport> _reports = [];

  /// Relatórios de erro capturados.
  List<ErrorReport> get reports => List.unmodifiable(_reports);

  /// Total de relatórios.
  int get totalReports => _reports.length;

  /// Carrega relatórios salvos.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _reports.clear();
      _reports.addAll(list.map(ErrorReport.fromJson));
    } catch (e) {
      ChronosLogger.error('Erro ao carregar reports: $e', tag: _tag);
    }
  }

  /// Captura um erro automaticamente.
  Future<void> captureError({
    required Object error,
    StackTrace? stackTrace,
    String? screenContext,
  }) async {
    final report = ErrorReport(
      id: 'ERR-${DateTime.now().millisecondsSinceEpoch}',
      errorMessage: error.toString(),
      stackTrace: stackTrace?.toString(),
      screenContext: screenContext,
      timestamp: DateTime.now(),
    );
    _reports.add(report);
    await _save();
    ChronosLogger.error('Erro capturado: ${report.id}', tag: _tag);
    notifyListeners();
  }

  /// Adiciona descrição do usuário a um relatório existente.
  Future<void> addUserDescription(String reportId, String description) async {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) return;

    final old = _reports[index];
    _reports[index] = ErrorReport(
      id: old.id,
      errorMessage: old.errorMessage,
      stackTrace: old.stackTrace,
      userDescription: description,
      screenContext: old.screenContext,
      timestamp: old.timestamp,
    );
    await _save();
    notifyListeners();
  }

  /// Limpa todos os relatórios.
  Future<void> clear() async {
    _reports.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_reports.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, data);
    } catch (e) {
      ChronosLogger.error('Erro ao salvar reports: $e', tag: _tag);
    }
  }
}
