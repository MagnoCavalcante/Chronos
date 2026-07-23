import '../../knowledge_base/domain/entities/knowledge_entities.dart';
import '../../knowledge_base/services/knowledge_graph_service.dart';
import '../domain/entities/learning_entities.dart';
import '../domain/repositories/learning_repository.dart';

/// Serviço de Recomendações Inteligentes.
///
/// Baseado no histórico do usuário, sugere novos conteúdos.
/// Exemplo: "Você estudou Roma. Talvez queira aprender sobre Júlio César, Augusto..."
class RecommendationService {
  final LearningRepository _repository;
  final KnowledgeGraphService _graphService;
  final String _userId;

  RecommendationService({
    required LearningRepository repository,
    required KnowledgeGraphService graphService,
    String userId = 'local_user',
  })  : _repository = repository,
        _graphService = graphService,
        _userId = userId;

  /// Obtém recomendações baseadas no histórico recente.
  Future<List<Recommendation>> getRecommendations({int limit = 5}) async {
    final recentProgress = await _repository.getRecentProgress(_userId, limit: 10);
    if (recentProgress.isEmpty) return [];

    final recommendations = <Recommendation>[];
    final seenIds = <String>{};

    // Para cada entidade estudada recentemente, buscar relações
    for (final progress in recentProgress) {
      if (recommendations.length >= limit) break;
      seenIds.add(progress.entityId);

      final suggestions = await _graphService.getContinueStudying(progress.entityId, limit: 3);
      for (final suggestion in suggestions) {
        if (seenIds.add(suggestion.targetId) && recommendations.length < limit) {
          recommendations.add(Recommendation(
            entityId: suggestion.targetId,
            entityType: suggestion.targetType.name,
            entityName: suggestion.targetName,
            reason: 'Você estudou ${progress.entityName}',
            source: progress.entityName,
            confidence: _calculateConfidence(progress),
          ));
        }
      }
    }

    // Se poucas recomendações, buscar descobertas de segundo nível
    if (recommendations.length < limit && recentProgress.isNotEmpty) {
      final discoveries = await _graphService.getDiscoverySuggestions(
        recentProgress.first.entityId,
        limit: limit - recommendations.length,
      );
      for (final d in discoveries) {
        if (seenIds.add(d.targetId)) {
          recommendations.add(Recommendation(
            entityId: d.targetId,
            entityType: d.targetType.name,
            entityName: d.targetName,
            reason: 'Baseado no seu histórico de estudos',
            source: 'Descoberta',
            confidence: 0.6,
          ));
        }
      }
    }

    return recommendations;
  }

  /// Obtém recomendações específicas para uma entidade.
  Future<List<Recommendation>> getEntityRecommendations(
    String entityId,
    String entityName, {
    int limit = 5,
  }) async {
    final suggestions = await _graphService.getContinueStudying(entityId, limit: limit);
    return suggestions.map((s) => Recommendation(
      entityId: s.targetId,
      entityType: s.targetType.name,
      entityName: s.targetName,
      reason: 'Relacionado a $entityName',
      source: entityName,
      confidence: 0.8,
    )).toList();
  }

  double _calculateConfidence(StudyProgress progress) {
    // Quanto mais o usuário estudou, maior a confiança da recomendação
    if (progress.viewCount >= 3) return 0.9;
    if (progress.viewCount >= 2) return 0.8;
    return 0.7;
  }
}

/// Recomendação de estudo.
class Recommendation {
  final String entityId;
  final String entityType;
  final String entityName;
  final String reason;
  final String source;
  final double confidence; // 0.0 - 1.0

  const Recommendation({
    required this.entityId,
    required this.entityType,
    required this.entityName,
    required this.reason,
    required this.source,
    this.confidence = 0.7,
  });
}
