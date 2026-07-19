import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/presentation/widgets/widgets.dart';

/// Widget de exibição de estado de carregamento com efeito de esqueleto (Skeleton Loading).
class HistoricalEventsLoading extends StatelessWidget {
  const HistoricalEventsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.lg,
        vertical: ChronosSpacing.md,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const ChronosCard(
          margin: EdgeInsets.symmetric(vertical: ChronosSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ChronosSkeleton(
                width: 38.0,
                height: 38.0,
                isCircular: true,
              ),
              SizedBox(width: ChronosSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ChronosSkeleton(width: 140.0, height: 16.0),
                        ChronosSkeleton(width: 60.0, height: 14.0),
                      ],
                    ),
                    SizedBox(height: ChronosSpacing.sm),
                    ChronosSkeleton(width: double.infinity, height: 12.0),
                    SizedBox(height: ChronosSpacing.xs),
                    ChronosSkeleton(width: 180.0, height: 12.0),
                    SizedBox(height: ChronosSpacing.md),
                    ChronosDivider(),
                    SizedBox(height: ChronosSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ChronosSkeleton(width: 100.0, height: 12.0),
                        ChronosSkeleton(width: 80.0, height: 12.0),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
