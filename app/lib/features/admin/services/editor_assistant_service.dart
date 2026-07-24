import '../../../core/utils/logger.dart';
import '../domain/entities/admin_entities.dart';

/// Assistente Editorial com IA.
///
/// Auxilia o editor com sugestões, mas NUNCA substitui a revisão humana.
/// Toda sugestão requer aprovação explícita do editor.
///
/// Funcionalidades:
/// - Identificar campos incompletos
/// - Sugerir relações entre entidades
/// - Apontar inconsistências cronológicas
/// - Sugerir fontes relacionadas
/// - Indicar classificação Fato/Teoria/Em Debate
class EditorAssistantService {
  static const _tag = 'EditorAssistant';

  /// Campos obrigatórios por tipo de entidade.
  static const _requiredFields = <AdminEntityType, List<String>>{
    AdminEntityType.character: [
      'name', 'original_name', 'period', 'civilization',
      'biography', 'historical_importance', 'sources',
    ],
    AdminEntityType.event: [
      'name', 'date', 'location', 'description',
      'consequences', 'participants', 'sources',
    ],
    AdminEntityType.civilization: [
      'name', 'period', 'culture', 'religion',
      'economy', 'territory',
    ],
    AdminEntityType.artifact: [
      'name', 'material', 'museum', 'location',
      'historical_context', 'images',
    ],
    AdminEntityType.location: [
      'name', 'coordinates', 'events', 'characters',
    ],
    AdminEntityType.source: [
      'name', 'type', 'reliability',
    ],
  };

  /// Analisa conteúdo e gera sugestões.
  List<EditorAssistantSuggestion> analyze(ManagedContent content) {
    final suggestions = <EditorAssistantSuggestion>[];
    final now = DateTime.now();

    // 1. Campos incompletos
    suggestions.addAll(_checkIncompleteFields(content, now));

    // 2. Campos de texto vazios ou muito curtos
    suggestions.addAll(_checkShortContent(content, now));

    // 3. Verificar se tem fontes
    suggestions.addAll(_checkSources(content, now));

    // 4. Verificar classificação Fato/Teoria/Debate
    suggestions.addAll(_checkClassification(content, now));

    ChronosLogger.info(
        'Análise: ${content.name} → ${suggestions.length} sugestões',
        tag: _tag);
    return suggestions;
  }

  List<EditorAssistantSuggestion> _checkIncompleteFields(
      ManagedContent content, DateTime now) {
    final required = _requiredFields[content.entityType] ?? [];
    final suggestions = <EditorAssistantSuggestion>[];

    for (final field in required) {
      final value = content.fields[field];
      if (value == null || (value is String && value.isEmpty)) {
        suggestions.add(EditorAssistantSuggestion(
          id: '${content.id}_missing_$field',
          entityId: content.id,
          type: AssistantSuggestionType.incompleteField,
          title: 'Campo "$field" vazio',
          description:
              'O campo "$field" é recomendado para ${content.entityType.label}.',
          fieldName: field,
          createdAt: now,
        ));
      }
    }
    return suggestions;
  }

  List<EditorAssistantSuggestion> _checkShortContent(
      ManagedContent content, DateTime now) {
    final suggestions = <EditorAssistantSuggestion>[];
    final textFields = ['biography', 'description', 'historical_importance',
        'culture', 'historical_context'];

    for (final field in textFields) {
      final value = content.fields[field];
      if (value is String && value.isNotEmpty && value.length < 50) {
        suggestions.add(EditorAssistantSuggestion(
          id: '${content.id}_short_$field',
          entityId: content.id,
          type: AssistantSuggestionType.incompleteField,
          title: 'Campo "$field" muito curto',
          description:
              'O campo "$field" tem apenas ${value.length} caracteres. '
              'Considere expandir para melhorar a qualidade do conteúdo.',
          fieldName: field,
          createdAt: now,
        ));
      }
    }
    return suggestions;
  }

  List<EditorAssistantSuggestion> _checkSources(
      ManagedContent content, DateTime now) {
    final suggestions = <EditorAssistantSuggestion>[];
    final sources = content.fields['sources'];

    if (sources == null ||
        (sources is List && sources.isEmpty) ||
        (sources is String && sources.isEmpty)) {
      suggestions.add(EditorAssistantSuggestion(
        id: '${content.id}_no_sources',
        entityId: content.id,
        type: AssistantSuggestionType.sourceSuggestion,
        title: 'Sem fontes cadastradas',
        description:
            'Todo conteúdo histórico deve ter ao menos uma fonte. '
            'Adicione referências bibliográficas ou acadêmicas.',
        fieldName: 'sources',
        createdAt: now,
      ));
    }
    return suggestions;
  }

  List<EditorAssistantSuggestion> _checkClassification(
      ManagedContent content, DateTime now) {
    final suggestions = <EditorAssistantSuggestion>[];
    final blocks = content.blocks;

    // Se tem blocos textuais mas nenhum bloco fact/theory/debate
    final hasTextBlocks = blocks.any((b) =>
        b.type == EditorBlockType.paragraph ||
        b.type == EditorBlockType.heading);
    final hasClassification = blocks.any((b) =>
        b.type == EditorBlockType.fact ||
        b.type == EditorBlockType.theory ||
        b.type == EditorBlockType.debate);

    if (hasTextBlocks && !hasClassification) {
      suggestions.add(EditorAssistantSuggestion(
        id: '${content.id}_no_classification',
        entityId: content.id,
        type: AssistantSuggestionType.classificationSuggestion,
        title: 'Sem classificação Fato/Teoria/Debate',
        description:
            'Considere usar blocos "Fato", "Teoria" ou "Em Debate" para '
            'diferenciar claramente o grau de certeza das informações.',
        createdAt: now,
      ));
    }
    return suggestions;
  }

  /// Sugere relações entre entidades com base no nome.
  List<EditorAssistantSuggestion> suggestRelations({
    required ManagedContent content,
    required List<ManagedContent> allContents,
  }) {
    final suggestions = <EditorAssistantSuggestion>[];
    final now = DateTime.now();
    final nameWords = content.name.toLowerCase().split(' ');

    for (final other in allContents) {
      if (other.id == content.id) continue;
      final otherWords = other.name.toLowerCase().split(' ');

      // Verificar overlap de palavras significativas (>3 chars)
      final significantOverlap = nameWords.where((w) =>
          w.length > 3 && otherWords.any((o) => o.contains(w) || w.contains(o)));

      if (significantOverlap.isNotEmpty) {
        suggestions.add(EditorAssistantSuggestion(
          id: '${content.id}_rel_${other.id}',
          entityId: content.id,
          type: AssistantSuggestionType.relationSuggestion,
          title: 'Possível relação com "${other.name}"',
          description:
              'O conteúdo "${other.name}" (${other.entityType.label}) '
              'pode estar relacionado. Deseja criar uma relação?',
          suggestedValue: other.id,
          createdAt: now,
        ));
      }
    }
    return suggestions;
  }

  /// Verifica possíveis inconsistências cronológicas.
  List<EditorAssistantSuggestion> checkChronology({
    required ManagedContent content,
    required List<ManagedContent> relatedContents,
  }) {
    final suggestions = <EditorAssistantSuggestion>[];
    final now = DateTime.now();

    final startDate = _parseYear(content.fields['start_date'] ?? content.fields['date']);
    final endDate = _parseYear(content.fields['end_date']);

    // Verificar se data de fim é antes da data de início
    if (startDate != null && endDate != null && endDate < startDate) {
      suggestions.add(EditorAssistantSuggestion(
        id: '${content.id}_chrono_invalid',
        entityId: content.id,
        type: AssistantSuggestionType.chronologyInconsistency,
        title: 'Datas inconsistentes',
        description:
            'A data de fim ($endDate) é anterior à data de início ($startDate).',
        createdAt: now,
      ));
    }

    return suggestions;
  }

  int? _parseYear(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value.replaceAll(RegExp(r'[^0-9\-]'), ''));
    return null;
  }
}
