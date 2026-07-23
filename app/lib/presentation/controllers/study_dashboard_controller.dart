import 'package:flutter/material.dart';
import '../../core/study/collection_repository.dart';
import '../../core/study/goal_repository.dart';
import '../../core/study/progress_repository.dart';
import '../../core/study/review_repository.dart';
import '../../core/study/stats_repository.dart';
import '../../core/study/study_models.dart';

enum DashboardStatus { idle, loading, loaded, error }

class StudyDashboardController extends ChangeNotifier {
  final ProgressRepository _progressRepository;
  final ReviewRepository _reviewRepository;
  final GoalRepository _goalRepository;
  final StatsRepository _statsRepository;
  final CollectionRepository _collectionRepository;

  StudyDashboardController({
    ProgressRepository? progressRepository,
    ReviewRepository? reviewRepository,
    GoalRepository? goalRepository,
    StatsRepository? statsRepository,
    CollectionRepository? collectionRepository,
  })  : _progressRepository = progressRepository ?? ProgressRepository(),
        _reviewRepository = reviewRepository ?? ReviewRepository(),
        _goalRepository = goalRepository ?? GoalRepository(),
        _statsRepository = statsRepository ?? StatsRepository(),
        _collectionRepository = collectionRepository ?? CollectionRepository();

  DashboardStatus _status = DashboardStatus.idle;
  UserStats? _stats;
  List<ReviewItem> _pendingReviews = [];
  List<StudyGoal> _goals = [];
  List<Collection> _collections = [];
  StudyProgress? _continueStudying;
  String? _error;

  DashboardStatus get status => _status;
  UserStats? get stats => _stats;
  List<ReviewItem> get pendingReviews => _pendingReviews;
  List<StudyGoal> get goals => _goals;
  List<Collection> get collections => _collections;
  StudyProgress? get continueStudying => _continueStudying;
  String? get error => _error;

  Future<void> load() async {
    _status = DashboardStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _stats = await _statsRepository.getStats();
      _pendingReviews = await _reviewRepository.getPendingReviews();
      _goals = await _goalRepository.getGoals();
      _collections = await _collectionRepository.getCollections();
      _continueStudying = await _progressRepository.getContinueStudying();
      _status = DashboardStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = DashboardStatus.error;
    } finally {
      notifyListeners();
    }
  }
}
