enum CrudFieldType { text, multiline, number, integer, year, url, color, dropdown, date, relation }

/// Configuração de campo para os formulários CRUD genéricos do CHRONOS.
class CrudField {
  final String name;
  final String label;
  final CrudFieldType type;
  final bool required;
  final List<CrudOption> options;
  final String? hint;
  final String? validationMessage;

  const CrudField({
    required this.name,
    required this.label,
    this.type = CrudFieldType.text,
    this.required = true,
    this.options = const [],
    this.hint,
    this.validationMessage,
  });
}

class CrudOption {
  final String value;
  final String label;

  const CrudOption(this.value, this.label);
}
