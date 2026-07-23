import '../../domain/entities/export_entities.dart';

/// Serviço responsável por gerar layout específico para impressão.
///
/// Compatível com A4, Carta, Paisagem e Retrato.
/// Modo economia evita desperdício de tinta.
class PrintLayoutService {
  /// Dimensões em mm para cada tamanho de página.
  static const Map<PageSize, _PageDimensions> _dimensions = {
    PageSize.a4: _PageDimensions(width: 210, height: 297),
    PageSize.letter: _PageDimensions(width: 216, height: 279),
  };

  /// Retorna as dimensões efetivas com base no layout.
  PageDimensionsResult getEffectiveDimensions(PrintLayout layout) {
    final base = _dimensions[layout.pageSize]!;
    final isLandscape = layout.orientation == PageOrientation.landscape;

    return PageDimensionsResult(
      widthMm: isLandscape ? base.height : base.width,
      heightMm: isLandscape ? base.width : base.height,
      marginMm: layout.marginMm,
      contentWidthMm: (isLandscape ? base.height : base.width) - (layout.marginMm * 2),
      contentHeightMm: (isLandscape ? base.width : base.height) - (layout.marginMm * 2),
    );
  }

  /// Gera CSS @media print com base no layout.
  String generatePrintCss(PrintLayout layout) {
    final dims = getEffectiveDimensions(layout);
    final sizeStr = layout.pageSize == PageSize.a4 ? 'A4' : 'letter';
    final orient = layout.orientation == PageOrientation.landscape ? 'landscape' : 'portrait';

    final buffer = StringBuffer();
    buffer.writeln('@media print {');
    buffer.writeln('  @page { size: $sizeStr $orient; margin: ${layout.marginMm}mm; }');
    buffer.writeln('  body { max-width: ${dims.contentWidthMm}mm; }');

    if (layout.economyMode) {
      buffer.writeln('  * { color: #000 !important; background: #fff !important; }');
      buffer.writeln('  img { opacity: 0.8; filter: grayscale(30%); }');
      buffer.writeln('  .no-print { display: none !important; }');
    }

    buffer.writeln('}');
    return buffer.toString();
  }
}

class _PageDimensions {
  final double width;
  final double height;

  const _PageDimensions({required this.width, required this.height});
}

/// Resultado de cálculo de dimensões de página.
class PageDimensionsResult {
  final double widthMm;
  final double heightMm;
  final double marginMm;
  final double contentWidthMm;
  final double contentHeightMm;

  const PageDimensionsResult({
    required this.widthMm,
    required this.heightMm,
    required this.marginMm,
    required this.contentWidthMm,
    required this.contentHeightMm,
  });
}
