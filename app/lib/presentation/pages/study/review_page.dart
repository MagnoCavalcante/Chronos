import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../presentation/controllers/review_controller.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _controller = ReviewController();

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
        title: Text('Modo Revisão', style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.status == ReviewStatus.loading) {
            return const Center(child: ChronosLoading());
          }
          if (_controller.status == ReviewStatus.error) {
            return ChronosEmptyState(title: 'Erro', description: _controller.error ?? '');
          }
          final items = _controller.items;
          return items.isEmpty
              ? const ChronosEmptyState(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'Sem revisões pendentes',
                  description: 'Você está em dia!',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(ChronosSpacing.lg),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: ChronosSpacing.sm),
                      child: ChronosCard(
                        child: ListTile(
                          title: Text('${item.entityType}: ${item.entityId}',
                              style: ChronosTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text('Revisão em ${item.reviewDate.toString().split(' ').first}',
                              style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textSecondary)),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_rounded, color: Colors.green),
                            onPressed: () => _controller.markReviewed(item.id),
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
