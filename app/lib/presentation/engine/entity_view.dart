/// Enum contendo as modalidades de visualização unificadas para qualquer Entidade do CHRONOS.
enum EntityView {
  list,
  grid,
  cards,
  compact,
  details,
  timeline,
  map,
  graph,
  comparison,
  preview,
  searchResult,
  aiResult,
}

/// Extensão para mapear e expandir descrições textuais amigáveis a cada modalidade visual.
extension EntityViewExtension on EntityView {
  String get label {
    switch (this) {
      case EntityView.list:
        return 'Lista';
      case EntityView.grid:
        return 'Grade';
      case EntityView.cards:
        return 'Cards Expandidos';
      case EntityView.compact:
        return 'Compacto';
      case EntityView.details:
        return 'Detalhado';
      case EntityView.timeline:
        return 'Linha do Tempo';
      case EntityView.map:
        return 'Georreferenciado (Mapa)';
      case EntityView.graph:
        return 'Grafo de Conexões';
      case EntityView.comparison:
        return 'Comparativo';
      case EntityView.preview:
        return 'Pré-visualização';
      case EntityView.searchResult:
        return 'Resultado de Busca';
      case EntityView.aiResult:
        return 'Resposta IA';
    }
  }
}
