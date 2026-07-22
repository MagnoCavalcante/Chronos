import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import 'timeline_controller.dart';
import 'timeline_detail_page.dart';
import 'timeline_item.dart';

/// Lista vertical de itens da Timeline com lazy loading, markers e Hero animations.
class TimelineList extends StatefulWidget {
  final TimelineController controller;

  const TimelineList({
    super.key,
    required this.controller,
  });

  @override
  State<TimelineList> createState() => _TimelineListState();
}

class _TimelineListState extends State<TimelineList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.controller.loadMore();
    }
  }

  void _showDetails(BuildContext context, TimelineDisplayItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TimelineDetailPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.controller.filteredItems;

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(ChronosSpacing.lg),
      itemCount: items.length + (widget.controller.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: ChronosSpacing.md),
            child: Center(child: ChronosSkeleton(width: 200, height: 80)),
          );
        }
        final item = items[index];
        return _TimelineRowItem(
          item: item,
          index: index,
          totalCount: items.length,
          onTap: () => _showDetails(context, item),
        );
      },
    );
  }
}

class _TimelineRowItem extends StatelessWidget {
  final TimelineDisplayItem item;
  final int index;
  final int totalCount;
  final VoidCallback onTap;

  const _TimelineRowItem({
    required this.item,
    required this.index,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(item);
    final image = item.imageUrl;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 24,
                  color: index > 0 ? color.withValues(alpha: 0.5) : Colors.transparent,
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: ChronosColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: index < totalCount - 1 ? color.withValues(alpha: 0.5) : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
          ChronosSpacing.hSizedBoxMD,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.xs),
              child: ChronosCard(
                borderColor: color.withValues(alpha: 0.25),
                borderWidth: 1.0,
                padding: const EdgeInsets.all(ChronosSpacing.md),
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ChronosSpacing.sm,
                            vertical: ChronosSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(ChronosRadius.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.type.icon, size: 14, color: color),
                              ChronosSpacing.hSizedBoxXS,
                              Text(
                                item.type.label.toUpperCase(),
                                style: ChronosTypography.labelSmall.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          item.periodLabel,
                          style: ChronosTypography.codeSmall.copyWith(
                            color: ChronosColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ChronosSpacing.vSizedBoxXS,
                    if (image != null && image.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Hero(
                          tag: 'timeline-${item.entityType}-${item.id}',
                          child: Image.network(
                            image,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      ChronosSpacing.vSizedBoxXS,
                    ],
                    Text(
                      item.title,
                      style: ChronosTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    ChronosSpacing.vSizedBoxXXS,
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _resolveColor(TimelineDisplayItem item) {
    if (item.color != null && item.color!.isNotEmpty) {
      try {
        final clean = item.color!.replaceFirst('#', '');
        if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
        if (clean.length == 8) return Color(int.parse(clean, radix: 16));
      } catch (_) {}
    }
    return item.type.color;
  }
}
