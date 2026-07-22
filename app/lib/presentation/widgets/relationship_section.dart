import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/presentation/widgets/widgets.dart';
import '../../core/relationships/relationship_engine.dart';
import '../../core/relationships/relationship_item.dart';
import '../pages/details/entity_details_page.dart';

/// Seção reutilizável de itens relacionados agrupados por tipo.
class RelationshipSection extends StatelessWidget {
  final List<RelatedGroup> groups;
  final int maxItemsPerGroup;

  const RelationshipSection({
    super.key,
    required this.groups,
    this.maxItemsPerGroup = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.expand((group) {
        final items = group.items.take(maxItemsPerGroup).toList();
        return [
          ChronosSectionTitle(title: group.relationType),
          ChronosSpacing.vSizedBoxXS,
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => ChronosSpacing.hSizedBoxSM,
              itemBuilder: (context, index) => _RelatedCard(item: items[index]),
            ),
          ),
          ChronosSpacing.vSizedBoxMD,
        ];
      }).toList(),
    );
  }
}

class _RelatedCard extends StatelessWidget {
  final RelatedItem item;

  const _RelatedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(item.color);

    return SizedBox(
      width: 160,
      child: ChronosCard(
        onTap: () => _openDetails(context),
        padding: const EdgeInsets.all(ChronosSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl!,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                ),
              )
            else
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Icon(_iconFor(item.entityType), color: color)),
              ),
            ChronosSpacing.vSizedBoxXS,
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ChronosTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              item.periodLabel,
              style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
            ),
            const Spacer(),
            _StrengthBar(strength: item.strength),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    // A entidade original não está disponível; passamos um display mínimo.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntityDetailsPage(
          entity: _toMinimalMap(item),
        ),
      ),
    );
  }

  Map<String, dynamic> _toMinimalMap(RelatedItem item) {
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

class _StrengthBar extends StatelessWidget {
  final int strength;

  const _StrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    final color = strength >= 80
        ? Colors.redAccent
        : strength >= 60
            ? Colors.orangeAccent
            : strength >= 35
                ? Colors.yellowAccent
                : Colors.blueGrey;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength / 100,
              backgroundColor: ChronosColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$strength',
          style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
        ),
      ],
    );
  }
}
