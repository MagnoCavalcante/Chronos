/// Representa o estado editorial de um conteúdo no ecossistema CHRONOS.
enum PublicationStatus {
  draft('draft'),
  review('review'),
  published('published'),
  archived('archived');

  final String value;

  const PublicationStatus(this.value);

  /// Converte uma string vinda do banco de dados no enum correspondente de forma segura.
  factory PublicationStatus.fromValue(String value) {
    return PublicationStatus.values.firstWhere(
      (status) => status.value == value.toLowerCase(),
      orElse: () => PublicationStatus.draft,
    );
  }

  @override
  String toString() => value;
}
