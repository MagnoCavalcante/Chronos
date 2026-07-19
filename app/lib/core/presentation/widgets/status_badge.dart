import 'package:flutter/material.dart';

/// Um pequeno badge visual reutilizável para indicar o status editorial de publicação
/// (draft, review, published, archived) no ecossistema CHRONOS.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    switch (status.toLowerCase()) {
      case 'published':
        badgeColor = Colors.green;
        break;
      case 'draft':
        badgeColor = Colors.orange;
        break;
      case 'review':
        badgeColor = Colors.blue;
        break;
      case 'archived':
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: badgeColor.withValues(alpha: 0.35), width: 1.0),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: badgeColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
