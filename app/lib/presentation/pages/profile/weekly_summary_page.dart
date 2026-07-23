import 'package:flutter/material.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/theme/theme.dart';
import '../../controllers/weekly_summary_controller.dart';

/// Tela de resumo semanal de estudos.
class WeeklySummaryPage extends StatefulWidget {
  const WeeklySummaryPage({super.key});

  @override
  State<WeeklySummaryPage> createState() => _WeeklySummaryPageState();
}

class _WeeklySummaryPageState extends State<WeeklySummaryPage> {
  late final WeeklySummaryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WeeklySummaryController();
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
    final summary = _controller.summary;
    return ChronosScaffold(
      title: 'Resumo Semanal',
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : summary == null
              ? const ChronosEmptyState(
                  icon: Icons.summarize_rounded,
                  title: 'Nenhum resumo disponível',
                  description: 'Complete alguns estudos para gerar seu resumo semanal.',
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(ChronosSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Esta semana', style: ChronosTypography.displaySmall.copyWith(fontWeight: FontWeight.bold)),
                      ChronosSpacing.vSizedBoxLG,
                      _buildMetricCard('XP ganho', '${summary.totalXp} XP', Icons.star_rounded),
                      _buildMetricCard('Horas estudadas', '${summary.hoursStudied}h', Icons.timer_rounded),
                      _buildMetricCard('Conquistas', '${summary.achievementsCount}', Icons.emoji_events_rounded),
                      _buildMetricCard('Coleções iniciadas', '${summary.collectionsStarted}', Icons.folder_open_rounded),
                      _buildMetricCard('Coleções concluídas', '${summary.collectionsCompleted}', Icons.folder_rounded),
                      if (summary.topCategories.isNotEmpty) ...[
                        ChronosSpacing.vSizedBoxLG,
                        Text('Categorias mais estudadas', style: ChronosTypography.titleMedium),
                        ChronosSpacing.vSizedBoxSM,
                        Wrap(
                          spacing: ChronosSpacing.sm,
                          runSpacing: ChronosSpacing.sm,
                          children: summary.topCategories.map((c) => ChronosBadge(text: c, uppercase: false)).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChronosSpacing.md),
      child: ChronosCard(
        child: ListTile(
          leading: Icon(icon, color: ChronosColors.accent, size: 32),
          title: Text(value, style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          subtitle: Text(label, style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textMuted)),
        ),
      ),
    );
  }
}
