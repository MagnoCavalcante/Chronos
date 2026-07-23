/// Serviço responsável por desbloquear coleções especiais baseadas em conquistas.
///
/// Placeholder para futura implementação. As conquistas podem conter o campo
/// `special_collection_slug`; este serviço será acionado pelo `GamificationService`
/// quando uma conquista for desbloqueada e esse campo estiver presente.
class SpecialCollectionService {
  Future<void> unlock(String? collectionSlug) async {
    if (collectionSlug == null || collectionSlug.isEmpty) return;
    // Futuro: criar/relacionar coleção especial no repositório de estudos.
  }
}
