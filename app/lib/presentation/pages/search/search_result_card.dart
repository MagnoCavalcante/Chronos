import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/chronos_card.dart';
import '../../widgets/browser/entity_card.dart';
import '../../engine/entity_registry.dart';
import '../details/entity_details_page.dart';
import '../../../features/search/presentation/controllers/search_controller.dart';

/// Card individual de resultado de busca global.
///
/// Apresenta o resultado com destaque ao termo pesquisado (Relevance Highlights)
/// e navega diretamente para a tela unificada de detalhes ao ser tocado.
class SearchResultCard extends StatelessWidget {
  final SearchResultItem item;
  final String query;

  const SearchResultCard({
    super.key,
    required this.item,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final display = item.display;
    final themeColor = display.color ?? ChronosColors.accent;

    return Semantics(
      label: '${display.title}, ${display.subtitle}',
      hint: display.description ?? 'Registro histórico',
      button: true,
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: ChronosSpacing.md),
        child: ChronosCard(
          borderColor: themeColor.withValues(alpha: 0.2),
          padding: const EdgeInsets.all(ChronosSpacing.md),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EntityDetailsPage(
                  entity: item.originalEntity,
                  descriptor: EntityRegistry().getDescriptor(item.entityType),
                ),
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coluna do Ícone/Imagem
              _buildLeadingImageOrIcon(display, themeColor),
              ChronosSpacing.hSizedBoxMD,

              // Coluna de Texto Principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoria e Cronologia
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(ChronosRadius.xs),
                            border: Border.all(color: themeColor.withValues(alpha: 0.2), width: 0.5),
                          ),
                          child: Text(
                            display.type?.toUpperCase() ?? 'KNOWLEDGE',
                            style: ChronosTypography.codeSmall.copyWith(
                              color: themeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        if (display.chronology != null) ...[
                          ChronosSpacing.hSizedBoxSM,
                          Expanded(
                            child: Text(
                              display.chronology!,
                              style: ChronosTypography.codeSmall.copyWith(
                                color: ChronosColors.textMuted,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    ChronosSpacing.vSizedBoxSM,

                    // Título (com Destaque)
                    _buildHighlightedText(
                      display.title,
                      query,
                      ChronosTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ChronosColors.textPrimary,
                      ),
                      ChronosTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ChronosColors.accent,
                        backgroundColor: ChronosColors.accent.withValues(alpha: 0.1),
                      ),
                    ),

                    // Subtítulo
                    if (display.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        display.subtitle,
                        style: ChronosTypography.bodySmall.copyWith(
                          color: ChronosColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    // Descrição (com Destaque)
                    if (display.description != null && display.description!.isNotEmpty) ...[
                      ChronosSpacing.vSizedBoxSM,
                      _buildHighlightedText(
                        display.description!,
                        query,
                        ChronosTypography.bodySmall.copyWith(
                          color: ChronosColors.textSecondary,
                          height: 1.3,
                        ),
                        ChronosTypography.bodySmall.copyWith(
                          color: ChronosColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          backgroundColor: ChronosColors.accent.withValues(alpha: 0.12),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingImageOrIcon(ChronosEntityDisplay display, Color themeColor) {
    if (display.imageUrl != null && display.imageUrl!.isNotEmpty) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ChronosRadius.sm),
          border: Border.all(color: ChronosColors.border, width: 1.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ChronosRadius.sm - 1),
          child: Image.network(
            display.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackIconContainer(display, themeColor),
          ),
        ),
      );
    }

    return _buildFallbackIconContainer(display, themeColor);
  }

  Widget _buildFallbackIconContainer(ChronosEntityDisplay display, Color themeColor) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ChronosRadius.sm),
        border: Border.all(color: themeColor.withValues(alpha: 0.15), width: 1.0),
      ),
      child: Icon(
        display.icon ?? Icons.layers_outlined,
        color: themeColor,
        size: 24,
      ),
    );
  }

  String _normalize(String text) {
    const withDiacritics =
        'áàãâäéèêëíìîïóòõôöúùûüçÇñÑÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜ';
    const without =
        'aaaaaeeeeiiiiooooouuuucCnNAAAAAEEEEIIIIOOOOOUUUUU';
    final buffer = StringBuffer();
    for (final rune in text.toLowerCase().trim().runes) {
      final char = String.fromCharCode(rune);
      final index = withDiacritics.indexOf(char);
      buffer.write(index >= 0 ? without[index] : char);
    }
    return buffer.toString();
  }

  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle baseStyle,
    TextStyle highlightStyle, {
    int maxLines = 1,
  }) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final normalizedText = _normalize(text);

    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfQuery = normalizedText.indexOf(normalizedQuery, start);

    while (indexOfQuery != -1) {
      if (indexOfQuery > start) {
        spans.add(TextSpan(
          text: text.substring(start, indexOfQuery),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: text.substring(indexOfQuery, indexOfQuery + normalizedQuery.length),
        style: highlightStyle,
      ));
      start = indexOfQuery + normalizedQuery.length;
      indexOfQuery = normalizedText.indexOf(normalizedQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
