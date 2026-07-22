import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/relationships/relationship_item.dart';
import '../../engine/entity_renderer.dart';
import '../../engine/entity_registry.dart';
import '../../controllers/relationship_controller.dart';
import '../../widgets/browser/entity_card.dart';
import '../../widgets/chronos_empty_view.dart';
import '../../widgets/chronos_error_view.dart';
import '../../widgets/knowledge_graph_view.dart';
import '../../widgets/relationship_section.dart';
import 'entity_details_page.dart';

/// Componente de conexões e relações de conteúdo para a tela de detalhes do CHRONOS.
class EntityDetailsRelated extends StatefulWidget {
  final dynamic entity;
  final Color color;
  final ChronosEntityDisplay? display;

  const EntityDetailsRelated({
    super.key,
    required this.entity,
    required this.color,
    this.display,
  });

  @override
  State<EntityDetailsRelated> createState() => _EntityDetailsRelatedState();
}

class _EntityDetailsRelatedState extends State<EntityDetailsRelated> {
  late final RelationshipController _controller;
  bool _showGraph = false;

  @override
  void initState() {
    super.initState();
    _controller = RelationshipController();
    final type = _resolveEntityType(widget.entity);
    final id = _resolveId(widget.entity);
    if (type != null && id != null) {
      _controller.discover(entityType: type, entityId: id);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _resolveId(dynamic entity) {
    if (entity == null) return null;
    if (entity is Map<String, dynamic>) return entity['id'] as String?;
    try { return entity.id as String?; } catch (_) {}
    return null;
  }

  String? _resolveEntityType(dynamic entity) {
    if (entity == null) return null;
    String? type;
    if (entity is Map<String, dynamic>) {
      type = entity['entity_type'] as String?;
    }
    try { type ??= entity.entityType as String?; } catch (_) {}
    try { type ??= EntityRegistry().resolveEntityType(entity); } catch (_) {}
    if (type == null) return null;
    return _toSnakeCase(type);
  }

  String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(RegExp(r'[A-Z]'), (m) => '_${m[0]!.toLowerCase()}')
        .toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: ChronosSpacing.md),
            child: ChronosSkeleton(width: double.infinity, height: 120),
          );
        }
        if (_controller.hasError) {
          return ChronosErrorView(
            message: _controller.errorMessage!,
            onRetry: () => _controller.refresh(
              entityType: _resolveEntityType(widget.entity)!,
              entityId: _resolveId(widget.entity)!,
            ),
          );
        }

        final allItems = _controller.groups.expand((g) => g.items).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RelationshipSection(groups: _controller.groups),
            if (allItems.isNotEmpty) ...[
              ChronosSpacing.vSizedBoxMD,
              Center(
                child: TextButton.icon(
                  icon: Icon(_showGraph ? Icons.list_rounded : Icons.hub_rounded),
                  label: Text(_showGraph ? 'Ocultar Grafo' : 'Ver Grafo de Conhecimento'),
                  onPressed: () => setState(() => _showGraph = !_showGraph),
                ),
              ),
              if (_showGraph)
                SizedBox(
                  height: 500,
                  child: KnowledgeGraphView(
                    sourceId: _resolveId(widget.entity) ?? '',
                    sourceTitle: widget.display?.title ?? _fallbackTitle(widget.entity),
                    sourceColor: widget.color,
                    items: allItems,
                    onNodeTap: (item) => _openRelated(context, item),
                  ),
                ),
              ChronosSpacing.vSizedBoxLG,
              if (_controller.suggestions.isNotEmpty) ...[
                const ChronosSectionTitle(title: 'Você também pode gostar de...'),
                ChronosSpacing.vSizedBoxXS,
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _controller.suggestions.length,
                    separatorBuilder: (_, __) => ChronosSpacing.hSizedBoxSM,
                    itemBuilder: (context, index) => _SuggestionCard(
                      item: _controller.suggestions[index],
                      onTap: () => _openRelated(context, _controller.suggestions[index]),
                    ),
                  ),
                ),
              ],
            ],
            if (allItems.isEmpty)
              const ChronosEmptyView(
                icon: Icons.hub_outlined,
                title: 'Sem conexões automáticas',
                description: 'Ainda não há dados suficientes para sugerir relacionamentos para este registro.',
              ),
            ChronosSpacing.vSizedBoxMD,
          ],
        );
      },
    );
  }

  String _fallbackTitle(dynamic entity) {
    if (entity is Map<String, dynamic>) return (entity['title'] ?? 'Detalhes') as String;
    try { return (entity.nome ?? entity.titulo ?? entity.name ?? 'Detalhes') as String; } catch (_) {}
    return 'Detalhes';
  }

  void _openRelated(BuildContext context, RelatedItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntityDetailsPage(entity: _toMap(item)),
      ),
    );
  }

  Map<String, dynamic> _toMap(RelatedItem item) {
    return {
      'id': item.id,
      'slug': item.slug,
      'entity_type': item.entityType,
      'title': item.title,
      'description': item.description,
      'year': item.year,
      'image_url': item.imageUrl,
      'color': item.color,
    };
  }
}

class _SuggestionCard extends StatelessWidget {
  final RelatedItem item;
  final VoidCallback onTap;

  const _SuggestionCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(item.color);
    return SizedBox(
      width: 140,
      child: ChronosCard(
        onTap: onTap,
        padding: const EdgeInsets.all(ChronosSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconFor(item.entityType), color: color),
            ChronosSpacing.vSizedBoxXS,
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ChronosTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              item.relationType,
              style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return ChronosColors.accent;
    try {
      final clean = hex.replaceFirst('#', '');
      if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
      if (clean.length == 8) return Color(int.parse(clean, radix: 16));
    } catch (_) {}
    return ChronosColors.accent;
  }

  IconData _iconFor(String entityType) {
    return switch (entityType) {
      'civilization' => Icons.account_balance_rounded,
      'historical_character' => Icons.person_rounded,
      'historical_event' => Icons.history_edu_rounded,
      'historical_location' => Icons.public_rounded,
      'artifact' => Icons.museum_rounded,
      'historical_source' => Icons.menu_book_rounded,
      _ => Icons.layers_outlined,
    };
  }
}

