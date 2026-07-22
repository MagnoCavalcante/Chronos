import 'package:flutter/material.dart';
import '../presentation/widgets/widgets.dart';
import '../theme/theme.dart';
import 'crud_card.dart';
import 'crud_controller.dart';
import 'crud_field.dart';
import 'crud_form_page.dart';
import 'crud_module_configs.dart';

/// Tela de listagem CRUD genérica para qualquer módulo configurado.
///
/// Exibe FAB para criação, cards com menu de ações e atualiza a lista
/// automaticamente após criação, edição ou exclusão.
class CrudScreen extends StatefulWidget {
  final CrudModuleConfig config;

  // ignore: prefer_const_constructors_in_immutables
  CrudScreen({
    super.key,
    required this.config,
  });

  @override
  State<CrudScreen> createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  late final CrudController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CrudController(
      repository: widget.config.repository,
      fields: widget.config.fields,
    );
    _controller.addListener(_onControllerUpdate);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _openForm({Map<String, dynamic>? record}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CrudFormPage(
          title: record == null ? 'Novo ${widget.config.itemLabel}' : 'Editar ${widget.config.itemLabel}',
          controller: _controller,
          initialData: record,
        ),
      ),
    );
    if (result == true) {
      await _controller.load();
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tem certeza?'),
        content: const Text('Esta ação não poderá ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final id = record['id'] as String?;
      if (id == null || id.isEmpty) return;
      final success = await _controller.delete(id);
      if (!mounted) return;
      if (success) {
        ChronosSnackBar.show(
          context,
          message: 'Registro excluído com sucesso.',
        );
      } else {
        ChronosSnackBar.show(
          context,
          message: _controller.error ?? 'Erro ao excluir registro.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChronosScaffold(
      title: 'CHRONOS — ${widget.config.title}',
      actions: [
        ChronosIconButton(
          tooltip: 'Sincronizar',
          icon: ChronosIcons.sync,
          onPressed: _controller.load,
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: ChronosColors.accent,
        child: const Icon(Icons.add_rounded, color: ChronosColors.background),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.hasError && _controller.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_controller.error ?? 'Erro ao carregar dados.'),
            const SizedBox(height: ChronosSpacing.md),
            ElevatedButton(
              onPressed: _controller.load,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_controller.isEmpty) {
      return Center(
        child: Text(
          'Nenhum ${widget.config.itemLabel.toLowerCase()} cadastrado.',
          style: ChronosTypography.bodyMedium.copyWith(color: ChronosColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: ChronosColors.accent,
      backgroundColor: ChronosColors.background,
      onRefresh: _controller.load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: ChronosSpacing.sm),
        itemCount: _controller.items.length,
        itemBuilder: (context, index) {
          final record = _controller.items[index];
          return CrudCard(
            title: widget.config.titleBuilder(record),
            subtitle: widget.config.subtitleBuilder(record),
            imageUrl: record[widget.config.imageKey] as String?,
            onEdit: () => _openForm(record: record),
            onDelete: () => _confirmDelete(record),
            onShare: () => _onShare(record),
          );
        },
      ),
    );
  }

  void _onShare(Map<String, dynamic> record) {
    final title = widget.config.titleBuilder(record);
    ChronosSnackBar.show(
      context,
      message: 'Compartilhar "$title" (em breve).',
    );
  }
}
