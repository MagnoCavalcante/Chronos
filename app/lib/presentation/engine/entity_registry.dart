import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'entity_descriptor.dart';
import 'entity_metadata.dart';
import 'entity_view.dart';

/// Centralizador de Registro de Entidades do CHRONOS.
///
/// Mantém as definições de descritores e metadados de todas as entidades do sistema.
/// Permite o cadastro dinâmico de novas entidades, respeitando o princípio Aberto/Fechado (OCP).
class EntityRegistry {
  static final EntityRegistry _instance = EntityRegistry._internal();

  factory EntityRegistry() => _instance;

  final Map<String, EntityDescriptor> _descriptors = {};
  final Map<String, EntityMetadata> _metadata = {};

  EntityRegistry._internal() {
    _registerDefaults();
  }

  /// Limpa e redefine os registros. Útil para testes ou reinicialização.
  void clear() {
    _descriptors.clear();
    _metadata.clear();
  }

  /// Registra uma nova entidade na Engine com seu descritor e metadados.
  void register({
    required EntityDescriptor descriptor,
    required EntityMetadata metadata,
  }) {
    _descriptors[descriptor.entityType] = descriptor;
    _metadata[descriptor.entityType] = metadata;
  }

  /// Recupera o descritor associado a um tipo de entidade.
  EntityDescriptor? getDescriptor(String entityType) => _descriptors[entityType];

  /// Recupera os metadados associados a um tipo de entidade.
  EntityMetadata? getMetadata(String entityType) => _metadata[entityType];

  /// Retorna a lista de todos os descritores registrados.
  List<EntityDescriptor> get allDescriptors => _descriptors.values.toList()
    ..sort((a, b) => b.priority.compareTo(a.priority));

  /// Descobre automaticamente o tipo lógico da entidade com base no seu tipo de classe em runtime.
  String resolveEntityType(dynamic entity) {
    if (entity == null) return 'unknown';

    final String typeString = entity.runtimeType.toString().toLowerCase();

    // Mapeia classes reais do Dart para chaves de tipos unificados do CHRONOS
    if (typeString == 'era') return 'era';
    if (typeString == 'event' || typeString == 'historicalevent') return 'historical_event';
    if (typeString == 'character' || typeString == 'historicalcharacter') return 'historical_character';
    if (typeString == 'civilization') return 'civilization';
    if (typeString == 'artifact') return 'artifact';
    if (typeString == 'historicallocation') return 'historical_location';
    if (typeString == 'source' || typeString == 'historicalsource') return 'historical_source';
    if (typeString == 'relation' || typeString == 'relationship') return 'relationship';

    return typeString;
  }

  /// Popula as configurações padrão das 8 entidades originais do CHRONOS.
  void _registerDefaults() {
    // -------------------------------------------------------------
    // 1. ERA
    // -------------------------------------------------------------
    register(
      descriptor: const EntityDescriptor(
        entityType: 'era',
        displayName: 'Era Histórica',
        pluralName: 'Eras Históricas',
        icon: Icons.hourglass_empty_rounded,
        color: Colors.amber,
        coverStrategy: 'placeholder_color',
        defaultView: EntityView.cards,
        defaultSort: 'chronologyAsc',
        searchFields: ['nome', 'descricaoResumida'],
        timelineSupport: true,
        priority: 1000,
        category: 'Temporal',
      ),
      metadata: const EntityMetadata(
        entityType: 'era',
        fields: [
          FieldMetadata(key: 'id', label: 'ID', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'nome', label: 'Nome', type: FieldType.text, isSearchable: true, isComparable: true),
          FieldMetadata(key: 'descricaoResumida', label: 'Descrição', type: FieldType.text, isSearchable: true),
          FieldMetadata(key: 'inicioAno', label: 'Ano de Início', type: FieldType.number, isTimelineField: true, isComparable: true),
          FieldMetadata(key: 'fimAno', label: 'Ano de Término', type: FieldType.number, isTimelineField: true, isComparable: true),
          FieldMetadata(key: 'corHex', label: 'Hex de Cor', type: FieldType.text, isHidden: true),
        ],
      ),
    );

    // -------------------------------------------------------------
    // 2. HISTORICAL EVENT
    // -------------------------------------------------------------
    register(
      descriptor: const EntityDescriptor(
        entityType: 'historical_event',
        displayName: 'Evento Histórico',
        pluralName: 'Eventos Históricos',
        icon: Icons.auto_stories_rounded,
        color: ChronosColors.accent,
        coverStrategy: 'placeholder_color',
        defaultView: EntityView.list,
        defaultSort: 'chronologyAsc',
        searchFields: ['nome', 'descricao'],
        timelineSupport: true,
        mapSupport: true,
        priority: 900,
        category: 'Temporal',
      ),
      metadata: const EntityMetadata(
        entityType: 'historical_event',
        fields: [
          FieldMetadata(key: 'id', label: 'ID', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'eraId', label: 'ID da Era', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'nome', label: 'Nome', type: FieldType.text, isSearchable: true, isComparable: true),
          FieldMetadata(key: 'descricao', label: 'Descrição Detalhada', type: FieldType.text, isSearchable: true, isAiField: true),
          FieldMetadata(key: 'anoOcorrencia', label: 'Ano de Ocorrência', type: FieldType.number, isTimelineField: true, isComparable: true),
        ],
      ),
    );

    // -------------------------------------------------------------
    // 3. HISTORICAL CHARACTER
    // -------------------------------------------------------------
    register(
      descriptor: const EntityDescriptor(
        entityType: 'historical_character',
        displayName: 'Personagem Histórico',
        pluralName: 'Personagens Históricos',
        icon: Icons.person_outline_rounded,
        color: Colors.teal,
        coverStrategy: 'placeholder_color',
        defaultView: EntityView.grid,
        defaultSort: 'nameAsc',
        searchFields: ['nome', 'titulo', 'biografia'],
        timelineSupport: true,
        aiSupport: true,
        priority: 850,
        category: 'Agentes',
      ),
      metadata: const EntityMetadata(
        entityType: 'historical_character',
        fields: [
          FieldMetadata(key: 'id', label: 'ID', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'nome', label: 'Nome', type: FieldType.text, isSearchable: true, isComparable: true),
          FieldMetadata(key: 'titulo', label: 'Título/Alcunha', type: FieldType.text, isSearchable: true),
          FieldMetadata(key: 'biografia', label: 'Biografia', type: FieldType.text, isSearchable: true, isAiField: true),
          FieldMetadata(key: 'nascimentoAno', label: 'Nascimento (Ano)', type: FieldType.number, isTimelineField: true),
          FieldMetadata(key: 'morteAno', label: 'Falecimento (Ano)', type: FieldType.number, isTimelineField: true),
        ],
      ),
    );

    // -------------------------------------------------------------
    // 4. CIVILIZATION
    // -------------------------------------------------------------
    register(
      descriptor: const EntityDescriptor(
        entityType: 'civilization',
        displayName: 'Civilização',
        pluralName: 'Civilizações',
        icon: Icons.fort_rounded,
        color: Colors.deepOrange,
        coverStrategy: 'placeholder_color',
        defaultView: EntityView.grid,
        defaultSort: 'chronologyAsc',
        searchFields: ['name', 'shortName', 'description'],
        timelineSupport: true,
        graphSupport: true,
        priority: 800,
        category: 'Sociedades',
      ),
      metadata: const EntityMetadata(
        entityType: 'civilization',
        fields: [
          FieldMetadata(key: 'id', label: 'ID', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'name', label: 'Nome Oficial', type: FieldType.text, isSearchable: true, isComparable: true),
          FieldMetadata(key: 'shortName', label: 'Nome Curto', type: FieldType.text, isSearchable: true),
          FieldMetadata(key: 'description', label: 'Descrição Completa', type: FieldType.text, isSearchable: true, isAiField: true),
          FieldMetadata(key: 'summary', label: 'Resumo Executivo', type: FieldType.text, isSearchable: true),
          FieldMetadata(key: 'startYear', label: 'Início (Ano)', type: FieldType.number, isTimelineField: true, isComparable: true),
          FieldMetadata(key: 'endYear', label: 'Queda (Ano)', type: FieldType.number, isTimelineField: true, isComparable: true),
        ],
      ),
    );

    // -------------------------------------------------------------
    // 5. ARTIFACT
    // -------------------------------------------------------------
    register(
      descriptor: const EntityDescriptor(
        entityType: 'artifact',
        displayName: 'Artefato',
        pluralName: 'Artefatos Históricos',
        icon: Icons.category_rounded,
        color: Colors.indigo,
        coverStrategy: 'network',
        defaultView: EntityView.grid,
        defaultSort: 'nameAsc',
        searchFields: ['name', 'shortName', 'description', 'material'],
        timelineSupport: true,
        priority: 750,
        category: 'Cultura Material',
      ),
      metadata: const EntityMetadata(
        entityType: 'artifact',
        fields: [
          FieldMetadata(key: 'id', label: 'ID', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'name', label: 'Nome do Artefato', type: FieldType.text, isSearchable: true, isComparable: true),
          FieldMetadata(key: 'shortName', label: 'Nome Curto', type: FieldType.text, isSearchable: true),
          FieldMetadata(key: 'description', label: 'Descrição Detalhada', type: FieldType.text, isSearchable: true),
          FieldMetadata(key: 'summary', label: 'Resumo', type: FieldType.text),
          FieldMetadata(key: 'artifactType', label: 'Tipo de Objeto', type: FieldType.text, isSearchable: true),
          FieldMetadata(key: 'originCivilizationId', label: 'ID da Civilização', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'originLocationId', label: 'ID da Localização', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'estimatedYear', label: 'Ano Estimado', type: FieldType.number, isTimelineField: true, isComparable: true),
          FieldMetadata(key: 'material', label: 'Composição/Material', type: FieldType.text, isSearchable: true, isComparable: true),
          FieldMetadata(key: 'currentLocation', label: 'Custódia Atual', type: FieldType.text, isSearchable: true),
          FieldMetadata(key: 'coverImageUrl', label: 'Imagem', type: FieldType.text, isHidden: true),
        ],
      ),
    );

    // -------------------------------------------------------------
    // 6. HISTORICAL LOCATION
    // -------------------------------------------------------------
    register(
      descriptor: const EntityDescriptor(
        entityType: 'historical_location',
        displayName: 'Localização Histórica',
        pluralName: 'Localizações Históricas',
        icon: Icons.map_rounded,
        color: Colors.green,
        coverStrategy: 'network',
        defaultView: EntityView.grid,
        defaultSort: 'nameAsc',
        searchFields: ['name', 'shortName', 'description', 'modernCountry'],
        timelineSupport: true,
        mapSupport: true,
        priority: 700,
        category: 'Geografia',
      ),
      metadata: const EntityMetadata(
        entityType: 'historical_location',
        fields: [
          FieldMetadata(key: 'id', label: 'ID', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'name', label: 'Nome Geográfico', type: FieldType.text, isSearchable: true, isComparable: true),
          FieldMetadata(key: 'shortName', label: 'Nome Curto', type: FieldType.text, isSearchable: true),
          FieldMetadata(key: 'description', label: 'Descrição do Sítio', type: FieldType.text, isSearchable: true),
          FieldMetadata(key: 'summary', label: 'Resumo', type: FieldType.text),
          FieldMetadata(key: 'latitude', label: 'Latitude', type: FieldType.number, isMapField: true),
          FieldMetadata(key: 'longitude', label: 'Longitude', type: FieldType.number, isMapField: true),
          FieldMetadata(key: 'parentLocationId', label: 'Sítio Pai ID', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'modernCountry', label: 'País Moderno', type: FieldType.text, isSearchable: true, isComparable: true),
          FieldMetadata(key: 'modernRegion', label: 'Região Moderna', type: FieldType.text, isSearchable: true),
          FieldMetadata(key: 'startYear', label: 'Ocupação Inicial (Ano)', type: FieldType.number, isTimelineField: true, isComparable: true),
          FieldMetadata(key: 'endYear', label: 'Abandono (Ano)', type: FieldType.number, isTimelineField: true, isComparable: true),
          FieldMetadata(key: 'coverImageUrl', label: 'Imagem', type: FieldType.text, isHidden: true),
        ],
      ),
    );

    // -------------------------------------------------------------
    // 7. HISTORICAL SOURCE
    // -------------------------------------------------------------
    register(
      descriptor: const EntityDescriptor(
        entityType: 'historical_source',
        displayName: 'Fonte Histórica',
        pluralName: 'Fontes Históricas',
        icon: Icons.receipt_long_rounded,
        color: Colors.brown,
        coverStrategy: 'placeholder_color',
        defaultView: EntityView.list,
        defaultSort: 'nameAsc',
        searchFields: ['titulo', 'autor', 'descricao'],
        priority: 600,
        category: 'Custódia Documental',
      ),
      metadata: const EntityMetadata(
        entityType: 'historical_source',
        fields: [
          FieldMetadata(key: 'id', label: 'ID', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'titulo', label: 'Título', type: FieldType.text, isSearchable: true, isComparable: true),
          FieldMetadata(key: 'autor', label: 'Autor da Obra', type: FieldType.text, isSearchable: true, isComparable: true),
          FieldMetadata(key: 'url', label: 'URL / Referência Digital', type: FieldType.text, isSearchable: true),
          FieldMetadata(key: 'descricao', label: 'Descrição Textual', type: FieldType.text, isSearchable: true),
        ],
      ),
    );

    // -------------------------------------------------------------
    // 8. RELATIONSHIP (RELATION)
    // -------------------------------------------------------------
    register(
      descriptor: const EntityDescriptor(
        entityType: 'relationship',
        displayName: 'Relação Semântica',
        pluralName: 'Relações Semânticas',
        icon: Icons.mediation_rounded,
        color: Colors.purple,
        coverStrategy: 'placeholder_color',
        defaultView: EntityView.list,
        defaultSort: 'nameAsc',
        searchFields: ['tipoRelacao', 'origemTipo', 'destinoTipo'],
        graphSupport: true,
        priority: 500,
        category: 'Conexões',
      ),
      metadata: const EntityMetadata(
        entityType: 'relationship',
        fields: [
          FieldMetadata(key: 'id', label: 'ID', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'origemId', label: 'Origem ID', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'origemTipo', label: 'Tipo de Origem', type: FieldType.text, isSearchable: true, isGraphField: true),
          FieldMetadata(key: 'destinoId', label: 'Destino ID', type: FieldType.text, isHidden: true),
          FieldMetadata(key: 'destinoTipo', label: 'Tipo de Destino', type: FieldType.text, isSearchable: true, isGraphField: true),
          FieldMetadata(key: 'tipoRelacao', label: 'Tipo de Relação', type: FieldType.text, isSearchable: true, isComparable: true, isGraphField: true),
        ],
      ),
    );
  }
}
