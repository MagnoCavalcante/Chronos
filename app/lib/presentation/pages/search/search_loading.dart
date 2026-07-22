import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/chronos_skeleton.dart';

/// Visão de carregamento e indexação dinâmica do buscador temporal.
class SearchLoading extends StatelessWidget {
  const SearchLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(ChronosSpacing.md),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: ChronosSpacing.md),
          child: Container(
            padding: const EdgeInsets.all(ChronosSpacing.md),
            decoration: BoxDecoration(
              color: ChronosColors.surface,
              borderRadius: BorderRadius.circular(ChronosRadius.md),
              border: Border.all(color: ChronosColors.border, width: 1.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícone / Círculo de Placeholder
                ChronosSkeleton(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.circular(20),
                ),
                ChronosSpacing.hSizedBoxMD,
                // Bloco de conteúdo de texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const ChronosSkeleton(
                            width: 120,
                            height: 16,
                          ),
                          const Spacer(),
                          const ChronosSkeleton(
                            width: 60,
                            height: 12,
                          ),
                        ],
                      ),
                      ChronosSpacing.vSizedBoxSM,
                      const ChronosSkeleton(
                        width: 80,
                        height: 12,
                      ),
                      ChronosSpacing.vSizedBoxMD,
                      const ChronosSkeleton(
                        width: double.infinity,
                        height: 12,
                      ),
                      ChronosSpacing.vSizedBoxSM,
                      const ChronosSkeleton(
                        width: 180,
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
