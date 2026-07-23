import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../presentation/controllers/study_plan_controller.dart';

class StudyPlanPage extends StatefulWidget {
  const StudyPlanPage({super.key});

  @override
  State<StudyPlanPage> createState() => _StudyPlanPageState();
}

class _StudyPlanPageState extends State<StudyPlanPage> {
  final _controller = StudyPlanController();

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
        title: Text('Planos de Estudo', style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ChronosColors.accent,
        onPressed: _showCreatePlanDialog,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.status == StudyPlanStatus.loading) {
            return const Center(child: ChronosLoading());
          }
          if (_controller.status == StudyPlanStatus.error) {
            return ChronosEmptyState(title: 'Erro', description: _controller.error ?? '');
          }
          final plans = _controller.plans;
          return plans.isEmpty
              ? const ChronosEmptyState(
                  icon: Icons.calendar_month_outlined,
                  title: 'Nenhum plano',
                  description: 'Crie um roteiro cronológico de estudos.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(ChronosSpacing.lg),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final items = _controller.items[plan.id] ?? [];
                    final completed = items.where((i) => i.completed).length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: ChronosSpacing.md),
                      child: ChronosCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plan.title, style: ChronosTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                            Text('$completed / ${items.length} dias concluídos', style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textSecondary)),
                            ChronosSpacing.vSizedBoxSM,
                            ...items.take(3).map((i) => CheckboxListTile(
                                  dense: true,
                                  title: Text('Dia ${i.dayNumber}: ${i.title}', style: ChronosTypography.bodySmall),
                                  value: i.completed,
                                  onChanged: (_) => _controller.toggleComplete(i.id, !i.completed),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  void _showCreatePlanDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ChronosColors.surface,
        title: Text('Novo plano', style: ChronosTypography.titleSmall),
        content: TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Título')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                await _controller.createPlan(title);
                if (mounted) Navigator.of(context).pop();
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}
