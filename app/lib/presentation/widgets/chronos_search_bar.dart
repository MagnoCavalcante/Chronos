import 'package:flutter/material.dart';
import '../../core/theme/chronos_colors.dart';
import '../../core/theme/chronos_icons.dart';
import '../../core/theme/chronos_typography.dart';

/// Campo de busca reativo e reutilizável do ecossistema CHRONOS.
///
/// Prontamente preparado para consultas de dados locais ou remotas,
/// permitindo acoplar debounce ou gerenciamento personalizado de estados.
class ChronosSearchBar extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const ChronosSearchBar({
    super.key,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.controller,
    this.focusNode,
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
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _showClearButton = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    // Apenas descarta o controller se ele foi criado internamente
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_showClearButton != hasText) {
      setState(() {
        _showClearButton = hasText;
      });
    }
  }

  void _handleClear() {
    _controller.clear();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
    if (widget.onClear != null) {
      widget.onClear!();
    }
    setState(() {
      _showClearButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: 'Campo de Pesquisa',
      hint: widget.hintText ?? 'Buscar no tempo...',
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          style: ChronosTypography.bodyMedium.copyWith(
            color: ChronosColors.textPrimary,
          ),
          cursorColor: ChronosColors.accent,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Buscar no tempo...',
            prefixIcon: const Icon(
              ChronosIcons.search,
              color: ChronosColors.textMuted,
              size: 20,
            ),
            suffixIcon: _showClearButton
                ? Semantics(
                    button: true,
                    label: 'Limpar texto',
                    child: IconButton(
                      icon: const Icon(
                        ChronosIcons.close,
                        color: ChronosColors.textSecondary,
                        size: 18,
                      ),
                      onPressed: _handleClear,
                      tooltip: 'Limpar busca',
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
