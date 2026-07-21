import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/chronos_card.dart';
import '../../../domain/entities/publication_status.dart';

/// Modelo de parâmetros de filtragem unificado e reativo para Entidades do CHRONOS.
class EntityFilterParams {
  final PublicationStatus? status;
  final int? startYear;
  final int? endYear;
  final String? type;
  final String? category;

  const EntityFilterParams({
    this.status,
    this.startYear,
    this.endYear,
    this.type,
    this.category,
  });

  bool get isEmpty =>
      status == null &&
      startYear == null &&
      endYear == null &&
      type == null &&
      category == null;

  EntityFilterParams copyWith({
    PublicationStatus? status,
    int? startYear,
    int? endYear,
    String? type,
    String? category,
    bool clearStatus = false,
    bool clearStartYear = false,
    bool clearEndYear = false,
    bool clearType = false,
    bool clearCategory = false,
  }) {
    return EntityFilterParams(
      status: clearStatus ? null : (status ?? this.status),
      startYear: clearStartYear ? null : (startYear ?? this.startYear),
      endYear: clearEndYear ? null : (endYear ?? this.endYear),
      type: clearType ? null : (type ?? this.type),
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  EntityFilterParams clear() {
    return const EntityFilterParams();
  }
}

/// Painel lateral/modal deslizante de filtros contendo campos para refinar as listas do CHRONOS.
class EntityFiltersSheet extends StatefulWidget {
  final EntityFilterParams initialParams;
  final List<String>? availableTypes;
  final List<String>? availableCategories;
  final ValueChanged<EntityFilterParams> onApply;

  const EntityFiltersSheet({
    super.key,
    required this.initialParams,
    this.availableTypes,
    this.availableCategories,
    required this.onApply,
  });

  @override
  State<EntityFiltersSheet> createState() => _EntityFiltersSheetState();
}

class _EntityFiltersSheetState extends State<EntityFiltersSheet> {
  late EntityFilterParams _params;
  final TextEditingController _startYearController = TextEditingController();
  final TextEditingController _endYearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _params = widget.initialParams;
    if (_params.startYear != null) {
      _startYearController.text = _params.startYear.toString();
    }
    if (_params.endYear != null) {
      _endYearController.text = _params.endYear.toString();
    }
  }

  @override
  void dispose() {
    _startYearController.dispose();
    _endYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ChronosColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ChronosRadius.lg),
          topRight: Radius.circular(ChronosRadius.lg),
        ),
      ),
      padding: EdgeInsets.only(
        left: ChronosSpacing.lg,
        right: ChronosSpacing.lg,
        top: ChronosSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + ChronosSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(color: ChronosColors.border),
            ChronosSpacing.vSizedBoxMD,
            _buildStatusSection(),
            ChronosSpacing.vSizedBoxLG,
            _buildPeriodSection(),
            if (widget.availableTypes != null && widget.availableTypes!.isNotEmpty) ...[
              ChronosSpacing.vSizedBoxLG,
              _buildTypeSection(),
            ],
            if (widget.availableCategories != null && widget.availableCategories!.isNotEmpty) ...[
              ChronosSpacing.vSizedBoxLG,
              _buildCategorySection(),
            ],
            ChronosSpacing.vSizedBoxXL,
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.tune_rounded, color: ChronosColors.accent),
            ChronosSpacing.hSizedBoxSM,
            Text(
              'Refinar Busca',
              style: ChronosTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _params = const EntityFilterParams();
              _startYearController.clear();
              _endYearController.clear();
            });
          },
          child: Text(
            'Limpar Tudo',
            style: ChronosTypography.bodyMedium.copyWith(
              color: ChronosColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Editorial de Publicação',
          style: ChronosTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        ChronosSpacing.vSizedBoxSM,
        Wrap(
          spacing: ChronosSpacing.sm,
          runSpacing: ChronosSpacing.xs,
          children: PublicationStatus.values.map((status) {
            final bool isSelected = _params.status == status;
            return ChoiceChip(
              label: Text(status.value.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _params = _params.copyWith(
                    status: selected ? status : null,
                    clearStatus: !selected,
                  );
                });
              },
              selectedColor: ChronosColors.accent.withOpacity(0.12),
              labelStyle: ChronosTypography.codeSmall.copyWith(
                color: isSelected ? ChronosColors.accent : ChronosColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: ChronosColors.surfaceLight,
              side: BorderSide(
                color: isSelected ? ChronosColors.accent : ChronosColors.border,
                width: 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPeriodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período Cronológico (Ano)',
          style: ChronosTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        ChronosSpacing.vSizedBoxSM,
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startYearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Início',
                  hintText: 'Ex: -4000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.arrow_right_alt_rounded),
                ),
                style: ChronosTypography.bodyMedium,
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  setState(() {
                    _params = _params.copyWith(
                      startYear: parsed,
                      clearStartYear: val.isEmpty,
                    );
                  });
                },
              ),
            ),
            ChronosSpacing.hSizedBoxMD,
            Expanded(
              child: TextField(
                controller: _endYearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Término',
                  hintText: 'Ex: 2026',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.arrow_left_rounded),
                ),
                style: ChronosTypography.bodyMedium,
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  setState(() {
                    _params = _params.copyWith(
                      endYear: parsed,
                      clearEndYear: val.isEmpty,
                    );
                  });
                },
              ),
            ),
          ],
        ),
        ChronosSpacing.vSizedBoxXS,
        Text(
          'Dica: Anos negativos indicam antes de Cristo (a.C.)',
          style: ChronosTypography.bodySmall.copyWith(
            color: ChronosColors.textMuted,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo / Classificação',
          style: ChronosTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        ChronosSpacing.vSizedBoxSM,
        Wrap(
          spacing: ChronosSpacing.sm,
          runSpacing: ChronosSpacing.xs,
          children: widget.availableTypes!.map((type) {
            final bool isSelected = _params.type == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _params = _params.copyWith(
                    type: selected ? type : null,
                    clearType: !selected,
                  );
                });
              },
              selectedColor: ChronosColors.accent.withOpacity(0.12),
              labelStyle: ChronosTypography.bodySmall.copyWith(
                color: isSelected ? ChronosColors.accent : ChronosColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: ChronosColors.surfaceLight,
              side: BorderSide(
                color: isSelected ? ChronosColors.accent : ChronosColors.border,
                width: 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoria / Domínio',
          style: ChronosTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        ChronosSpacing.vSizedBoxSM,
        Wrap(
          spacing: ChronosSpacing.sm,
          runSpacing: ChronosSpacing.xs,
          children: widget.availableCategories!.map((category) {
            final bool isSelected = _params.category == category;
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _params = _params.copyWith(
                    category: selected ? category : null,
                    clearCategory: !selected,
                  );
                });
              },
              selectedColor: ChronosColors.accent.withOpacity(0.12),
              labelStyle: ChronosTypography.bodySmall.copyWith(
                color: isSelected ? ChronosColors.accent : ChronosColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: ChronosColors.surfaceLight,
              side: BorderSide(
                color: isSelected ? ChronosColors.accent : ChronosColors.border,
                width: 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
              side: const BorderSide(color: ChronosColors.border),
            ),
            child: Text(
              'Cancelar',
              style: ChronosTypography.bodyMedium.copyWith(
                color: ChronosColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ChronosSpacing.hSizedBoxMD,
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              widget.onApply(_params);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ChronosColors.accent,
              padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.md),
            ),
            child: Text(
              'Filtrar',
              style: ChronosTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
