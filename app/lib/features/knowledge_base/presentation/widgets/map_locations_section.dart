import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../services/knowledge_graph_service.dart';

/// Seção de Mapa Contextual — locais associados a uma entidade.
class MapLocationsSection extends StatelessWidget {
  final List<MapLocationData> locations;
  final ValueChanged<MapLocationData>? onTap;

  const MapLocationsSection({
    super.key,
    required this.locations,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
          child: Row(
            children: [
              Icon(Icons.map_rounded, color: const Color(0xFF009688), size: 20),
              const SizedBox(width: ChronosSpacing.sm),
              Text(
                'Localizações',
                style: ChronosTypography.titleMedium.copyWith(
                  color: ChronosColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        ...locations.map(_buildLocationItem),
      ],
    );
  }

  Widget _buildLocationItem(MapLocationData loc) {
    return GestureDetector(
      onTap: () => onTap?.call(loc),
      child: Padding(
        padding: const EdgeInsets.only(bottom: ChronosSpacing.xs),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ChronosSpacing.md,
            vertical: ChronosSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: ChronosColors.surface,
            borderRadius: ChronosRadius.borderRadiusSM,
            border: Border.all(color: const Color(0xFF009688).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(_tipoIcon(loc.tipo), size: 16, color: const Color(0xFF009688)),
              const SizedBox(width: ChronosSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.location,
                      style: ChronosTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      loc.label,
                      style: ChronosTypography.labelSmall.copyWith(
                        color: ChronosColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (loc.entityId != null)
                Icon(Icons.chevron_right_rounded, size: 16, color: ChronosColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  IconData _tipoIcon(String tipo) {
    switch (tipo) {
      case 'nascimento':
        return Icons.child_friendly_rounded;
      case 'morte':
        return Icons.church_rounded;
      case 'capital':
        return Icons.location_city_rounded;
      case 'batalha':
        return Icons.shield_rounded;
      default:
        return Icons.place_rounded;
    }
  }
}
