import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../services/knowledge_graph_service.dart';

/// Breadcrumb hierárquico de navegação histórica.
/// Exemplo: História → Antiguidade → Egito → Cleópatra VII
class HistoryBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final ValueChanged<BreadcrumbItem>? onTap;

  const HistoryBreadcrumb({
    super.key,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: entry.value.entityId != null
                    ? () => onTap?.call(entry.value)
                    : null,
                child: Text(
                  entry.value.label,
                  style: ChronosTypography.bodySmall.copyWith(
                    color: isLast ? ChronosColors.accent : ChronosColors.textMuted,
                    fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                    decoration: entry.value.entityId != null && !isLast
                        ? TextDecoration.underline
                        : null,
                  ),
                ),
              ),
              if (!isLast) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: ChronosColors.textMuted,
                ),
                const SizedBox(width: 4),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}
