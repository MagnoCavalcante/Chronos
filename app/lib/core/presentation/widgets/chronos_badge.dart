import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_typography.dart';
import '../../theme/chronos_radius.dart';

enum ChronosBadgeStyle { success, error, warning, info, draft, review, neutral }

/// Badge editorial e informativo reutilizável do ecossistema CHRONOS.
///
/// Oferece variantes de cores semânticas bem delineadas a partir de tokens de design.
class ChronosBadge extends StatelessWidget {
  final String text;
  final ChronosBadgeStyle style;
  final bool uppercase;

  const ChronosBadge({
    super.key,
    required this.text,
    this.style = ChronosBadgeStyle.neutral,
    this.uppercase = true,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (style) {
      case ChronosBadgeStyle.success:
        color = ChronosColors.success;
        break;
      case ChronosBadgeStyle.error:
        color = ChronosColors.error;
        break;
      case ChronosBadgeStyle.warning:
        color = ChronosColors.warning;
        break;
      case ChronosBadgeStyle.info:
        color = ChronosColors.info;
        break;
      case ChronosBadgeStyle.review:
        color = ChronosColors.info; // review mapped to blue
        break;
      case ChronosBadgeStyle.draft:
        color = ChronosColors.warning; // draft mapped to orange/amber
        break;
      case ChronosBadgeStyle.neutral:
      default:
        color = ChronosColors.textSecondary;
        break;
    }

    final displayText = uppercase ? text.toUpperCase() : text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: ChronosRadius.borderRadiusXS,
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: Text(
        displayText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: ChronosTypography.labelSmall.copyWith(
          fontSize: 9,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
