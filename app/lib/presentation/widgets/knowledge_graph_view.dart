import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/relationships/relationship_item.dart';

/// Visualização interativa de grafo de conhecimento histórico.
class KnowledgeGraphView extends StatefulWidget {
  final String sourceId;
  final String sourceTitle;
  final Color sourceColor;
  final List<RelatedItem> items;
  final void Function(RelatedItem item)? onNodeTap;

  const KnowledgeGraphView({
    super.key,
    required this.sourceId,
    required this.sourceTitle,
    required this.sourceColor,
    required this.items,
    this.onNodeTap,
  });

  @override
  State<KnowledgeGraphView> createState() => _KnowledgeGraphViewState();
}

class _KnowledgeGraphViewState extends State<KnowledgeGraphView> {
  static const double _radius = 220;
  static const double _nodeSize = 64;

  @override
  Widget build(BuildContext context) {
    final size = _radius * 2 + _nodeSize * 2;

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(64),
      minScale: 0.5,
      maxScale: 4.0,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _GraphEdgePainter(
                count: widget.items.length,
                radius: _radius,
                nodeSize: _nodeSize,
                color: ChronosColors.textMuted.withValues(alpha: 0.3),
              ),
            ),
            _buildCenterNode(size / 2, size / 2),
            ..._buildRelatedNodes(size / 2, size / 2),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNode(double cx, double cy) {
    return Positioned(
      left: cx - _nodeSize / 2,
      top: cy - _nodeSize / 2,
      child: _GraphNode(
        size: _nodeSize,
        color: widget.sourceColor,
        icon: Icons.circle,
        label: widget.sourceTitle,
        onTap: null,
      ),
    );
  }

  List<Widget> _buildRelatedNodes(double cx, double cy) {
    final nodes = <Widget>[];
    final step = 2 * math.pi / math.max(widget.items.length, 1);

    for (var i = 0; i < widget.items.length; i++) {
      final angle = i * step;
      final x = cx + _radius * math.cos(angle) - _nodeSize / 2;
      final y = cy + _radius * math.sin(angle) - _nodeSize / 2;
      final item = widget.items[i];
      nodes.add(
        Positioned(
          left: x,
          top: y,
          child: _GraphNode(
            size: _nodeSize,
            color: _parseColor(item.color),
            icon: _iconFor(item.entityType),
            label: item.title,
            strength: item.strength,
            onTap: () => widget.onNodeTap?.call(item),
          ),
        ),
      );
    }
    return nodes;
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return ChronosColors.accent;
    try {
      final clean = hex.replaceFirst('#', '');
      if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
      if (clean.length == 8) return Color(int.parse(clean, radix: 16));
    } catch (_) {}
    return ChronosColors.accent;
  }

  IconData _iconFor(String entityType) {
    return switch (entityType) {
      'civilization' => Icons.account_balance_rounded,
      'historical_character' => Icons.person_rounded,
      'historical_event' => Icons.history_edu_rounded,
      'historical_location' => Icons.public_rounded,
      'artifact' => Icons.museum_rounded,
      'historical_source' => Icons.menu_book_rounded,
      _ => Icons.layers_outlined,
    };
  }
}

class _GraphNode extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;
  final String label;
  final int? strength;
  final VoidCallback? onTap;

  const _GraphNode({
    required this.size,
    required this.color,
    required this.icon,
    required this.label,
    this.strength,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.4),
          ),
          SizedBox(
            width: size + 16,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ChronosTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (strength != null)
            SizedBox(
              width: size,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: strength! / 100,
                  minHeight: 3,
                  backgroundColor: ChronosColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GraphEdgePainter extends CustomPainter {
  final int count;
  final double radius;
  final double nodeSize;
  final Color color;

  _GraphEdgePainter({
    required this.count,
    required this.radius,
    required this.nodeSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    final step = 2 * math.pi / math.max(count, 1);
    for (var i = 0; i < count; i++) {
      final angle = i * step;
      final target = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, target, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
