import 'package:flutter/material.dart';
import '../../core/relationships/relationship_engine.dart';
import '../../core/relationships/relationship_item.dart';

/// Estados possíveis do controller de relacionamentos.
enum RelationshipStateStatus { idle, loading, error, loaded }

/// Controller reativo para descoberta de relacionamentos históricos.
class RelationshipController extends ChangeNotifier {
  final RelationshipEngine _engine;

  RelationshipController({RelationshipEngine? engine})
      : _engine = engine ?? RelationshipEngine();

  RelationshipStateStatus _status = RelationshipStateStatus.idle;
  List<RelatedGroup> _groups = [];
  List<RelatedItem> _suggestions = [];
  String? _errorMessage;

  RelationshipStateStatus get status => _status;
  List<RelatedGroup> get groups => _groups;
  List<RelatedItem> get suggestions => _suggestions;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == RelationshipStateStatus.loading;
  bool get hasError => _status == RelationshipStateStatus.error;
  bool get hasData => _status == RelationshipStateStatus.loaded;

  Future<void> discover({
    required String entityType,
    required String entityId,
    int limit = 100,
  }) async {
    _status = RelationshipStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _groups = await _engine.discover(
        entityType: entityType,
        entityId: entityId,
        limit: limit,
      );
      _suggestions = await _engine.suggestions(
        entityType: entityType,
        entityId: entityId,
      );
      _status = RelationshipStateStatus.loaded;
    } catch (e) {
      _errorMessage = 'Erro ao descobrir relacionamentos: $e';
      _status = RelationshipStateStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refresh({
    required String entityType,
    required String entityId,
  }) async {
    _groups = await _engine.refresh(
      entityType: entityType,
      entityId: entityId,
    );
    _suggestions = await _engine.suggestions(
      entityType: entityType,
      entityId: entityId,
    );
    _status = RelationshipStateStatus.loaded;
    notifyListeners();
  }
}
