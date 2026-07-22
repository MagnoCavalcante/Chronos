import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/timeline/timeline_repository.dart';
import '../../widgets/chronos_empty_view.dart';
import 'timeline_item.dart';

/// Página de comparação lado a lado entre dois períodos históricos.
class PeriodComparePage extends StatefulWidget {
  const PeriodComparePage({super.key});

  @override
  State<PeriodComparePage> createState() => _PeriodComparePageState();
}

class _PeriodComparePageState extends State<PeriodComparePage> {
  final TimelineRepository _repository = TimelineRepository();

  String _leftLabel = 'Antiguidade';
  String _rightLabel = 'Idade Moderna';
  (int, int) _leftRange = (-3000, 476);
  (int, int) _rightRange = (1453, 1789);

  bool _isLoading = true;
  List<TimelineDisplayItem> _leftItems = [];
  List<TimelineDisplayItem> _rightItems = [];

  final Map<String, (int, int)> _periods = {
    'Pré-História': (-5000, -3000),
    'Antiguidade': (-3000, 476),
    'Idade Média': (476, 1453),
    'Idade Moderna': (1453, 1789),
    'Idade Contemporânea': (1789, 2100),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final left = await _repository.getTimeline(
      startYear: _leftRange.$1,
      endYear: _leftRange.$2,
      pageSize: 100,
    );
    final right = await _repository.getTimeline(
      startYear: _rightRange.$1,
      endYear: _rightRange.$2,
      pageSize: 100,
    );
    setState(() {
      _leftItems = left;
      _rightItems = right;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChronosScaffold(
      title: 'Comparar Períodos',
      body: Padding(
        padding: const EdgeInsets.all(ChronosSpacing.lg),
        child: Column(
          children: [
            // Seletores de período
            Row(
              children: [
                Expanded(
                  child: _buildPeriodDropdown(
                    value: _leftLabel,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _leftLabel = val;
                          _leftRange = _periods[val]!;
                        });
                        _load();
                      }
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: ChronosSpacing.md),
                  child: Icon(Icons.compare_arrows_rounded),
                ),
                Expanded(
                  child: _buildPeriodDropdown(
                    value: _rightLabel,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _rightLabel = val;
                          _rightRange = _periods[val]!;
                        });
                        _load();
                      }
                    },
                  ),
                ),
              ],
            ),
            ChronosSpacing.vSizedBoxMD,
            // Colunas comparativas
            Expanded(
              child: _isLoading
                  ? const Center(child: ChronosSkeleton(width: 200, height: 200))
                  : Row(
                      children: [
                        Expanded(
                          child: _buildColumn(_leftLabel, _leftItems),
                        ),
                        const SizedBox(width: ChronosSpacing.md),
                        Expanded(
                          child: _buildColumn(_rightLabel, _rightItems),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Período',
        border: OutlineInputBorder(),
      ),
      items: _periods.keys.map((label) {
        return DropdownMenuItem(value: label, child: Text(label));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildColumn(String label, List<TimelineDisplayItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            label,
            style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ChronosSpacing.vSizedBoxSM,
        Expanded(
          child: items.isEmpty
              ? const ChronosEmptyView(
                  icon: Icons.hourglass_empty_rounded,
                  title: 'Vazio',
                  description: 'Nenhum registro encontrado neste período.',
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => ChronosSpacing.vSizedBoxSM,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final color = item.type.color;
                    return ChronosCard(
                      padding: const EdgeInsets.all(ChronosSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(item.type.icon, size: 16, color: color),
                              ChronosSpacing.hSizedBoxXS,
                              Text(
                                item.type.label,
                                style: ChronosTypography.labelSmall.copyWith(color: color),
                              ),
                            ],
                          ),
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ChronosTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item.periodLabel,
                            style: ChronosTypography.labelSmall.copyWith(color: ChronosColors.textMuted),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
