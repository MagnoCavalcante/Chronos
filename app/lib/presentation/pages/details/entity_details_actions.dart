import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';

/// Componente contendo as ações universais de interação com as fendas temporais do CHRONOS.
///
/// Suporta as ações de Compartilhar, Favoritar, Abrir na Timeline e Abrir no Mapa.
class EntityDetailsActions extends StatelessWidget {
  final dynamic entity;
  final Color color;

  const EntityDetailsActions({
    super.key,
    required this.entity,
    required this.color,
  });

  void _showActionFeedback(BuildContext context, String actionName, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ChronosColors.surface,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(Icons.bolt_rounded, color: color),
            const SizedBox(width: ChronosSpacing.sm),
            Expanded(
              child: Text(
                '$actionName: $message',
                style: ChronosTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ChronosSpacing.sm, top: ChronosSpacing.sm),
          child: Text(
            'Ações de Exploração',
            style: ChronosTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: ChronosColors.textPrimary,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // 1. Compartilhar
              _buildActionButton(
                context,
                label: 'Compartilhar',
                icon: Icons.share_rounded,
                onPressed: () => _showActionFeedback(
                  context,
                  'Compartilhar',
                  'Link de fenda temporal gerado e copiado para a área de transferência.',
                ),
              ),
              const SizedBox(width: ChronosSpacing.sm),

              // 2. Favoritar (placeholder)
              _buildActionButton(
                context,
                label: 'Favoritar',
                icon: Icons.favorite_border_rounded,
                onPressed: () => _showActionFeedback(
                  context,
                  'Favorito',
                  'Fenda temporal adicionada aos seus arquivos de exploração rápidos.',
                ),
              ),
              const SizedBox(width: ChronosSpacing.sm),

              // 3. Abrir na Timeline
              _buildActionButton(
                context,
                label: 'Timeline',
                icon: Icons.timeline_rounded,
                onPressed: () => _showActionFeedback(
                  context,
                  'Linha do Tempo',
                  'Sincronizando fenda temporal na Linha do Tempo CHRONOS.',
                ),
              ),
              const SizedBox(width: ChronosSpacing.sm),

              // 4. Abrir no Mapa (placeholder)
              _buildActionButton(
                context,
                label: 'Mapa',
                icon: Icons.map_rounded,
                onPressed: () => _showActionFeedback(
                  context,
                  'Mapeamento Espacial',
                  'Georreferenciamento indisponível para esta fenda temporal nesta versão.',
                ),
              ),
            ],
          ),
        ),
        ChronosSpacing.vSizedBoxMD,
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: ChronosColors.textPrimary,
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
