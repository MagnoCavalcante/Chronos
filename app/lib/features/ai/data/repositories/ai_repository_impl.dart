import '../../../../core/utils/logger.dart';
import '../../domain/entities/ai_entities.dart';
import '../../domain/repositories/ai_repository.dart';
import '../cache/ai_cache_service.dart';
import '../providers/ai_provider.dart';
import '../providers/offline_adapter.dart';
import '../providers/provider_factory.dart';

/// Implementação do [AIRepository] que gerencia provedores, fallback offline e cache.
class AIRepositoryImpl implements AIRepository {
  final AIProvider _primaryProvider;
  final OfflineAdapter _offlineAdapter;
  final AiCacheService _cache;

  static const _tag = 'AIRepositoryImpl';

  AIRepositoryImpl({
    AIProvider? primaryProvider,
    OfflineAdapter? offlineAdapter,
    AiCacheService? cache,
  })  : _primaryProvider = primaryProvider ?? ProviderFactory.create(),
        _offlineAdapter = offlineAdapter ?? OfflineAdapter(),
        _cache = cache ?? AiCacheService();

  @override
  Future<AiResponse> generate(AiRequest request) async {
    final cacheKey = _cacheKey(request);
    final cached = await getCached(cacheKey);
    if (cached != null) {
      ChronosLogger.info('Resposta carregada do cache para a pergunta: ${request.question}', tag: _tag);
      return cached;
    }

    try {
      if (_primaryProvider.isAvailable) {
        final stopwatch = Stopwatch()..start();
        final response = await _primaryProvider.generate(request);
        stopwatch.stop();
        final enriched = response.copyWith(latency: stopwatch.elapsed);
        await cache(cacheKey, enriched);
        return enriched;
      }
      throw StateError('Provedor ${_primaryProvider.name} indisponível.');
    } catch (e) {
      ChronosLogger.warn(
        'Falha no provedor ${_primaryProvider.name}: $e. Caindo para offline.',
        tag: _tag,
        error: e,
      );
      final stopwatch = Stopwatch()..start();
      final response = await _offlineAdapter.generate(request);
      stopwatch.stop();
      final enriched = response.copyWith(latency: stopwatch.elapsed);
      await cache(cacheKey, enriched);
      return enriched;
    }
  }

  @override
  Future<AiResponse?> getCached(String cacheKey) async {
    try {
      final json = await _cache.getResponse(cacheKey);
      if (json == null) return null;
      return AiResponse.fromJson(json);
    } catch (e) {
      ChronosLogger.warn('Erro ao ler cache de IA: $e', tag: _tag, error: e);
      return null;
    }
  }

  @override
  Future<void> cache(String cacheKey, AiResponse response) async {
    try {
      await _cache.cacheResponse(cacheKey, response.toJson());
    } catch (e) {
      ChronosLogger.warn('Erro ao salvar cache de IA: $e', tag: _tag, error: e);
    }
  }

  String _cacheKey(AiRequest request) {
    final normalized = '${request.question.trim().toLowerCase()}|${request.mode.name}';
    return normalized.replaceAll(RegExp(r'[^a-z0-9|]'), '_').substring(0, normalized.length > 200 ? 200 : normalized.length);
  }
}
