/// Utilitários Globais do CHRONOS
/// 
/// Contém funções auxiliares, manipuladores de strings, ferramentas de formatação 
/// de datas históricas complexas (como tratamento de anos a.C. e d.C.),
/// validações e extensões de sistema úteis para as demais camadas.
class UtilsPlaceholder {
  /// Converte um valor de ano numérico bruto para uma representação amigável e legível.
  /// Exemplo: -3400 -> "3400 a.C." ou 1500 -> "1500 d.C."
  static String formatHistoricalYear(int year) {
    if (year < 0) {
      return '${year.abs()} a.C.';
    }
    return '$year d.C.';
  }
}
