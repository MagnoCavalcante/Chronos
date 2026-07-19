import 'package:flutter/material.dart';
import '../../theme/chronos_colors.dart';
import '../../theme/chronos_typography.dart';
import '../../theme/chronos_radius.dart';

/// Campo de Seleção Suspensa (Dropdown) padronizado do CHRONOS.
///
/// Encapsula o visual do formulário para oferecer seleções estruturadas.
class ChronosDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final FormFieldValidator<T>? validator;

  const ChronosDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.errorText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: ChronosColors.textSecondary,
      ),
      dropdownColor: ChronosColors.surface,
      borderRadius: ChronosRadius.borderRadiusMD,
      style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textPrimary),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
      ),
    );
  }
}
