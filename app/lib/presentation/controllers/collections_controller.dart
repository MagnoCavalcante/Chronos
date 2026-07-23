import 'package:flutter/material.dart';
import '../../core/study/collection_repository.dart';
import '../../core/study/progress_repository.dart';
import '../../core/study/study_models.dart';
import '../../core/study/tags_repository.dart';

enum CollectionsStatus { idle, loading, loaded, error }

class CollectionsController extends ChangeNotifier {
  final CollectionRepository collectionRepository;
  final ProgressRepository progressRepository;
  final TagsRepository tagsRepository;

  CollectionsController({
    CollectionRepository? collectionRepository,
    ProgressRepository? progressRepository,
    TagsRepository? tagsRepository,
  })  : collectionRepository = collectionRepository ?? CollectionRepository(),
        progressRepository = progressRepository ?? ProgressRepository(),
        tagsRepository = tagsRepository ?? TagsRepository();

  CollectionsStatus _status = CollectionsStatus.idle;
  List<Collection> _collections = [];
  List<Tag> _tags = [];
  String? _error;

  CollectionsStatus get status => _status;
  List<Collection> get collections => _collections;
  List<Tag> get tags => _tags;
  String? get error => _error;

  Future<void> load() async {
    _status = CollectionsStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _collections = await collectionRepository.getCollections();
      _tags = await tagsRepository.getTags();
      _status = CollectionsStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = CollectionsStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> create(String title, {String? description, String? coverUrl}) async {
    final collection = await collectionRepository.createCollection(
      title: title,
      description: description,
      coverUrl: coverUrl,
    );
    if (collection != null) {
      await load();
      return true;
    }
    return false;
  }

  Future<bool> delete(String id) async {
    final ok = await collectionRepository.deleteCollection(id);
    if (ok) await load();
    return ok;
  }

  Future<bool> duplicate(String id) async {
    final ok = await collectionRepository.duplicateCollection(id);
    if (ok) await load();
    return ok;
  }

  Future<bool> addItem(String collectionId, String entityType, String entityId, {String? notes}) async {
    final item = await collectionRepository.addItemToCollection(
      collectionId: collectionId,
      entityType: entityType,
      entityId: entityId,
      notes: notes,
    );
    return item != null;
  }

  Future<void> updateProgress(String entityType, String entityId, StudyStatus status, int percent, {int? seconds}) async {
    await progressRepository.updateProgress(
      entityType: entityType,
      entityId: entityId,
      status: status,
      progressPercent: percent,
      addedSeconds: seconds,
    );
  }
}
