import 'package:flutter/material.dart';
import '../../core/theme/chronos_colors.dart';
import '../../core/theme/chronos_radius.dart';
import '../../core/theme/chronos_spacing.dart';
import '../../core/theme/chronos_typography.dart';

/// Widget unificado para exibição de imagens de destaque (Hero Images / Banners) no CHRONOS.
///
/// Trata de forma graciosa o carregamento de URLs remotas, apresentando
/// placeholders estilizados, spinners ou widgets de fallback personalizados.
class ChronosImageBanner extends StatelessWidget {
  final String? imageUrl;
  final Widget? placeholder;
  final Widget? fallback;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const ChronosImageBanner({
    super.key,
    required this.imageUrl,
    this.placeholder,
    this.fallback,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? ChronosRadius.borderRadiusMD;

    Widget buildPlaceholder() {
      return placeholder ??
          Container(
            color: ChronosColors.surfaceLight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_rounded,
                    color: ChronosColors.textMuted,
                    size: 36,
                  ),
                  ChronosSpacing.vSizedBoxXS,
                  Text(
                    'Carregando registro visual...',
                    style: ChronosTypography.bodySmall.copyWith(
                      color: ChronosColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    Widget buildFallback() {
      return fallback ??
          Container(
            color: ChronosColors.surfaceLight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.broken_image_rounded,
                    color: ChronosColors.textMuted,
                    size: 36,
                  ),
                  ChronosSpacing.vSizedBoxXS,
                  Text(
                    'Registro visual indisponível',
                    style: ChronosTypography.bodySmall.copyWith(
                      color: ChronosColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    Widget imageWidget;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      imageWidget = buildFallback();
    } else {
      imageWidget = Image.network(
        imageUrl!,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return buildFallback();
        },
      );
    }

    return Semantics(
      label: 'Banner visual da entidade histórica',
      child: ClipRRect(
        borderRadius: radius,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: ChronosColors.surface,
              border: Border.all(
                color: ChronosColors.border,
                width: 1.0,
              ),
              borderRadius: radius,
            ),
            child: imageWidget,
          ),
        ),
      ),
    );
  }
}
