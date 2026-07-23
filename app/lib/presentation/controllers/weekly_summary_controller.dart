import 'package:flutter/foundation.dart';
import '../../core/gamification/gamification_models.dart';
import '../../core/gamification/weekly_summary_repository.dart';
import '../../core/utils/logger.dart';

/// Controller do resumo semanal.
class WeeklySummaryController extends ChangeNotifier {
  final WeeklySummaryRepository _repository;

  WeeklySummaryController({WeeklySummaryRepository? repository}) : _repository = repository ?? WeeklySummaryRepository();

  bool _isLoading = false;
  String? _error;
  WeeklySummary? _summary;

  bool get isLoading => _isLoading;
  String? get error => _error;
  WeeklySummary? get summary => _summary;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _repository.generateSummary();
      _isLoading = false;
    } catch (e) {
      ChronosLogger.error('Erro ao gerar resumo semanal: $e', tag: 'WeeklySummaryController', error: e);
      _error = 'Não foi possível gerar o resumo semanal.';
      _isLoading = false;
    }

    notifyListeners();
  }

  Future<void> refresh() => load();
}
