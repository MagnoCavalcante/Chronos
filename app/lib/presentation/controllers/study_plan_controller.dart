import 'package:flutter/material.dart';
import '../../core/study/study_models.dart';
import '../../core/study/study_plan_repository.dart';

enum StudyPlanStatus { idle, loading, loaded, error }

class StudyPlanController extends ChangeNotifier {
  final StudyPlanRepository _repository;

  StudyPlanController({StudyPlanRepository? repository}) : _repository = repository ?? StudyPlanRepository();

  StudyPlanStatus _status = StudyPlanStatus.idle;
  List<StudyPlan> _plans = [];
  Map<String, List<StudyPlanItem>> _items = {};
  String? _error;

  StudyPlanStatus get status => _status;
  List<StudyPlan> get plans => _plans;
  Map<String, List<StudyPlanItem>> get items => _items;
  String? get error => _error;

  Future<void> load() async {
    _status = StudyPlanStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _plans = await _repository.getPlans();
      _items = {};
      for (final plan in _plans) {
        _items[plan.id] = await _repository.getItems(plan.id);
      }
      _status = StudyPlanStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = StudyPlanStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createPlan(String title, {String? description, DateTime? startDate, DateTime? endDate}) async {
    final plan = await _repository.createPlan(
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
    );
    if (plan != null) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> addItem(String planId, int dayNumber, String title, {String? entityType, String? entityId}) async {
    final item = await _repository.addItem(
      planId: planId,
      dayNumber: dayNumber,
      title: title,
      entityType: entityType,
      entityId: entityId,
    );
    if (item != null) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> toggleComplete(String itemId, bool completed) async {
    final ok = await _repository.toggleItemComplete(itemId, completed);
    if (ok) await load();
    return ok;
  }
}
