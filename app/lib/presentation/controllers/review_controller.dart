import 'package:flutter/material.dart';
import '../../core/study/review_repository.dart';
import '../../core/study/study_models.dart';

enum ReviewStatus { idle, loading, loaded, error }

class ReviewController extends ChangeNotifier {
  final ReviewRepository _repository;

  ReviewController({ReviewRepository? repository}) : _repository = repository ?? ReviewRepository();

  ReviewStatus _status = ReviewStatus.idle;
  List<ReviewItem> _items = [];
  String? _error;

  ReviewStatus get status => _status;
  List<ReviewItem> get items => _items;
  String? get error => _error;

  Future<void> load() async {
    _status = ReviewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _items = await _repository.getPendingReviews();
      _status = ReviewStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = ReviewStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> schedule(String entityType, String entityId, int intervalDays) async {
    final item = await _repository.scheduleReview(
      entityType: entityType,
      entityId: entityId,
      intervalDays: intervalDays,
    );
    if (item != null) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> markReviewed(String reviewId) async {
    final ok = await _repository.markReviewed(reviewId);
    if (ok) await load();
    return ok;
  }
}
