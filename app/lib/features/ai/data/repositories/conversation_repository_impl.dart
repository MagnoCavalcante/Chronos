import '../../../../core/utils/logger.dart';
import '../../domain/entities/ai_entities.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../cache/ai_cache_service.dart';

/// Implementação do histórico de conversas usando cache local (SharedPreferences + memória).
class ConversationRepositoryImpl implements ConversationRepository {
  final AiCacheService _cache;
  static const _historyKey = 'ai_conversation_history';
  static const _tag = 'ConversationRepositoryImpl';

  ConversationRepositoryImpl({AiCacheService? cache}) : _cache = cache ?? AiCacheService();

  Future<List<ConversationMessage>> _loadAll() async {
    try {
      final raw = await _cache.getHistory(_historyKey);
      return raw.map(ConversationMessage.fromJson).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      ChronosLogger.warn('Erro ao carregar histórico de conversas: $e', tag: _tag, error: e);
      return [];
    }
  }

  Future<void> _saveAll(List<ConversationMessage> messages) async {
    try {
      final data = messages.map((m) => m.toJson()).toList();
      await _cache.cacheHistory(_historyKey, data);
    } catch (e) {
      ChronosLogger.warn('Erro ao salvar histórico de conversas: $e', tag: _tag, error: e);
    }
  }

  @override
  Future<List<ConversationMessage>> getHistory() => _loadAll();

  @override
  Future<void> saveMessage(ConversationMessage message) async {
    final all = await _loadAll();
    all.removeWhere((m) => m.id == message.id);
    all.insert(0, message);
    // Mantém um limite prático de mensagens em cache local.
    final limited = all.take(100).toList();
    await _saveAll(limited);
  }

  @override
  Future<void> deleteMessage(String id) async {
    final all = await _loadAll();
    all.removeWhere((m) => m.id == id);
    await _saveAll(all);
  }

  @override
  Future<ConversationMessage> toggleFavorite(String id) async {
    final all = await _loadAll();
    final index = all.indexWhere((m) => m.id == id);
    if (index == -1) throw StateError('Mensagem não encontrada: $id');
    final updated = all[index].copyWith(isFavorite: !all[index].isFavorite);
    all[index] = updated;
    await _saveAll(all);
    return updated;
  }

  @override
  Future<ConversationMessage> togglePin(String id) async {
    final all = await _loadAll();
    final index = all.indexWhere((m) => m.id == id);
    if (index == -1) throw StateError('Mensagem não encontrada: $id');
    final updated = all[index].copyWith(isPinned: !all[index].isPinned);
    all[index] = updated;
    await _saveAll(all);
    return updated;
  }

  @override
  Future<List<ConversationMessage>> getFavorites() async {
    final all = await _loadAll();
    return all.where((m) => m.isFavorite).toList();
  }

  @override
  Future<List<ConversationMessage>> getPinned() async {
    final all = await _loadAll();
    return all.where((m) => m.isPinned).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<List<ConversationMessage>> getRecent({int limit = 10}) async {
    final all = await _loadAll();
    return all.take(limit).toList();
  }

  @override
  Future<void> clearHistory() async {
    await _cache.cacheHistory(_historyKey, []);
  }
}
