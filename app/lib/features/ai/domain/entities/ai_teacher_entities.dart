/// CHRONOS Sprint 8.5.0 — AI Teacher Entities
///
/// Entidades do Tutor de IA (Chronos AI Teacher).
/// Chat inteligente, explicações em níveis, comparações,
/// quiz IA, sessões de estudo, memória do tutor.

// ============================================================
// Enums
// ============================================================

/// Nível de explicação.
enum ExplanationLevel {
  basic('Básico'),
  intermediate('Intermediário'),
  advanced('Avançado'),
  academic('Acadêmico');

  final String label;
  const ExplanationLevel(this.label);
}

/// Tipo de quiz gerado pela IA.
enum AiQuizType {
  multipleChoice('Múltipla Escolha'),
  trueFalse('Verdadeiro ou Falso'),
  shortAnswer('Resposta Curta'),
  discursive('Discursiva');

  final String label;
  const AiQuizType(this.label);
}

/// Status da sessão de estudo.
enum StudySessionStatus { active, paused, completed, abandoned }

/// Tipo de sugestão pós-conteúdo.
enum TutorSuggestionType { summary, quiz, deepen, nextContent }

/// Etapa da sessão de estudo guiada.
enum SessionStepType { explanation, question, correction, transition }

// ============================================================
// Sessão de Estudo Guiada
// ============================================================

class TutorSession {
  final String id;
  final String userId;
  final String topic;
  final StudySessionStatus status;
  final List<SessionStep> steps;
  final ExplanationLevel level;
  final DateTime startedAt;
  final DateTime? endedAt;

  const TutorSession({
    required this.id,
    required this.userId,
    required this.topic,
    this.status = StudySessionStatus.active,
    this.steps = const [],
    this.level = ExplanationLevel.intermediate,
    required this.startedAt,
    this.endedAt,
  });

  TutorSession copyWith({
    StudySessionStatus? status,
    List<SessionStep>? steps,
    DateTime? endedAt,
  }) =>
      TutorSession(
        id: id,
        userId: userId,
        topic: topic,
        status: status ?? this.status,
        steps: steps ?? this.steps,
        level: level,
        startedAt: startedAt,
        endedAt: endedAt ?? this.endedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'topic': topic,
        'status': status.name,
        'steps': steps.map((s) => s.toJson()).toList(),
        'level': level.name,
        'started_at': startedAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
      };

  factory TutorSession.fromJson(Map<String, dynamic> json) => TutorSession(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        topic: json['topic'] as String? ?? '',
        status: StudySessionStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String? ?? 'active'),
          orElse: () => StudySessionStatus.active,
        ),
        steps: (json['steps'] as List?)
                ?.map((s) => SessionStep.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        level: ExplanationLevel.values.firstWhere(
          (e) => e.name == (json['level'] as String? ?? 'intermediate'),
          orElse: () => ExplanationLevel.intermediate,
        ),
        startedAt: DateTime.tryParse(json['started_at'] as String? ?? '') ?? DateTime.now(),
        endedAt: json['ended_at'] != null ? DateTime.tryParse(json['ended_at'] as String) : null,
      );
}

class SessionStep {
  final SessionStepType type;
  final String content;
  final String? userResponse;
  final bool? isCorrect;
  final DateTime timestamp;

  const SessionStep({
    required this.type,
    required this.content,
    this.userResponse,
    this.isCorrect,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'content': content,
        'user_response': userResponse,
        'is_correct': isCorrect,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SessionStep.fromJson(Map<String, dynamic> json) => SessionStep(
        type: SessionStepType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? 'explanation'),
          orElse: () => SessionStepType.explanation,
        ),
        content: json['content'] as String? ?? '',
        userResponse: json['user_response'] as String?,
        isCorrect: json['is_correct'] as bool?,
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      );
}

// ============================================================
// Sugestões Pós-Conteúdo
// ============================================================

class TutorSuggestion {
  final TutorSuggestionType type;
  final String label;
  final String description;

  const TutorSuggestion({
    required this.type,
    required this.label,
    required this.description,
  });
}

// ============================================================
// Quiz Gerado pela IA
// ============================================================

class AiGeneratedQuiz {
  final String entityId;
  final String entityName;
  final AiQuizType type;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final ExplanationLevel difficulty;

  const AiGeneratedQuiz({
    required this.entityId,
    required this.entityName,
    required this.type,
    required this.question,
    this.options = const [],
    this.correctIndex = 0,
    required this.explanation,
    this.difficulty = ExplanationLevel.intermediate,
  });
}

// ============================================================
// Comparação Estruturada
// ============================================================

class ComparisonResult {
  final String entityA;
  final String entityB;
  final List<ComparisonRow> rows;
  final String summary;

  const ComparisonResult({
    required this.entityA,
    required this.entityB,
    this.rows = const [],
    required this.summary,
  });
}

class ComparisonRow {
  final String aspect;
  final String valueA;
  final String valueB;

  const ComparisonRow({
    required this.aspect,
    required this.valueA,
    required this.valueB,
  });
}

// ============================================================
// Memória do Tutor
// ============================================================

class TutorMemoryEntry {
  final String id;
  final String userId;
  final String entityId;
  final String entityName;
  final TutorMemoryType type;
  final String content;
  final DateTime recordedAt;

  const TutorMemoryEntry({
    required this.id,
    required this.userId,
    required this.entityId,
    required this.entityName,
    required this.type,
    required this.content,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'entity_id': entityId,
        'entity_name': entityName,
        'type': type.name,
        'content': content,
        'recorded_at': recordedAt.toIso8601String(),
      };

  factory TutorMemoryEntry.fromJson(Map<String, dynamic> json) => TutorMemoryEntry(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        entityId: json['entity_id'] as String? ?? '',
        entityName: json['entity_name'] as String? ?? '',
        type: TutorMemoryType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? 'doubt'),
          orElse: () => TutorMemoryType.doubt,
        ),
        content: json['content'] as String? ?? '',
        recordedAt: DateTime.tryParse(json['recorded_at'] as String? ?? '') ?? DateTime.now(),
      );
}

enum TutorMemoryType { doubt, difficulty, mastered, progress, preference }

// ============================================================
// Contexto para IA Contextual
// ============================================================

class PageContext {
  final String entityId;
  final String entityType;
  final String entityName;
  final String summary;
  final List<String> relatedEntityIds;

  const PageContext({
    required this.entityId,
    required this.entityType,
    required this.entityName,
    this.summary = '',
    this.relatedEntityIds = const [],
  });
}

// ============================================================
// RAG Pipeline Interfaces (preparação para futuro)
// ============================================================

/// Interface para indexação de documentos.
abstract class DocumentIndexer {
  Future<void> indexDocument(String documentId, String content, Map<String, dynamic> metadata);
  Future<void> removeDocument(String documentId);
  Future<void> reindexAll();
}

/// Interface para geração de embeddings.
abstract class EmbeddingProvider {
  Future<List<double>> generateEmbedding(String text);
  Future<List<List<double>>> generateBatchEmbeddings(List<String> texts);
}

/// Interface para busca semântica.
abstract class SemanticSearchEngine {
  Future<List<SemanticSearchResult>> search(String query, {int limit = 10});
}

class SemanticSearchResult {
  final String documentId;
  final double score;
  final String content;
  final Map<String, dynamic> metadata;

  const SemanticSearchResult({
    required this.documentId,
    required this.score,
    required this.content,
    this.metadata = const {},
  });
}

/// Interface para recuperação de documentos relevantes.
abstract class DocumentRetriever {
  Future<List<RetrievedDocument>> retrieve(String query, {int limit = 5});
}

class RetrievedDocument {
  final String id;
  final String content;
  final double relevanceScore;
  final Map<String, dynamic> metadata;

  const RetrievedDocument({
    required this.id,
    required this.content,
    required this.relevanceScore,
    this.metadata = const {},
  });
}

/// Interface para geração de resposta (modelo de IA intercambiável).
abstract class ResponseGenerator {
  Future<String> generate({
    required String prompt,
    required List<RetrievedDocument> context,
    Map<String, dynamic> parameters,
  });
}
