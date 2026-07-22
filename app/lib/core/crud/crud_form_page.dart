import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';
import '../presentation/widgets/widgets.dart';
import 'crud_controller.dart';
import 'crud_field.dart';

/// Página de formulário genérica para criação/edição de registros CRUD.
class CrudFormPage extends StatefulWidget {
  final String title;
  final CrudController controller;
  final Map<String, dynamic>? initialData;

  const CrudFormPage({
    super.key,
    required this.title,
    required this.controller,
    this.initialData,
  });

  @override
  State<CrudFormPage> createState() => _CrudFormPageState();
}

class _CrudFormPageState extends State<CrudFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.initialData ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return ChronosScaffold(
      title: widget.title,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(ChronosSpacing.md),
          children: [
            ...widget.controller.fields.map(_buildField),
            const SizedBox(height: ChronosSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Salvar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ChronosColors.accent,
                  foregroundColor: ChronosColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(CrudField field) {
    switch (field.type) {
      case CrudFieldType.dropdown:
        return _buildDropdown(field);
      case CrudFieldType.multiline:
        return _buildText(field, maxLines: 4);
      case CrudFieldType.number:
        return _buildText(
          field,
          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
        );
      case CrudFieldType.year:
      case CrudFieldType.integer:
        return _buildText(
          field,
          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
        );
      case CrudFieldType.date:
        return _buildDate(field);
      default:
        return _buildText(field);
    }
  }

  Widget _buildText(
    CrudField field, {
    int? maxLines,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ChronosSpacing.md),
      child: TextFormField(
        initialValue: _initialValue(field),
        maxLines: maxLines ?? 1,
        keyboardType: keyboardType,
        inputFormatters: _buildInputFormatters(field),
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.hint,
          border: const OutlineInputBorder(),
        ),
        style: const TextStyle(color: ChronosColors.textPrimary),
        validator: (value) {
          if (field.required && (value == null || value.trim().isEmpty)) {
            return field.validationMessage ?? 'Campo obrigatório';
          }
          if ((field.type == CrudFieldType.year || field.type == CrudFieldType.integer) && value != null && value.isNotEmpty) {
            if (int.tryParse(value) == null) return 'Informe um número inteiro válido';
          }
          if (field.type == CrudFieldType.number && value != null && value.isNotEmpty) {
            if (double.tryParse(value) == null) return 'Informe um número válido';
          }
          return null;
        },
        onSaved: (value) => _data[field.name] = value?.trim(),
      ),
    );
  }

  List<TextInputFormatter>? _buildInputFormatters(CrudField field) {
    if (field.type == CrudFieldType.number) {
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]'))];
    }
    if (field.type == CrudFieldType.year || field.type == CrudFieldType.integer) {
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))];
    }
    return null;
  }

  Widget _buildDropdown(CrudField field) {
    final current = _data[field.name] as String? ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: ChronosSpacing.md),
      child: DropdownButtonFormField<String>(
        value: current.isEmpty ? null : current,
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
        ),
        items: field.options.map((option) {
          return DropdownMenuItem<String>(
            value: option.value,
            child: Text(option.label),
          );
        }).toList(),
        onChanged: (value) => _data[field.name] = value,
        validator: (value) {
          if (field.required && (value == null || value.isEmpty)) {
            return field.validationMessage ?? 'Selecione uma opção';
          }
          return null;
        },
        onSaved: (value) => _data[field.name] = value,
      ),
    );
  }

  Widget _buildDate(CrudField field) {
    final initial = _data[field.name] as String?;
    final controller = TextEditingController(text: initial ?? '');
    return Padding(
      padding: const EdgeInsets.only(bottom: ChronosSpacing.md),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: field.label,
          hintText: 'AAAA-MM-DD',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_rounded),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(-5000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.text = picked.toIso8601String().split('T').first;
            _data[field.name] = controller.text;
          }
        },
        validator: (value) {
          if (field.required && (value == null || value.trim().isEmpty)) {
            return field.validationMessage ?? 'Campo obrigatório';
          }
          return null;
        },
        onSaved: (value) => _data[field.name] = value?.trim(),
      ),
    );
  }

  String? _initialValue(CrudField field) {
    final value = _data[field.name];
    if (value == null) return null;
    return value.toString();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final success = await widget.controller.save(_data);
    if (!mounted) return;

    if (success) {
      ChronosSnackBar.show(
        context,
        message: 'Registro salvo com sucesso.',
      );
      Navigator.of(context).pop(true);
    } else {
      ChronosSnackBar.show(
        context,
        message: widget.controller.error ?? 'Erro ao salvar registro.',
      );
    }
  }
}
