import 'package:flutter/material.dart';
import 'package:chronos/core/presentation/widgets/chronos_card.dart';
import 'package:chronos/core/presentation/widgets/chronos_badge.dart';
import 'package:chronos/core/theme/chronos_colors.dart';
import 'package:chronos/core/theme/chronos_icons.dart';
import 'package:chronos/core/theme/chronos_radius.dart';
import 'package:chronos/core/theme/chronos_typography.dart';
import '../../domain/entities/civilization.dart';

class CivilizationCard extends StatelessWidget {
  final Civilization item;
  final VoidCallback? onTap;

  const CivilizationCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      borderRadius: ChronosRadius.borderRadiusMD,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ChronosColors.accent.withValues(alpha: 0.12),
              borderRadius: ChronosRadius.borderRadiusSM,
            ),
            child: const Icon(ChronosIcons.era, color: ChronosColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChronosBadge(
                      text: item.shortName.isEmpty ? 'CIV' : item.shortName.toUpperCase(),
                      style: ChronosBadgeStyle.info,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.summary.isEmpty ? item.description : item.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (item.startYear != null)
                      Text(
                        '${item.startYear} — ${item.endYear ?? 'atual'}',
                        style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
