/// Tipo de item de novidades.
enum WhatsNewItemType {
  feature,
  improvement,
  fix,
}

/// Item individual de novidades.
class WhatsNewItem {
  final String title;
  final String description;
  final WhatsNewItemType type;

  const WhatsNewItem({
    required this.title,
    required this.description,
    required this.type,
  });
}

/// Release notes de uma versão.
class ReleaseNotes {
  final String version;
  final DateTime releaseDate;
  final List<WhatsNewItem> items;

  const ReleaseNotes({
    required this.version,
    required this.releaseDate,
    required this.items,
  });
}
