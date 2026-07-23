/// Nível de confiabilidade de uma informação histórica.
enum ReliabilityLevel {
  /// 🟢 Informação amplamente aceita e documentada.
  fact,

  /// 🟡 Teoria com suporte acadêmico significativo.
  theory,

  /// 🟠 Hipótese com evidências parciais.
  hypothesis,

  /// 🔴 Informação em discussão ativa entre pesquisadores.
  disputed,
}

/// Tipo de entidade no grafo de conhecimento.
enum EntityType {
  character,
  event,
  civilization,
  artifact,
  location,
  era,
}

/// Referência bibliográfica/fonte histórica detalhada.
class HistoricalSource {
  final String id;
  final String autor;
  final String titulo;
  final String? livro;
  final String? artigo;
  final String? documento;
  final String? capitulo;
  final String? pagina;
  final String? url;
  final int? anoPublicacao;
  final ReliabilityLevel confiabilidade;

  const HistoricalSource({
    required this.id,
    required this.autor,
    required this.titulo,
    this.livro,
    this.artigo,
    this.documento,
    this.capitulo,
    this.pagina,
    this.url,
    this.anoPublicacao,
    this.confiabilidade = ReliabilityLevel.fact,
  });

  factory HistoricalSource.fromJson(Map<String, dynamic> json) => HistoricalSource(
        id: json['id'] as String? ?? '',
        autor: json['autor'] as String? ?? '',
        titulo: json['titulo'] as String? ?? '',
        livro: json['livro'] as String?,
        artigo: json['artigo'] as String?,
        documento: json['documento'] as String?,
        capitulo: json['capitulo'] as String?,
        pagina: json['pagina'] as String?,
        url: json['url'] as String?,
        anoPublicacao: json['ano_publicacao'] as int?,
        confiabilidade: ReliabilityLevel.values.firstWhere(
          (e) => e.name == (json['confiabilidade'] as String? ?? 'fact'),
          orElse: () => ReliabilityLevel.fact,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'autor': autor,
        'titulo': titulo,
        'livro': livro,
        'artigo': artigo,
        'documento': documento,
        'capitulo': capitulo,
        'pagina': pagina,
        'url': url,
        'ano_publicacao': anoPublicacao,
        'confiabilidade': confiabilidade.name,
      };
}

/// Bloco de informação com classificação de confiabilidade.
class KnowledgeBlock {
  final String id;
  final String conteudo;
  final ReliabilityLevel confiabilidade;
  final List<String> sourceIds;

  const KnowledgeBlock({
    required this.id,
    required this.conteudo,
    this.confiabilidade = ReliabilityLevel.fact,
    this.sourceIds = const [],
  });

  factory KnowledgeBlock.fromJson(Map<String, dynamic> json) => KnowledgeBlock(
        id: json['id'] as String? ?? '',
        conteudo: json['conteudo'] as String? ?? '',
        confiabilidade: ReliabilityLevel.values.firstWhere(
          (e) => e.name == (json['confiabilidade'] as String? ?? 'fact'),
          orElse: () => ReliabilityLevel.fact,
        ),
        sourceIds: (json['source_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'conteudo': conteudo,
        'confiabilidade': confiabilidade.name,
        'source_ids': sourceIds,
      };
}

/// Debate histórico entre pesquisadores.
class HistoricalDebate {
  final String id;
  final String titulo;
  final String descricao;
  final List<String> posicoes;
  final ReliabilityLevel statusAtual;

  const HistoricalDebate({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.posicoes = const [],
    this.statusAtual = ReliabilityLevel.disputed,
  });

  factory HistoricalDebate.fromJson(Map<String, dynamic> json) => HistoricalDebate(
        id: json['id'] as String? ?? '',
        titulo: json['titulo'] as String? ?? '',
        descricao: json['descricao'] as String? ?? '',
        posicoes: (json['posicoes'] as List<dynamic>?)?.cast<String>() ?? [],
        statusAtual: ReliabilityLevel.values.firstWhere(
          (e) => e.name == (json['status_atual'] as String? ?? 'disputed'),
          orElse: () => ReliabilityLevel.disputed,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'posicoes': posicoes,
        'status_atual': statusAtual.name,
      };
}

/// Curiosidade, mito ou equívoco histórico.
class HistoricalCuriosity {
  final String id;
  final String titulo;
  final String conteudo;
  final String tipo; // 'curiosidade', 'mito', 'equivoco'
  final ReliabilityLevel confiabilidade;

  const HistoricalCuriosity({
    required this.id,
    required this.titulo,
    required this.conteudo,
    this.tipo = 'curiosidade',
    this.confiabilidade = ReliabilityLevel.fact,
  });

  factory HistoricalCuriosity.fromJson(Map<String, dynamic> json) => HistoricalCuriosity(
        id: json['id'] as String? ?? '',
        titulo: json['titulo'] as String? ?? '',
        conteudo: json['conteudo'] as String? ?? '',
        tipo: json['tipo'] as String? ?? 'curiosidade',
        confiabilidade: ReliabilityLevel.values.firstWhere(
          (e) => e.name == (json['confiabilidade'] as String? ?? 'fact'),
          orElse: () => ReliabilityLevel.fact,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'conteudo': conteudo,
        'tipo': tipo,
        'confiabilidade': confiabilidade.name,
      };
}

/// Relação navegável entre entidades no grafo de conhecimento.
class KnowledgeRelation {
  final String id;
  final String targetId;
  final EntityType targetType;
  final String targetName;
  final String relationType;
  final String? descricao;

  const KnowledgeRelation({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.targetName,
    required this.relationType,
    this.descricao,
  });

  factory KnowledgeRelation.fromJson(Map<String, dynamic> json) => KnowledgeRelation(
        id: json['id'] as String? ?? '',
        targetId: json['target_id'] as String? ?? '',
        targetType: EntityType.values.firstWhere(
          (e) => e.name == (json['target_type'] as String? ?? 'event'),
          orElse: () => EntityType.event,
        ),
        targetName: json['target_name'] as String? ?? '',
        relationType: json['relation_type'] as String? ?? '',
        descricao: json['descricao'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'target_id': targetId,
        'target_type': targetType.name,
        'target_name': targetName,
        'relation_type': relationType,
        'descricao': descricao,
      };
}

/// Consenso acadêmico sobre uma entidade.
class AcademicConsensus {
  final String resumo;
  final ReliabilityLevel nivel;
  final List<String> sourceIds;

  const AcademicConsensus({
    required this.resumo,
    this.nivel = ReliabilityLevel.fact,
    this.sourceIds = const [],
  });

  factory AcademicConsensus.fromJson(Map<String, dynamic> json) => AcademicConsensus(
        resumo: json['resumo'] as String? ?? '',
        nivel: ReliabilityLevel.values.firstWhere(
          (e) => e.name == (json['nivel'] as String? ?? 'fact'),
          orElse: () => ReliabilityLevel.fact,
        ),
        sourceIds: (json['source_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'resumo': resumo,
        'nivel': nivel.name,
        'source_ids': sourceIds,
      };
}

/// Entry completa de conhecimento — genérica para qualquer tipo de entidade.
/// Contém todo o conteúdo enriquecido de uma entidade na base de conhecimento.
class KnowledgeEntry {
  final String entityId;
  final EntityType entityType;
  final String nome;
  final String? nomeOriginal;
  final String? imagemUrl;
  final String? bannerUrl;
  final String? periodoHistorico;
  final String? civilizacao;
  final String? localNascimento;
  final String? localMorte;
  final String resumo;
  final String? conteudoCompleto;
  final List<KnowledgeBlock> principaisFeitos;
  final String? influenciaHistorica;
  final AcademicConsensus? consenso;
  final List<HistoricalDebate> debates;
  final List<HistoricalCuriosity> curiosidades;
  final List<HistoricalSource> fontes;
  final List<KnowledgeRelation> relacoes;
  final List<TimelineEntry> linhaDoTempo;

  const KnowledgeEntry({
    required this.entityId,
    required this.entityType,
    required this.nome,
    this.nomeOriginal,
    this.imagemUrl,
    this.bannerUrl,
    this.periodoHistorico,
    this.civilizacao,
    this.localNascimento,
    this.localMorte,
    required this.resumo,
    this.conteudoCompleto,
    this.principaisFeitos = const [],
    this.influenciaHistorica,
    this.consenso,
    this.debates = const [],
    this.curiosidades = const [],
    this.fontes = const [],
    this.relacoes = const [],
    this.linhaDoTempo = const [],
  });

  factory KnowledgeEntry.fromJson(Map<String, dynamic> json) => KnowledgeEntry(
        entityId: json['entity_id'] as String? ?? '',
        entityType: EntityType.values.firstWhere(
          (e) => e.name == (json['entity_type'] as String? ?? 'character'),
          orElse: () => EntityType.character,
        ),
        nome: json['nome'] as String? ?? '',
        nomeOriginal: json['nome_original'] as String?,
        imagemUrl: json['imagem_url'] as String?,
        bannerUrl: json['banner_url'] as String?,
        periodoHistorico: json['periodo_historico'] as String?,
        civilizacao: json['civilizacao'] as String?,
        localNascimento: json['local_nascimento'] as String?,
        localMorte: json['local_morte'] as String?,
        resumo: json['resumo'] as String? ?? '',
        conteudoCompleto: json['conteudo_completo'] as String?,
        principaisFeitos: (json['principais_feitos'] as List<dynamic>?)
                ?.map((e) => KnowledgeBlock.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        influenciaHistorica: json['influencia_historica'] as String?,
        consenso: json['consenso'] != null
            ? AcademicConsensus.fromJson(json['consenso'] as Map<String, dynamic>)
            : null,
        debates: (json['debates'] as List<dynamic>?)
                ?.map((e) => HistoricalDebate.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        curiosidades: (json['curiosidades'] as List<dynamic>?)
                ?.map((e) => HistoricalCuriosity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        fontes: (json['fontes'] as List<dynamic>?)
                ?.map((e) => HistoricalSource.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        relacoes: (json['relacoes'] as List<dynamic>?)
                ?.map((e) => KnowledgeRelation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        linhaDoTempo: (json['linha_do_tempo'] as List<dynamic>?)
                ?.map((e) => TimelineEntry.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'entity_id': entityId,
        'entity_type': entityType.name,
        'nome': nome,
        'nome_original': nomeOriginal,
        'imagem_url': imagemUrl,
        'banner_url': bannerUrl,
        'periodo_historico': periodoHistorico,
        'civilizacao': civilizacao,
        'local_nascimento': localNascimento,
        'local_morte': localMorte,
        'resumo': resumo,
        'conteudo_completo': conteudoCompleto,
        'principais_feitos': principaisFeitos.map((e) => e.toJson()).toList(),
        'influencia_historica': influenciaHistorica,
        'consenso': consenso?.toJson(),
        'debates': debates.map((e) => e.toJson()).toList(),
        'curiosidades': curiosidades.map((e) => e.toJson()).toList(),
        'fontes': fontes.map((e) => e.toJson()).toList(),
        'relacoes': relacoes.map((e) => e.toJson()).toList(),
        'linha_do_tempo': linhaDoTempo.map((e) => e.toJson()).toList(),
      };
}

/// Entrada na linha do tempo pessoal de uma entidade.
class TimelineEntry {
  final String id;
  final int ano;
  final String titulo;
  final String? descricao;
  final ReliabilityLevel confiabilidade;

  const TimelineEntry({
    required this.id,
    required this.ano,
    required this.titulo,
    this.descricao,
    this.confiabilidade = ReliabilityLevel.fact,
  });

  factory TimelineEntry.fromJson(Map<String, dynamic> json) => TimelineEntry(
        id: json['id'] as String? ?? '',
        ano: json['ano'] as int? ?? 0,
        titulo: json['titulo'] as String? ?? '',
        descricao: json['descricao'] as String?,
        confiabilidade: ReliabilityLevel.values.firstWhere(
          (e) => e.name == (json['confiabilidade'] as String? ?? 'fact'),
          orElse: () => ReliabilityLevel.fact,
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ano': ano,
        'titulo': titulo,
        'descricao': descricao,
        'confiabilidade': confiabilidade.name,
      };
}
