/// Registro local de uma busca realizada para fins analíticos.
class SearchAnalyticsEvent {
  final String query;
  final String? category;
  final int resultCount;
  final Duration duration;
  final DateTime timestamp;

  const SearchAnalyticsEvent({
    required this.query,
    required this.category,
    required this.resultCount,
    required this.duration,
    required this.timestamp,
  });
}

/// Serviço de analytics local da busca global.
///
/// Registra query, quantidade de resultados, categoria e tempo de consulta
/// sem enviar dados para servidor (modo local).
class SearchAnalyticsService {
  final List<SearchAnalyticsEvent> _events = [];

  List<SearchAnalyticsEvent> get events => List.unmodifiable(_events);

  void record({
    required String query,
    required int resultCount,
    required Duration duration,
    String? category,
  }) {
    _events.add(SearchAnalyticsEvent(
      query: query,
      category: category,
      resultCount: resultCount,
      duration: duration,
      timestamp: DateTime.now(),
    ));
  }

  void clear() => _events.clear();
}

/// Serviço local de histórico de pesquisas.
///
/// Mantém até 10 termos de busca recentes em memória (sessão atual).
class SearchHistoryService {
  final List<String> _history = [];

  List<String> get history => List.unmodifiable(_history);

  void add(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) return;
    _history.remove(normalized);
    _history.insert(0, normalized);
    if (_history.length > 10) _history.removeLast();
  }

  void clear() => _history.clear();
}
