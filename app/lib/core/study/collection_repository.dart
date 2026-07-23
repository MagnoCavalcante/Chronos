import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/logger.dart';
import 'study_cache_service.dart';
import 'study_models.dart';

/// Repositório para gerenciamento de coleções de estudo.
class CollectionRepository {
  final SupabaseClient? _providedClient;
  final StudyCacheService _cache = StudyCacheService();

  CollectionRepository({SupabaseClient? client}) : _providedClient = client;

  SupabaseClient? get _client => _providedClient ?? _safeSupabaseClient();

  SupabaseClient? _safeSupabaseClient() {
    try {
      return SupabaseConfig.client;
    } catch (_) {
      return null;
    }
  }

  Future<List<Collection>> getCollections() async {
    final client = _client;
    if (client == null) return _cache.getCollections();
    try {
      final response = await client.from('collections').select().eq('ativo', true).order('updated_at', ascending: false);
      final list = response.map((e) => Collection.fromJson(e)).toList();
      await _cache.cacheCollections(list);
      return list;
    } catch (e) {
      ChronosLogger.error('Erro ao carregar coleções', error: e);
      return _cache.getCollections();
    }
  }

  Future<Collection?> createCollection({
    required String title,
    String? description,
    String? coverUrl,
  }) async {
    final client = _client;
    if (client == null) return null;
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;
      final slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      final response = await client.from('collections').insert({
        'user_id': userId,
        'slug': slug,
        'title': title,
        'description': description,
        'cover_url': coverUrl,
      }).select().single();
      return Collection.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao criar coleção', error: e);
      return null;
    }
  }

  Future<bool> updateCollection(Collection collection) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('collections').update({
        'title': collection.title,
        'description': collection.description,
        'cover_url': collection.coverUrl,
        'is_public': collection.isPublic,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', collection.id);
      return true;
    } catch (e) {
      ChronosLogger.error('Erro ao atualizar coleção', error: e);
      return false;
    }
  }

  Future<bool> deleteCollection(String id) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('collections').update({'ativo': false}).eq('id', id);
      return true;
    } catch (e) {
      ChronosLogger.error('Erro ao excluir coleção', error: e);
      return false;
    }
  }

  Future<bool> duplicateCollection(String id) async {
    final original = await getCollectionById(id);
    if (original == null) return false;
    final copy = await createCollection(
      title: '${original.title} (Cópia)',
      description: original.description,
      coverUrl: original.coverUrl,
    );
    if (copy == null) return false;
    final items = await getItems(id);
    for (final item in items) {
      await addItemToCollection(
        collectionId: copy.id,
        entityType: item.entityType,
        entityId: item.entityId,
        notes: item.notes,
      );
    }
    return true;
  }

  Future<Collection?> getCollectionById(String id) async {
    final client = _client;
    if (client == null) return null;
    try {
      final response = await client.from('collections').select().eq('id', id).single();
      return Collection.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao buscar coleção', error: e);
      return null;
    }
  }

  Future<List<CollectionItem>> getItems(String collectionId) async {
    final client = _client;
    if (client == null) return [];
    try {
      final response = await client.from('collection_items').select().eq('collection_id', collectionId).order('order_index');
      return response.map((e) => CollectionItem.fromJson(e)).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao carregar itens da coleção', error: e);
      return [];
    }
  }

  Future<CollectionItem?> addItemToCollection({
    required String collectionId,
    required String entityType,
    required String entityId,
    String? notes,
  }) async {
    final client = _client;
    if (client == null) return null;
    try {
      final response = await client.from('collection_items').insert({
        'collection_id': collectionId,
        'entity_type': entityType,
        'entity_id': entityId,
        'notes': notes,
      }).select().single();
      return CollectionItem.fromJson(response);
    } catch (e) {
      ChronosLogger.error('Erro ao adicionar item', error: e);
      return null;
    }
  }

  Future<bool> removeItem(String itemId) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('collection_items').delete().eq('id', itemId);
      return true;
    } catch (e) {
      ChronosLogger.error('Erro ao remover item', error: e);
      return false;
    }
  }

  Future<bool> reorderItems(String collectionId, List<String> itemIds) async {
    final client = _client;
    if (client == null) return false;
    try {
      for (var i = 0; i < itemIds.length; i++) {
        await client.from('collection_items').update({'order_index': i}).eq('id', itemIds[i]);
      }
      return true;
    } catch (e) {
      ChronosLogger.error('Erro ao reordenar itens', error: e);
      return false;
    }
  }

  Future<List<Collection>> searchCollections(String query) async {
    final client = _client;
    if (client == null) return [];
    try {
      final response = await client.from('collections').select().ilike('title', '%$query%').eq('ativo', true);
      return response.map((e) => Collection.fromJson(e)).toList();
    } catch (e) {
      ChronosLogger.error('Erro ao pesquisar coleções', error: e);
      return [];
    }
  }
}
