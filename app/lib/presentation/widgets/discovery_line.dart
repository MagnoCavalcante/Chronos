import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme.dart';
import '../../core/presentation/widgets/widgets.dart';
import '../../core/relationships/relationship_item.dart';
import '../pages/details/entity_details_page.dart';

/// Modelo de um passo na Linha de Descoberta.
class DiscoveryStep {
  final String entityType;
  final String entityId;
  final String title;
  final String? imageUrl;
  final String? color;

  const DiscoveryStep({
    required this.entityType,
    required this.entityId,
    required this.title,
    this.imageUrl,
    this.color,
  });

  Map<String, dynamic> toJson() => {
        'entity_type': entityType,
        'entity_id': entityId,
        'title': title,
        'image_url': imageUrl,
        'color': color,
      };

  factory DiscoveryStep.fromJson(Map<String, dynamic> json) => DiscoveryStep(
        entityType: json['entity_type'] as String,
        entityId: json['entity_id'] as String,
        title: json['title'] as String,
        imageUrl: json['image_url'] as String?,
        color: json['color'] as String?,
      );
}

/// Gerenciador local da Linha de Descoberta.
class DiscoveryLineService {
  static const _key = 'discovery_line';

  Future<List<DiscoveryStep>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => DiscoveryStep.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> save(List<DiscoveryStep> steps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(steps.map((s) => s.toJson()).toList()));
  }

  Future<void> add(DiscoveryStep step) async {
    final steps = await load();
    // Evita duplicados consecutivos
    if (steps.isNotEmpty &&
        steps.last.entityType == step.entityType &&
        steps.last.entityId == step.entityId) {
      return;
    }
    steps.add(step);
    await save(steps);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// Widget visual horizontal da Linha de Descoberta.
class DiscoveryLine extends StatefulWidget {
  const DiscoveryLine({super.key});

  @override
  State<DiscoveryLine> createState() => _DiscoveryLineState();
}

class _DiscoveryLineState extends State<DiscoveryLine> {
  final _service = DiscoveryLineService();
  List<DiscoveryStep> _steps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final steps = await _service.load();
    setState(() {
      _steps = steps;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const ChronosSkeleton(width: double.infinity, height: 80);
    if (_steps.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ChronosSectionTitle(title: 'Linha de Descoberta'),
            TextButton(
              onPressed: () async {
                await _service.clear();
                _load();
              },
              child: const Text('Limpar'),
            ),
          ],
        ),
        ChronosSpacing.vSizedBoxXS,
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _steps.length,
            separatorBuilder: (_, __) => const _StepConnector(),
            itemBuilder: (context, index) => _StepChip(
              step: _steps[index],
              isLast: index == _steps.length - 1,
              onTap: () => _open(context, _steps[index]),
            ),
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context, DiscoveryStep step) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntityDetailsPage(
          entity: {
            'id': step.entityId,
            'entity_type': step.entityType,
            'title': step.title,
            'image_url': step.imageUrl,
            'color': step.color,
          },
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final DiscoveryStep step;
  final bool isLast;
  final VoidCallback onTap;

  const _StepChip({
    required this.step,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(step.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (step.imageUrl != null && step.imageUrl!.isNotEmpty)
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(step.imageUrl!),
                backgroundColor: color,
              )
            else
              CircleAvatar(
                radius: 18,
                backgroundColor: color,
                child: Icon(_iconFor(step.entityType), color: Colors.white, size: 18),
              ),
            ChronosSpacing.hSizedBoxSM,
            Flexible(
              child: Text(
                step.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ChronosTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (isLast)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.place, size: 14, color: color),
              ),
          ],
        ),
      ),
    );
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

class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(Icons.arrow_downward_rounded, size: 16, color: ChronosColors.textMuted),
    );
  }
}
