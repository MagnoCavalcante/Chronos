import 'package:flutter/material.dart';
import '../../../core/gamification/gamification_models.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/theme/theme.dart';
import '../../controllers/achievements_controller.dart';

/// Tela de conquistas e badges do usuário.
class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late final AchievementsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AchievementsController();
    _controller.addListener(_onUpdate);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ChronosScaffold(
      title: 'Conquistas',
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.achievements.isEmpty
              ? const ChronosEmptyState(
                  icon: Icons.emoji_events_rounded,
                  title: 'Nenhuma conquista ainda',
                  description: 'Continue estudando para desbloquear badges e recompensas.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(ChronosSpacing.lg),
                  itemCount: _controller.achievements.length,
                  separatorBuilder: (_, __) => ChronosSpacing.vSizedBoxMD,
                  itemBuilder: (_, index) => _buildAchievementCard(_controller.achievements[index]),
                ),
    );
  }

  Widget _buildAchievementCard(UserAchievement ua) {
    final achievement = ua.achievement;
    final color = ua.isUnlocked ? ChronosColors.accent : ChronosColors.textMuted;
    return ChronosCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconData(achievement.icon), color: color, size: 24),
          ),
          ChronosSpacing.hSizedBoxMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.name, style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                if (achievement.description != null)
                  Text(achievement.description!, style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textMuted)),
                ChronosSpacing.vSizedBoxXS,
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ua.progressPercent,
                    minHeight: 6,
                    backgroundColor: ChronosColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text('${ua.progress}/${achievement.criteriaValue}', style: ChronosTypography.bodySmall),
              ],
            ),
          ),
          if (ua.isUnlocked)
            const Icon(Icons.check_circle_rounded, color: ChronosColors.success),
        ],
      ),
    );
  }

  IconData _iconData(String? name) {
    return switch (name) {
      'menu_book' => Icons.menu_book_rounded,
      'collections_bookmark' => Icons.collections_bookmark_rounded,
      'account_balance' => Icons.account_balance_rounded,
      'temple_buddhist' => Icons.temple_buddhist_rounded,
      'groups' => Icons.groups_rounded,
      'event_note' => Icons.event_note_rounded,
      'local_fire_department' => Icons.local_fire_department_rounded,
      'whatshot' => Icons.whatshot_rounded,
      'workspace_premium' => Icons.workspace_premium_rounded,
      'travel_explore' => Icons.travel_explore_rounded,
      'search' => Icons.search_rounded,
      _ => Icons.emoji_events_rounded,
    };
  }
}
