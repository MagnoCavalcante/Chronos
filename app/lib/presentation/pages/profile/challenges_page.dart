import 'package:flutter/material.dart';
import '../../../core/gamification/gamification_models.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/theme/theme.dart';
import '../../controllers/challenges_controller.dart';

/// Tela de desafios diários, semanais e mensais.
class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  late final ChallengesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChallengesController();
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
      title: 'Desafios',
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.challenges.isEmpty
              ? const ChronosEmptyState(
                  icon: Icons.flag_rounded,
                  title: 'Sem desafios ativos',
                  description: 'Volte em breve para novos desafios e recompensas.',
                )
              : ListView(
                  padding: const EdgeInsets.all(ChronosSpacing.lg),
                  children: [
                    _buildSection('Diários', _controller.daily),
                    _buildSection('Semanais', _controller.weekly),
                    _buildSection('Mensais', _controller.monthly),
                  ],
                ),
    );
  }

  Widget _buildSection(String title, List<Challenge> challenges) {
    if (challenges.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ChronosTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
        ChronosSpacing.vSizedBoxSM,
        ...challenges.map(_buildChallengeCard),
        ChronosSpacing.vSizedBoxLG,
      ],
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final color = challenge.completed ? ChronosColors.success : ChronosColors.accent;
    return ChronosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(challenge.title, style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              if (challenge.completed) const Icon(Icons.check_circle_rounded, color: ChronosColors.success),
            ],
          ),
          if (challenge.description != null)
            Text(challenge.description!, style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textMuted)),
          ChronosSpacing.vSizedBoxSM,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: challenge.progressPercent,
              minHeight: 8,
              backgroundColor: ChronosColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          ChronosSpacing.vSizedBoxXS,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${challenge.currentValue}/${challenge.targetValue}', style: ChronosTypography.bodySmall),
              Text('+${challenge.rewardXp} XP', style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.accent)),
            ],
          ),
        ],
      ),
    );
  }
}
