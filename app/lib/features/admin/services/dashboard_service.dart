import '../../../core/utils/logger.dart';
import '../domain/entities/admin_entities.dart';
import '../domain/repositories/admin_repository.dart';

/// Serviço do Dashboard Administrativo.
///
/// Fornece estatísticas gerais, dados de crescimento e atividade.
class DashboardService {
  final AdminRepository _repository;
  static const _tag = 'DashboardService';

  AdminDashboardStats? _cachedStats;
  DateTime? _lastFetch;
  static const _cacheDuration = Duration(minutes: 5);

  DashboardService({required AdminRepository repository})
      : _repository = repository;

  /// Obtém estatísticas do dashboard (com cache de 5 min).
  Future<AdminDashboardStats> getStats({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedStats != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      return _cachedStats!;
    }
    ChronosLogger.info('Carregando stats do dashboard', tag: _tag);
    _cachedStats = await _repository.getDashboardStats();
    _lastFetch = DateTime.now();
    return _cachedStats!;
  }

  /// Retorna totais por tipo de entidade.
  Future<Map<AdminEntityType, int>> getEntityCounts() async {
    final stats = await getStats();
    return {
      AdminEntityType.character: stats.characters,
      AdminEntityType.event: stats.events,
      AdminEntityType.civilization: stats.civilizations,
      AdminEntityType.artifact: stats.artifacts,
      AdminEntityType.location: stats.locations,
      AdminEntityType.source: stats.sources,
      AdminEntityType.learningPath: stats.learningPaths,
      AdminEntityType.quiz: stats.quizzes,
    };
  }

  /// Total de conteúdos.
  Future<int> getTotalContents() async {
    final counts = await getEntityCounts();
    return counts.values.fold<int>(0, (sum, c) => sum + c);
  }

  void invalidateCache() {
    _cachedStats = null;
    _lastFetch = null;
  }
}
