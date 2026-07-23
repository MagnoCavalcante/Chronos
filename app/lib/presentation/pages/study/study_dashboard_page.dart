import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/study/study_models.dart';
import '../../../presentation/controllers/study_dashboard_controller.dart';
import '../../../presentation/widgets/study/collection_card.dart';
import '../../../presentation/widgets/study/progress_bar.dart';
import '../../../presentation/widgets/study/study_goal_card.dart';
import 'collections_page.dart';
import 'review_page.dart';
import 'study_plan_page.dart';

class StudyDashboardPage extends StatefulWidget {
  const StudyDashboardPage({super.key});

  @override
  State<StudyDashboardPage> createState() => _StudyDashboardPageState();
}

class _StudyDashboardPageState extends State<StudyDashboardPage> {
  final _controller = StudyDashboardController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChronosColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Aprendizagem', style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.status == DashboardStatus.loading) {
            return const Center(child: ChronosLoading());
          }
          if (_controller.status == DashboardStatus.error) {
            return ChronosEmptyState(
              title: 'Erro ao carregar',
              description: _controller.error!,
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(ChronosSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCards(),
                ChronosSpacing.vSizedBoxLG,
                if (_controller.continueStudying != null) _buildContinueStudying(),
                ChronosSpacing.vSizedBoxLG,
                _buildPendingReviews(),
                ChronosSpacing.vSizedBoxLG,
                _buildGoals(),
                ChronosSpacing.vSizedBoxLG,
                _buildCollectionsShortcut(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCards() {
    final stats = _controller.stats;
    final hours = ((stats?.totalStudyTimeSeconds ?? 0) / 3600).toStringAsFixed(1);
    return Wrap(
      spacing: ChronosSpacing.md,
      runSpacing: ChronosSpacing.md,
      children: [
        _StatCard(label: 'Horas estudadas', value: hours),
        _StatCard(label: 'Sequência', value: '${stats?.streakDays ?? 0}'),
        _StatCard(label: 'Coleções concluídas', value: '${stats?.collectionsCompleted ?? 0}'),
        _StatCard(label: 'Itens estudados', value: '${stats?.itemsStudied ?? 0}'),
      ],
    );
  }

  Widget _buildContinueStudying() {
    final progress = _controller.continueStudying!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChronosSectionTitle(title: 'Continue estudando...'),
        ChronosSpacing.vSizedBoxXS,
        ChronosCard(
          onTap: () {},
          child: ListTile(
            leading: const Icon(Icons.play_circle_fill_rounded, color: ChronosColors.accent, size: 40),
            title: Text(progress.entityId, style: ChronosTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text(progress.status.label, style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textSecondary)),
            trailing: Text('${progress.progressPercent}%', style: ChronosTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingReviews() {
    final count = _controller.pendingReviews.length;
    if (count == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChronosSectionTitle(title: 'Revisões pendentes'),
        ChronosSpacing.vSizedBoxXS,
        ChronosCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReviewPage())),
          child: ListTile(
            leading: const Icon(Icons.alarm_rounded, color: Colors.orange),
            title: Text('$count item${count == 1 ? '' : 's'} para revisar'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildGoals() {
    if (_controller.goals.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChronosSectionTitle(title: 'Metas'),
        ChronosSpacing.vSizedBoxXS,
        ..._controller.goals.take(3).map((g) => Padding(
              padding: const EdgeInsets.only(bottom: ChronosSpacing.sm),
              child: StudyGoalCard(goal: g),
            )),
      ],
    );
  }

  Widget _buildCollectionsShortcut() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ChronosSectionTitle(title: 'Coleções'),
        ChronosSpacing.vSizedBoxXS,
        ..._controller.collections.take(3).map((c) => Padding(
              padding: const EdgeInsets.only(bottom: ChronosSpacing.sm),
              child: CollectionCard(
                collection: c,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CollectionsPage())),
              ),
            )),
        ChronosSpacing.vSizedBoxSM,
        SizedBox(
          width: double.infinity,
          child: ChronosButton(
            label: 'Ver todas as coleções',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CollectionsPage())),
          ),
        ),
        ChronosSpacing.vSizedBoxSM,
        SizedBox(
          width: double.infinity,
          child: ChronosButton(
            label: 'Planos de estudo',
            variant: ChronosButtonVariant.outline,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudyPlanPage())),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(ChronosSpacing.md),
      decoration: BoxDecoration(
        color: ChronosColors.surface,
        borderRadius: BorderRadius.circular(ChronosRadius.md),
        border: Border.all(color: ChronosColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: ChronosTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: ChronosColors.accent)),
          Text(label, style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted)),
        ],
      ),
    );
  }
}
