import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import 'timeline_controller.dart';
import 'timeline_item.dart';

/// Painel de filtragem avançada para a Linha do Tempo.
class TimelineFilters extends StatefulWidget {
  final TimelineController controller;

  const TimelineFilters({
    super.key,
    required this.controller,
  });

  @override
  State<TimelineFilters> createState() => _TimelineFiltersState();
}

class _TimelineFiltersState extends State<TimelineFilters> {
  late TimelineItemType _selectedCategory;
  late double _startYear;
  late double _endYear;
  late double _minLimit;
  late double _maxLimit;

  final Map<String, (int start, int end)> _periodPresets = {
    'Pré-História': (-5000, -3000),
    'Antiguidade': (-3000, 476),
    'Idade Média': (476, 1453),
    'Idade Moderna': (1453, 1789),
    'Idade Contemporânea': (1789, 2100),
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.controller.selectedCategory;
    _minLimit = widget.controller.minPossibleYear.toDouble();
    _maxLimit = widget.controller.maxPossibleYear.toDouble();
    _startYear = widget.controller.startYear.toDouble();
    _endYear = widget.controller.endYear.toDouble();
  }

  String _formatYear(double yearVal) {
    final yr = yearVal.toInt();
    return yr < 0 ? '${yr.abs()} a.C.' : '$yr d.C.';
  }

  void _apply() {
    widget.controller.selectCategory(_selectedCategory);
    widget.controller.setPeriod(_startYear.toInt(), _endYear.toInt());
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _selectedCategory = TimelineItemType.all;
      _startYear = _minLimit;
      _endYear = _maxLimit;
    });
    widget.controller.resetFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros da Timeline',
                style: ChronosTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.tune_rounded, color: ChronosColors.accent),
            ],
          ),
          ChronosSpacing.vSizedBoxLG,

          Text(
            'Categoria',
            style: ChronosTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: ChronosColors.textPrimary,
            ),
          ),
          ChronosSpacing.vSizedBoxSM,
          Wrap(
            spacing: ChronosSpacing.sm,
            runSpacing: ChronosSpacing.sm,
            children: [
              _CategoryChip(
                label: 'Todos',
                selected: _selectedCategory == TimelineItemType.all,
                onTap: () => setState(() => _selectedCategory = TimelineItemType.all),
              ),
              ...widget.controller.categories.map((category) {
                return _CategoryChip(
                  label: category.label,
                  selected: _selectedCategory == category,
                  onTap: () => setState(() => _selectedCategory = category),
                );
              }),
            ],
          ),
          ChronosSpacing.vSizedBoxLG,

          Text(
            'Períodos Históricos',
            style: ChronosTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: ChronosColors.textPrimary,
            ),
          ),
          ChronosSpacing.vSizedBoxSM,
          Wrap(
            spacing: ChronosSpacing.sm,
            runSpacing: ChronosSpacing.sm,
            children: _periodPresets.entries.map((entry) {
              return ActionChip(
                label: Text(entry.key),
                onPressed: () => setState(() {
                  _startYear = entry.value.$1.toDouble();
                  _endYear = entry.value.$2.toDouble();
                }),
              );
            }).toList(),
          ),
          ChronosSpacing.vSizedBoxLG,

          Text(
            'Período Personalizado',
            style: ChronosTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: ChronosColors.textPrimary,
            ),
          ),
          ChronosSpacing.vSizedBoxSM,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatYear(_startYear)} — ${_formatYear(_endYear)}',
                style: ChronosTypography.codeSmall.copyWith(
                  color: ChronosColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(_startYear, _endYear),
            min: _minLimit,
            max: _maxLimit,
            activeColor: ChronosColors.accent,
            inactiveColor: ChronosColors.border,
            labels: RangeLabels(_formatYear(_startYear), _formatYear(_endYear)),
            onChanged: (values) {
              setState(() {
                _startYear = values.start;
                _endYear = values.end;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatYear(_minLimit), style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textMuted)),
              Text(_formatYear(_maxLimit), style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textMuted)),
            ],
          ),
          ChronosSpacing.vSizedBoxXL,

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Restaurar'),
                ),
              ),
              ChronosSpacing.hSizedBoxMD,
              Expanded(
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(backgroundColor: ChronosColors.accent),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
