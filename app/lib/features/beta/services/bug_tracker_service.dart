import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/logger.dart';
import '../domain/entities/bug_report.dart';

/// Sistema de Bug Tracking local do CHRONOS Beta.
///
/// Registra, atualiza e consulta bugs encontrados durante testes beta.
class BugTrackerService extends ChangeNotifier {
  static const String _tag = 'BugTrackerService';
  static const String _storageKey = 'chronos_bug_tracker';

  final List<BugReport> _bugs = [];

  /// Lista imutável de todos os bugs registrados.
  List<BugReport> get bugs => List.unmodifiable(_bugs);

  /// Bugs abertos.
  List<BugReport> get openBugs => _bugs.where((b) => b.status == BugStatus.open).toList();

  /// Bugs críticos abertos.
  List<BugReport> get criticalBugs =>
      _bugs.where((b) => b.priority == BugPriority.critical && b.status == BugStatus.open).toList();

  /// Bugs corrigidos.
  List<BugReport> get fixedBugs => _bugs.where((b) => b.status == BugStatus.fixed).toList();

  /// Total de bugs.
  int get totalCount => _bugs.length;

  /// Total corrigidos.
  int get fixedCount => fixedBugs.length;

  /// Carrega bugs salvos.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;

      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _bugs.clear();
      _bugs.addAll(list.map(BugReport.fromJson));
      notifyListeners();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar bugs: $e', tag: _tag);
    }
  }

  /// Reporta um novo bug.
  Future<void> report({
    required String description,
    required BugPriority priority,
    required BugCategory category,
    String? steps,
    String? expectedBehavior,
    String? actualBehavior,
  }) async {
    final bug = BugReport(
      id: 'BUG-${DateTime.now().millisecondsSinceEpoch}',
      description: description,
      priority: priority,
      category: category,
      steps: steps,
      expectedBehavior: expectedBehavior,
      actualBehavior: actualBehavior,
      createdAt: DateTime.now(),
    );

    _bugs.add(bug);
    await _save();
    ChronosLogger.info('Bug reportado: ${bug.id} [${priority.name}]', tag: _tag);
    notifyListeners();
  }

  /// Atualiza o status de um bug.
  Future<void> updateStatus(String bugId, BugStatus newStatus, {String? versionFixed}) async {
    final index = _bugs.indexWhere((b) => b.id == bugId);
    if (index == -1) return;

    _bugs[index] = _bugs[index].copyWith(
      status: newStatus,
      versionFixed: versionFixed,
      resolvedAt: newStatus == BugStatus.fixed ? DateTime.now() : null,
    );
    await _save();
    notifyListeners();
  }

  /// Filtra bugs por categoria.
  List<BugReport> getByCategory(BugCategory category) =>
      _bugs.where((b) => b.category == category).toList();

  /// Filtra bugs por prioridade.
  List<BugReport> getByPriority(BugPriority priority) =>
      _bugs.where((b) => b.priority == priority).toList();

  /// Limpa todos os registros.
  Future<void> clear() async {
    _bugs.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_bugs.map((b) => b.toJson()).toList());
      await prefs.setString(_storageKey, data);
    } catch (e) {
      ChronosLogger.error('Erro ao salvar bugs: $e', tag: _tag);
    }
  }
}
