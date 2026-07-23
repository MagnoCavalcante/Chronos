import 'package:flutter/material.dart';
import '../../../core/gamification/gamification_models.dart';
import '../../../core/gamification/level_calculator.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/theme/theme.dart';
import '../../../core/navigation/route_names.dart';
import '../../controllers/profile_controller.dart';

/// Tela de perfil gamificado do usuário.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
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

  void _openAchievements() => Navigator.of(context).pushNamed(RouteNames.achievements);
  void _openChallenges() => Navigator.of(context).pushNamed(RouteNames.challenges);
  void _openWeeklySummary() => Navigator.of(context).pushNamed(RouteNames.weeklySummary);

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return ChronosScaffold(
      title: 'Perfil',
      body: state.isLoading && state.profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(ChronosSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(state.profile),
                  ChronosSpacing.vSizedBoxLG,
                  _buildLevelCard(state.profile),
                  ChronosSpacing.vSizedBoxLG,
                  _buildStatsGrid(state),
                  ChronosSpacing.vSizedBoxLG,
                  _buildActions(state),
                  if (state.error != null) ...[
                    ChronosSpacing.vSizedBoxLG,
                    Text(state.error!, style: ChronosTypography.bodyMedium.copyWith(color: Colors.redAccent)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(UserProfile? profile) {
    return Row(
      children: [
        ChronosAvatar(
          imageUrl: profile?.avatarUrl,
          name: profile?.displayName,
          size: 80,
        ),
        ChronosSpacing.hSizedBoxLG,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.displayName ?? 'Historiador',
                style: ChronosTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              if (profile?.titleId != null)
                ChronosBadge(
                  text: profile!.titleId!,
                  style: ChronosBadgeStyle.info,
                  uppercase: false,
                ),
              Text(
                'Membro desde ${_formatDate(profile?.joinedAt ?? DateTime.now())}',
                style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard(UserProfile? profile) {
    final totalXp = profile?.totalXp ?? 0;
    final level = profile?.currentLevel ?? 1;
    final progress = LevelCalculator.levelProgress(totalXp);
    final nextXp = LevelCalculator.xpToNextLevel(totalXp);

    return ChronosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nível $level', style: ChronosTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              Text('$totalXp XP', style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.accent)),
            ],
          ),
          ChronosSpacing.vSizedBoxSM,
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: ChronosColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(ChronosColors.accent),
            ),
          ),
          ChronosSpacing.vSizedBoxSM,
          Text(
            'Faltam $nextXp XP para o nível ${level + 1}',
            style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textMuted),
          ),
          if (profile?.streakDays != null && profile!.streakDays > 0) ...[
            ChronosSpacing.vSizedBoxSM,
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: ChronosColors.warning, size: 18),
                ChronosSpacing.hSizedBoxXS,
                Text('${profile.streakDays} dias de sequência', style: ChronosTypography.bodySmall),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estatísticas', style: ChronosTypography.titleMedium),
        ChronosSpacing.vSizedBoxSM,
        Wrap(
          spacing: ChronosSpacing.md,
          runSpacing: ChronosSpacing.md,
          children: [
            _buildStatChip('Conquistas', '${state.unlockedAchievements}/${state.achievements.length}'),
            _buildStatChip('Desafios', '${state.completedChallenges}'),
            _buildStatChip('Títulos', '${state.titles.length}'),
            _buildStatChip('Resumo semanal', state.weeklySummary == null ? '-' : '${state.weeklySummary!.totalXp} XP'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value) {
    return ChronosCard(
      padding: const EdgeInsets.symmetric(horizontal: ChronosSpacing.md, vertical: ChronosSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: ChronosTypography.titleMedium.copyWith(color: ChronosColors.accent)),
          Text(label, style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildActions(ProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChronosButton(
          label: 'Conquistas',
          icon: Icons.emoji_events_rounded,
          onPressed: _openAchievements,
          variant: ChronosButtonVariant.secondary,
        ),
        ChronosSpacing.vSizedBoxSM,
        ChronosButton(
          label: 'Desafios',
          icon: Icons.flag_rounded,
          onPressed: _openChallenges,
          variant: ChronosButtonVariant.secondary,
        ),
        ChronosSpacing.vSizedBoxSM,
        ChronosButton(
          label: 'Resumo Semanal',
          icon: Icons.summarize_rounded,
          onPressed: _openWeeklySummary,
          variant: ChronosButtonVariant.secondary,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
