/// Modos de resposta do assistente Chronos AI.
enum AiMode {
  /// Resposta padrão baseada no contexto do banco.
  normal('Resposta'),

  /// Explicação didática como professor.
  teacher('Como professor'),

  /// Resposta resumida.
  summary('Resumido'),

  /// Resposta detalhada.
  detailed('Detalhado'),

  /// Comparação entre duas entidades.
  comparison('Comparar'),

  /// Linha do tempo de eventos entre anos.
  timeline('Linha do tempo');

  final String label;
  const AiMode(this.label);

  static AiMode fromLabel(String label) {
    return AiMode.values.firstWhere(
      (e) => e.label.toLowerCase() == label.toLowerCase(),
      orElse: () => AiMode.normal,
    );
  }
}

/// Provedores de IA suportados pela arquitetura.
enum AiProviderType {
  openAi('OpenAI'),
  gemini('Gemini'),
  claude('Claude'),
  local('Modelo Local'),
  offline('Chronos Offline');

  final String label;
  const AiProviderType(this.label);

  static AiProviderType fromString(String value) {
    return AiProviderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AiProviderType.offline,
    );
  }
}

/// Entrada enviada para um provedor de IA.
class AiRequest {
  final String question;
  final AiMode mode;
  final String prompt;
  final List<AiSearchResult> searchResults;
  final List<AiRelationshipGroup> relationships;
  final List<AiTimelineItem> timelineItems;

  const AiRequest({
    required this.question,
    required this.mode,
    required this.prompt,
    this.searchResults = const [],
    this.relationships = const [],
    this.timelineItems = const [],
  });
}

/// Item de busca enriquecido para o contexto da IA.
class AiSearchResult {
  final String id;
  final String entityType;
  final String title;
  final String subtitle;
  final String summary;
  final String? imageUrl;
  final int? chronologyValue;

  const AiSearchResult({
    required this.id,
    required this.entityType,
    required this.title,
    this.subtitle = '',
    this.summary = '',
    this.imageUrl,
    this.chronologyValue,
  });
}

/// Grupo de entidades relacionadas retornado pela Relationship Engine.
class AiRelationshipGroup {
  final String relationType;
  final List<AiRelatedEntity> items;

  const AiRelationshipGroup({required this.relationType, this.items = const []});
}

/// Entidade relacionada mencionada na resposta.
class AiRelatedEntity {
  final String id;
  final String slug;
  final String entityType;
  final String title;
  final String description;
  final int? year;
  final String? imageUrl;
  final String? color;

  const AiRelatedEntity({
    required this.id,
    required this.slug,
    required this.entityType,
    required this.title,
    this.description = '',
    this.year,
    this.imageUrl,
    this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'entityType': entityType,
        'title': title,
        'description': description,
        'year': year,
        'imageUrl': imageUrl,
        'color': color,
      };

  factory AiRelatedEntity.fromJson(Map<String, dynamic> json) {
    return AiRelatedEntity(
      id: json['id'] as String,
      slug: json['slug'] as String,
      entityType: json['entityType'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      year: json['year'] as int?,
      imageUrl: json['imageUrl'] as String?,
      color: json['color'] as String?,
    );
  }
}

/// Item de timeline usado no contexto temporal.
class AiTimelineItem {
  final String id;
  final String slug;
  final String entityType;
  final String title;
  final String description;
  final int year;
  final String? imageUrl;
  final String? color;

  const AiTimelineItem({
    required this.id,
    required this.slug,
    required this.entityType,
    required this.title,
    this.description = '',
    required this.year,
    this.imageUrl,
    this.color,
  });
}

/// Citação / fonte histórica utilizada na resposta.
class AiCitation {
  final String id;
  final String title;
  final String? author;
  final String? url;

  const AiCitation({
    required this.id,
    required this.title,
    this.author,
    this.url,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'url': url,
      };

  factory AiCitation.fromJson(Map<String, dynamic> json) {
    return AiCitation(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      url: json['url'] as String?,
    );
  }
}

/// Resposta final do assistente Chronos AI.
class AiResponse {
  final String text;
  final bool usedExternalAi;
  final AiProviderType provider;
  final List<AiCitation> citations;
  final List<AiRelatedEntity> relatedEntities;
  final List<String> suggestedQuestions;
  final Duration? latency;

  const AiResponse({
    required this.text,
    this.usedExternalAi = false,
    this.provider = AiProviderType.offline,
    this.citations = const [],
    this.relatedEntities = const [],
    this.suggestedQuestions = const [],
    this.latency,
  });

  AiResponse copyWith({
    String? text,
    bool? usedExternalAi,
    AiProviderType? provider,
    List<AiCitation>? citations,
    List<AiRelatedEntity>? relatedEntities,
    List<String>? suggestedQuestions,
    Duration? latency,
  }) {
    return AiResponse(
      text: text ?? this.text,
      usedExternalAi: usedExternalAi ?? this.usedExternalAi,
      provider: provider ?? this.provider,
      citations: citations ?? this.citations,
      relatedEntities: relatedEntities ?? this.relatedEntities,
      suggestedQuestions: suggestedQuestions ?? this.suggestedQuestions,
      latency: latency ?? this.latency,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'usedExternalAi': usedExternalAi,
        'provider': provider.name,
        'citations': citations.map((e) => e.toJson()).toList(),
        'relatedEntities': relatedEntities.map((e) => e.toJson()).toList(),
        'suggestedQuestions': suggestedQuestions,
        'latencyMs': latency?.inMilliseconds,
      };

  factory AiResponse.fromJson(Map<String, dynamic> json) {
    return AiResponse(
      text: json['text'] as String,
      usedExternalAi: json['usedExternalAi'] as bool? ?? false,
      provider: AiProviderType.fromString(json['provider'] as String? ?? 'offline'),
      citations: (json['citations'] as List<dynamic>? ?? [])
          .map((e) => AiCitation.fromJson(e as Map<String, dynamic>))
          .toList(),
      relatedEntities: (json['relatedEntities'] as List<dynamic>? ?? [])
          .map((e) => AiRelatedEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestedQuestions: (json['suggestedQuestions'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      latency: json['latencyMs'] == null
          ? null
          : Duration(milliseconds: (json['latencyMs'] as num).toInt()),
    );
  }
}

/// Mensagem de conversa persistida no histórico.
class ConversationMessage {
  final String id;
  final String question;
  final AiResponse response;
  final DateTime timestamp;
  final bool isFavorite;
  final bool isPinned;

  const ConversationMessage({
    required this.id,
    required this.question,
    required this.response,
    required this.timestamp,
    this.isFavorite = false,
    this.isPinned = false,
  });

  ConversationMessage copyWith({
    String? id,
    String? question,
    AiResponse? response,
    DateTime? timestamp,
    bool? isFavorite,
    bool? isPinned,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      question: question ?? this.question,
      response: response ?? this.response,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'response': response.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
        'isPinned': isPinned,
      };

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'] as String,
      question: json['question'] as String,
      response: AiResponse.fromJson(json['response'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }
}
