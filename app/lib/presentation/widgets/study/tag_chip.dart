import 'package:flutter/material.dart';
import '../../../core/study/study_models.dart';

/// Chip visual para tags pessoais.
class TagChip extends StatelessWidget {
  final Tag tag;
  final bool selected;
  final VoidCallback? onTap;

  const TagChip({
    super.key,
    required this.tag,
    this.selected = false,
    this.onTap,
  });

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
      if (clean.length == 8) return Color(int.parse(clean, radix: 16));
    } catch (_) {}
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(tag.color);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tag.name,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
