import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import 'timeline_controller.dart';

/// Painel de filtragem avançada para a Linha do Tempo.
///
/// Permite selecionar filtros por Era e por intervalo de período (anos)
/// utilizando um seletor visual deslizante reativo.
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
  String? _selectedEraId;
  late double _startYear;
  late double _endYear;

  late double _minLimit;
  late double _maxLimit;

  @override
  void initState() {
    super.initState();
    _selectedEraId = widget.controller.selectedEraId;
    _minLimit = widget.controller.minPossibleYear.toDouble();
    _maxLimit = widget.controller.maxPossibleYear.toDouble();

    // Garante que o limite superior é maior que o inferior
    if (_maxLimit <= _minLimit) {
      _maxLimit = _minLimit + 100.0;
    }

    _startYear = (widget.controller.startYear ?? widget.controller.minPossibleYear)
        .toDouble()
        .clamp(_minLimit, _maxLimit);
    _endYear = (widget.controller.endYear ?? widget.controller.maxPossibleYear)
        .toDouble()
        .clamp(_minLimit, _maxLimit);

    if (_startYear > _endYear) {
      _startYear = _minLimit;
      _endYear = _maxLimit;
    }
  }

  String _formatYear(double yearVal) {
    final int yr = yearVal.toInt();
    return yr < 0 ? '${yr.abs()} a.C.' : '$yr d.C.';
  }

  void _apply() {
    widget.controller.selectEra(_selectedEraId);
    widget.controller.setPeriod(_startYear.toInt(), _endYear.toInt());
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _selectedEraId = null;
      _startYear = _minLimit;
      _endYear = _maxLimit;
    });
    widget.controller.resetFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<DropdownMenuItem<String>> dropdownItems = [
      const DropdownMenuItem<String>(
        value: null,
        child: Text('Todas as Eras'),
      ),
      ...widget.controller.eras.map((era) => DropdownMenuItem<String>(
            value: era.id,
            child: Text(era.nome),
          )),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título do Painel
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

          // Filtro 1: Seleção de Era
          Text(
            'Filtrar por Era Histórica',
            style: ChronosTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: ChronosColors.textPrimary,
            ),
          ),
          ChronosSpacing.vSizedBoxSM,
          ChronosDropdown<String>(
            value: _selectedEraId,
            items: dropdownItems,
            labelText: 'Selecione uma Era específica',
            onChanged: (val) {
              setState(() {
                _selectedEraId = val;
              });
            },
          ),
          ChronosSpacing.vSizedBoxLG,

          // Filtro 2: Período Cronológico (Anos)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Período Cronológico',
                style: ChronosTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ChronosColors.textPrimary,
                ),
              ),
              Text(
                '${_formatYear(_startYear)} — ${_formatYear(_endYear)}',
                style: ChronosTypography.codeSmall.copyWith(
                  color: ChronosColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ChronosSpacing.vSizedBoxSM,
          RangeSlider(
            values: RangeValues(_startYear, _endYear),
            min: _minLimit,
            max: _maxLimit,
            activeColor: ChronosColors.accent,
            inactiveColor: ChronosColors.border,
            labels: RangeLabels(
              _formatYear(_startYear),
              _formatYear(_endYear),
            ),
            onChanged: (values) {
              setState(() {
                _startYear = values.start;
                _endYear = values.end;
              });
            },
          ),
          ChronosSpacing.vSizedBoxSM,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatYear(_minLimit), style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textMuted)),
              Text(_formatYear(_maxLimit), style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textMuted)),
            ],
          ),
          ChronosSpacing.vSizedBoxXL,

          // Ações do Filtro
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ChronosColors.textPrimary,
                    side: const BorderSide(color: ChronosColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Restaurar Padrão'),
                ),
              ),
              ChronosSpacing.hSizedBoxMD,
              Expanded(
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChronosColors.accent,
                    foregroundColor: ChronosColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Aplicar Filtros'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
