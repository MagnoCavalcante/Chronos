import 'package:flutter/material.dart';
import '../presentation/widgets/chronos_card.dart';
import '../theme/theme.dart';

/// Card genérico para listagens CRUD com menu de ações (Editar, Excluir, Compartilhar).
class CrudCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const CrudCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return ChronosCard(
      margin: const EdgeInsets.symmetric(
        horizontal: ChronosSpacing.md,
        vertical: ChronosSpacing.xs,
      ),
      onTap: onTap,
      child: Row(
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          if (imageUrl != null && imageUrl!.isNotEmpty) ChronosSpacing.hSizedBoxMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ChronosTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ChronosTypography.bodyMedium.copyWith(
                      color: ChronosColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: ChronosColors.textMuted),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit?.call();
                case 'delete':
                  onDelete?.call();
                case 'share':
                  onShare?.call();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              const PopupMenuItem(value: 'delete', child: Text('Excluir')),
              const PopupMenuItem(value: 'share', child: Text('Compartilhar')),
            ],
          ),
        ],
      ),
    );
  }
}
