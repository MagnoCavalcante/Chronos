/// Enum contendo as tipagens de dados lógicas suportadas pelos metadados de campos.
enum FieldType {
  text,
  number,
  boolean,
  datetime,
  location,
  relation,
  custom,
}

/// Representação individual das propriedades e regras de um campo de uma Entidade.
class FieldMetadata {
  final String key;
  final String label;
  final FieldType type;
  final bool isVisible;
  final bool isHidden;
  final bool isSearchable;
  final bool isComparable;
  final bool isExportable;
  final bool isIndexable;
  final bool isAiField;
  final bool isTimelineField;
  final bool isMapField;
  final bool isGraphField;

  const FieldMetadata({
    required this.key,
    required this.label,
    required this.type,
    this.isVisible = true,
    this.isHidden = false,
    this.isSearchable = false,
    this.isComparable = false,
    this.isExportable = false,
    this.isIndexable = false,
    this.isAiField = false,
    this.isTimelineField = false,
    this.isMapField = false,
    this.isGraphField = false,
  });
}

/// Estrutura responsável por descrever todos os metadados de campos de qualquer Entidade.
class EntityMetadata {
  final String entityType;
  final List<FieldMetadata> fields;

  const EntityMetadata({
    required this.entityType,
    required this.fields,
  });

  /// Retorna a lista de campos que devem ser exibidos visualmente na UI padrão.
  List<FieldMetadata> get visibleFields =>
      fields.where((f) => f.isVisible && !f.isHidden).toList();

  /// Retorna a lista de campos ocultos, úteis para IDs ou referências internas.
  List<FieldMetadata> get hiddenFields =>
      fields.where((f) => f.isHidden).toList();

  /// Retorna a lista de campos considerados para a pesquisa/busca de texto.
  List<FieldMetadata> get searchableFields =>
      fields.where((f) => f.isSearchable).toList();

  /// Retorna a lista de campos que podem ser comparados entre si.
  List<FieldMetadata> get comparableFields =>
      fields.where((f) => f.isComparable).toList();

  /// Retorna a lista de campos elegíveis para exportação estruturada (JSON, CSV, etc.).
  List<FieldMetadata> get exportableFields =>
      fields.where((f) => f.isExportable).toList();

  /// Retorna a lista de campos indexados para buscas de alta performance.
  List<FieldMetadata> get indexableFields =>
      fields.where((f) => f.isIndexable).toList();

  /// Retorna a lista de campos que a IA deve analisar ou indexar para sínteses.
  List<FieldMetadata> get aiFields =>
      fields.where((f) => f.isAiField).toList();

  /// Retorna a lista de campos que descrevem coordenadas temporais/cronológicas.
  List<FieldMetadata> get timelineFields =>
      fields.where((f) => f.isTimelineField).toList();

  /// Retorna a lista de campos contendo geolocalizações, sítios ou referências de mapa.
  List<FieldMetadata> get mapFields =>
      fields.where((f) => f.isMapField).toList();

  /// Retorna a lista de conexões direcionadas que alimentam a Graph Engine.
  List<FieldMetadata> get graphFields =>
      fields.where((f) => f.isGraphField).toList();

  /// Busca um metadado de campo pela sua chave.
  FieldMetadata? getField(String key) {
    try {
      return fields.firstWhere((f) => f.key == key);
    } catch (_) {
      return null;
    }
  }
}
