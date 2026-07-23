import 'package:flutter/material.dart';

import '../../domain/entities/knowledge_entities.dart';

/// Badge visual para indicar o nível de confiabilidade de uma informação.
///
/// 🟢 Fato Histórico | 🟡 Teoria | 🟠 Hipótese | 🔴 Em discussão
class ReliabilityBadge extends StatelessWidget {
  final ReliabilityLevel level;
  final bool compact;

  const ReliabilityBadge({
    super.key,
    required this.level,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 8 : 10,
            height: compact ? 8 : 10,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color {
    switch (level) {
      case ReliabilityLevel.fact:
        return const Color(0xFF4CAF50); // Verde
      case ReliabilityLevel.theory:
        return const Color(0xFFFFC107); // Amarelo
      case ReliabilityLevel.hypothesis:
        return const Color(0xFFFF9800); // Laranja
      case ReliabilityLevel.disputed:
        return const Color(0xFFF44336); // Vermelho
    }
  }

  String get _label {
    switch (level) {
      case ReliabilityLevel.fact:
        return 'Fato Histórico';
      case ReliabilityLevel.theory:
        return 'Teoria';
      case ReliabilityLevel.hypothesis:
        return 'Hipótese';
      case ReliabilityLevel.disputed:
        return 'Em discussão';
    }
  }
}
