import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/timeline/timeline_repository.dart';
import 'timeline_item.dart';

/// Página de detalhes de um item da Timeline com itens cronologicamente relacionados.
class TimelineDetailPage extends StatefulWidget {
  final TimelineDisplayItem item;

  const TimelineDetailPage({super.key, required this.item});

  @override
  State<TimelineDetailPage> createState() => _TimelineDetailPageState();
}

class _TimelineDetailPageState extends State<TimelineDetailPage> {
  final TimelineRepository _repository = TimelineRepository();
  List<TimelineDisplayItem> _related = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRelated();
  }

  Future<void> _loadRelated() async {
    final related = await _repository.getRelatedItems(
      entityType: widget.item.entityType,
      entityId: widget.item.id,
    );
    if (mounted) {
      setState(() {
        _related = related;
        _isLoading = false;
      });
    }
  }

  Color _resolveColor() {
    final color = widget.item.color;
    if (color != null && color.isNotEmpty) {
      try {
        final clean = color.replaceFirst('#', '');
        if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
        if (clean.length == 8) return Color(int.parse(clean, radix: 16));
      } catch (_) {}
    }
    return widget.item.type.color;
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor();
    final image = widget.item.imageUrl;

    return ChronosScaffold(
      title: widget.item.type.label,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(ChronosSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null && image.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Hero(
                  tag: 'timeline-${widget.item.entityType}-${widget.item.id}',
                  child: Image.network(
                    image,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            if (image != null && image.isNotEmpty) ChronosSpacing.vSizedBoxMD,
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ChronosSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.item.type.icon, color: color),
                ),
                ChronosSpacing.hSizedBoxMD,
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: ChronosTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ChronosSpacing.vSizedBoxSM,
            Text(
              widget.item.periodLabel,
              style: ChronosTypography.codeSmall.copyWith(color: ChronosColors.textMuted),
            ),
            ChronosSpacing.vSizedBoxMD,
            Text(
              widget.item.description,
              style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textSecondary, height: 1.5),
            ),
            ChronosSpacing.vSizedBoxLG,
            const ChronosSectionTitle(title: 'Relações Cronológicas'),
            ChronosSpacing.vSizedBoxSM,
            if (_isLoading)
              const ChronosSkeleton(width: double.infinity, height: 120)
            else if (_related.isEmpty)
              const Text(
                'Nenhum item relacionado encontrado para este período.',
                style: TextStyle(color: ChronosColors.textMuted),
              )
            else
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _related.length,
                  separatorBuilder: (_, __) => ChronosSpacing.hSizedBoxSM,
                  itemBuilder: (context, index) {
                    final related = _related[index];
                    return _RelatedCard(item: related);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RelatedCard extends StatelessWidget {
  final TimelineDisplayItem item;

  const _RelatedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.color != null && item.color!.isNotEmpty
        ? _parseColor(item.color!)
        : item.type.color;

    return SizedBox(
      width: 140,
      child: ChronosCard(
        padding: const EdgeInsets.all(ChronosSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.type.icon, color: color),
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
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
      if (clean.length == 8) return Color(int.parse(clean, radix: 16));
    } catch (_) {}
    return ChronosColors.accent;
  }
}
