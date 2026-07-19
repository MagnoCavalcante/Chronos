import 'package:flutter/material.dart';
import 'package:chronos/core/presentation/widgets/chronos_skeleton.dart';

/// Componente visual dedicado ao estado de carregamento da listagem de Personagens Históricos.
class HistoricalCharacterLoading extends StatelessWidget {
  const HistoricalCharacterLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChronosSkeleton(width: 52, height: 52, borderRadius: BorderRadius.all(Radius.circular(12)), isCircular: false),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChronosSkeleton(width: 160, height: 16),
                        SizedBox(height: 8),
                        ChronosSkeleton(width: 110, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ChronosSkeleton(width: double.infinity, height: 12),
              SizedBox(height: 8),
              ChronosSkeleton(width: 220, height: 12),
              SizedBox(height: 16),
              ChronosSkeleton(width: 140, height: 12),
            ],
          ),
        );
      },
    );
  }
}
