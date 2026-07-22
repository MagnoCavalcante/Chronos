import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_radius.dart';

/// Componente de Imagem de Perfil / Avatar padronizado do CHRONOS.
///
/// Trata carregamentos remotos de forma assíncrona, exibindo fallbacks de iniciais do nome
/// ou ícones genéricos em caso de falha de conexão.
class ChronosAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final IconData fallbackIcon;
  final double size;
  final bool isCircular;
  final Color? borderColor;

  const ChronosAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.fallbackIcon = Icons.person_rounded,
    this.size = 40.0,
    this.isCircular = true,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderCol = borderColor ?? ChronosColors.border;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : ChronosRadius.borderRadiusSM,
        border: Border.all(color: borderCol, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: isCircular
            ? BorderRadius.circular(size / 2)
            : ChronosRadius.borderRadiusSM,
        child: _buildAvatarContent(context),
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: ChronosColors.surface,
            child: const Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ),
          );
        },
      );
    }
    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    final accentCol = ChronosColors.accent;

    if (name != null && name!.trim().isNotEmpty) {
      final cleanName = name!.trim();
      final words = cleanName.split(' ');
      String initials = '';
      if (words.length > 1) {
        initials = '${words[0][0]}${words[1][0]}';
      } else if (words[0].isNotEmpty) {
        initials = words[0][0];
      }
      initials = initials.toUpperCase();

      return Container(
        color: accentCol.withValues(alpha: 0.12),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: accentCol,
            ),
          ),
        ),
      );
    }

    return Container(
      color: ChronosColors.surfaceLight,
      child: Center(
        child: Icon(
          fallbackIcon,
          size: size * 0.55,
          color: ChronosColors.textSecondary,
        ),
      ),
    );
  }
}
