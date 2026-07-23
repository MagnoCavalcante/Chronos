import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../presentation/controllers/collections_controller.dart';
import '../../../presentation/widgets/study/collection_card.dart';
import 'collection_detail_page.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final _controller = CollectionsController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChronosColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Coleções', style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: ChronosColors.accent,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.status == CollectionsStatus.loading) {
            return const Center(child: ChronosLoading());
          }
          if (_controller.status == CollectionsStatus.error) {
            return ChronosEmptyState(title: 'Erro', description: _controller.error ?? '');
          }
          final items = _controller.collections;
          return items.isEmpty
              ? const ChronosEmptyState(
                  icon: Icons.collections_bookmark_outlined,
                  title: 'Nenhuma coleção',
                  description: 'Crie sua primeira coleção de estudos para começar.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(ChronosSpacing.lg),
                  itemCount: items.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: ChronosSpacing.sm),
                    child: CollectionCard(
                      collection: items[index],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CollectionDetailPage(collection: items[index]),
                        ),
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  void _showCreateDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ChronosColors.surface,
        title: Text('Nova coleção', style: ChronosTypography.titleSmall),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Título'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                Navigator.of(context).pop();
                _controller.create(title);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}
