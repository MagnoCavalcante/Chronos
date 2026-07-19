import 'package:flutter/material.dart';
import 'package:chronos/core/presentation/widgets/chronos_card.dart';
import 'package:chronos/core/presentation/widgets/chronos_skeleton.dart';

class CivilizationsLoading extends StatelessWidget {
  const CivilizationsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const ChronosCard(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              ChronosSkeleton(width: 48, height: 48, isCircular: true),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChronosSkeleton(width: 140, height: 16),
                    SizedBox(height: 8),
                    ChronosSkeleton(width: double.infinity, height: 12),
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
