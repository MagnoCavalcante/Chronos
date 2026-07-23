import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/study/study_models.dart';

/// Card de meta de estudo com barra de avanço.
class StudyGoalCard extends StatelessWidget {
  final StudyGoal goal;
  final VoidCallback? onTap;

  const StudyGoalCard({super.key, required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final percent = goal.targetValue > 0 ? goal.currentValue / goal.targetValue : 0.0;
    return ChronosCard(
      onTap: onTap,
      padding: const EdgeInsets.all(ChronosSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: ChronosTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (goal.completed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(ChronosRadius.xs),
                  ),
                  child: Text('Concluída', style: ChronosTypography.labelSmall.copyWith(color: Colors.green)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: ChronosColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(ChronosColors.accent),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${goal.currentValue} / ${goal.targetValue}',
            style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
          ),
        ],
      ),
    );
  }
}
