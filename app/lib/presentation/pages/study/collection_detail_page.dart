import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/presentation/widgets/widgets.dart';
import '../../../core/study/study_models.dart';
import '../../../presentation/controllers/collections_controller.dart';
import '../../../presentation/widgets/study/progress_bar.dart';

class CollectionDetailPage extends StatefulWidget {
  final Collection collection;

  const CollectionDetailPage({super.key, required this.collection});

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  final _controller = CollectionsController();
  List<CollectionItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _controller.collectionRepository.getItems(widget.collection.id);
    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChronosColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.collection.title, style: ChronosTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.delete_rounded), onPressed: _delete),
          IconButton(icon: const Icon(Icons.copy_rounded), onPressed: _duplicate),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ChronosSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudyProgressBar(
              percent: _items.isEmpty ? 0.0 : 1.0,
              itemCount: _items.length,
              completedCount: 0,
            ),
            ChronosSpacing.vSizedBoxMD,
            if (widget.collection.description?.isNotEmpty == true)
              Text(widget.collection.description!, style: ChronosTypography.bodyMedium),
            ChronosSpacing.vSizedBoxMD,
            const ChronosSectionTitle(title: 'Itens'),
            ChronosSpacing.vSizedBoxXS,
            if (_items.isEmpty)
              const Text('Nenhum item nesta coleção.', style: TextStyle(color: ChronosColors.textSecondary))
            else
              ..._items.map((i) => Padding(
                    padding: const EdgeInsets.only(bottom: ChronosSpacing.sm),
                    child: ChronosCard(
                      child: ListTile(
                        title: Text(i.entityType, style: ChronosTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(i.entityId, style: ChronosTypography.bodySmall.copyWith(color: ChronosColors.textSecondary)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final ok = await _controller.delete(widget.collection.id);
    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _duplicate() async {
    await _controller.duplicate(widget.collection.id);
  }
}
