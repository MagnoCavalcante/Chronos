import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_icons.dart';
import '../../theme/chronos_radius.dart';
import '../../theme/chronos_typography.dart';

/// Barra de Pesquisa padronizada do CHRONOS.
///
/// Oferece campo de texto pré-configurado com ícone de busca e opção de limpeza.
class ChronosSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final String? initialValue;
  final TextEditingController? controller;

  const ChronosSearchBar({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Pesquisar...',
    this.initialValue,
    this.controller,
  });

  @override
  State<ChronosSearchBar> createState() => _ChronosSearchBarState();
}

class _ChronosSearchBarState extends State<ChronosSearchBar> {
  late final TextEditingController _controller;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _showClearButton = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final showClear = _controller.text.isNotEmpty;
    if (showClear != _showClearButton) {
      setState(() {
        _showClearButton = showClear;
      });
    }
  }

  void _handleClear() {
    _controller.clear();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ChronosColors.surface,
        borderRadius: ChronosRadius.borderRadiusMD,
        border: Border.all(color: ChronosColors.border, width: 1.0),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textPrimary),
        decoration: InputDecoration(
          filled: false,
          hintText: widget.hintText,
          prefixIcon: const Icon(
            ChronosIcons.search,
            color: ChronosColors.textMuted,
            size: 20,
          ),
          suffixIcon: _showClearButton
              ? IconButton(
                  icon: const Icon(
                    ChronosIcons.close,
                    color: ChronosColors.textMuted,
                    size: 18,
                  ),
                  onPressed: _handleClear,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      ),
    );
  }
}
