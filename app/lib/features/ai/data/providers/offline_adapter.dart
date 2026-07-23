import '../../domain/entities/ai_entities.dart';
import 'provider_adapter.dart';

/// Adapter de fallback 100% offline.
///
/// Usa exclusivamente os dados presentes no acervo local do Chronos. É o provedor
/// padrão quando não há chaves de API configuradas ou quando a rede falha.
class OfflineAdapter extends ProviderAdapter {
  OfflineAdapter();

  @override
  String get name => 'Chronos Offline';

  @override
  AiProviderType get type => AiProviderType.offline;

  @override
  bool get isAvailable => true;

  @override
  Future<AiResponse> buildResponse(AiRequest request) async {
    final buffer = StringBuffer();

    buffer.writeln('Resposta gerada offline a partir do acervo Chronos:');
    buffer.writeln();

    if (request.searchResults.isEmpty) {
      buffer.writeln(
        'Não encontrei dados no acervo sobre "${request.question}". '
        'Tente perguntar sobre personagens, eventos, civilizações, artefatos, localizações ou fontes históricas.',
      );
    } else {
      buffer.writeln('Com base nos dados do Chronos:');
      buffer.writeln();

      for (final result in request.searchResults) {
        final year = result.chronologyValue;
        final period = year == null ? '' : (year < 0 ? '${year.abs()} a.C.' : '$year d.C.');
        buffer.writeln('• ${result.title}${period.isNotEmpty ? ' ($period)' : ''}: ${result.summary}');
      }

      if (request.timelineItems.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Linha do tempo:');
        for (final item in request.timelineItems..sort((a, b) => a.year.compareTo(b.year))) {
          final period = item.year < 0 ? '${item.year.abs()} a.C.' : '${item.year} d.C.';
          buffer.writeln('  - $period: ${item.title}');
        }
      }

      if (request.relationships.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Relacionados:');
        for (final group in request.relationships) {
          final titles = group.items.map((e) => e.title).join(', ');
          if (titles.isNotEmpty) {
            buffer.writeln('  [${group.relationType}]: $titles');
          }
        }
      }
    }

    return AiResponse(
      text: buffer.toString().trim(),
      usedExternalAi: false,
      provider: type,
      latency: const Duration(milliseconds: 150),
    );
  }
}
