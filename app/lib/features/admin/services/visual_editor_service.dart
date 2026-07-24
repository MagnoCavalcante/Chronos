import '../domain/entities/admin_entities.dart';

/// Serviço do Editor Visual (WYSIWYG).
///
/// Suporta: títulos, imagens, vídeos, tabelas, citações,
/// blocos de observação, caixas "Fato"/"Teoria"/"Em Debate",
/// notas de rodapé, referências automáticas.
///
/// Converte entre EditorBlocks e formatos de saída (Markdown, HTML).
class VisualEditorService {
  /// Cria bloco de título.
  EditorBlock createHeading(String text, {int level = 2, int order = 0}) =>
      EditorBlock(
        id: '${DateTime.now().millisecondsSinceEpoch}_h$level',
        type: EditorBlockType.heading,
        data: {'text': text, 'level': level},
        order: order,
      );

  /// Cria bloco de parágrafo.
  EditorBlock createParagraph(String text, {int order = 0}) => EditorBlock(
        id: '${DateTime.now().millisecondsSinceEpoch}_p',
        type: EditorBlockType.paragraph,
        data: {'text': text},
        order: order,
      );

  /// Cria bloco de imagem.
  EditorBlock createImage(String url,
          {String? caption, String? alt, int order = 0}) =>
      EditorBlock(
        id: '${DateTime.now().millisecondsSinceEpoch}_img',
        type: EditorBlockType.image,
        data: {'url': url, 'caption': caption ?? '', 'alt': alt ?? ''},
        order: order,
      );

  /// Cria bloco de vídeo.
  EditorBlock createVideo(String url, {String? caption, int order = 0}) =>
      EditorBlock(
        id: '${DateTime.now().millisecondsSinceEpoch}_vid',
        type: EditorBlockType.video,
        data: {'url': url, 'caption': caption ?? ''},
        order: order,
      );

  /// Cria bloco de tabela.
  EditorBlock createTable(List<List<String>> rows, {int order = 0}) =>
      EditorBlock(
        id: '${DateTime.now().millisecondsSinceEpoch}_tbl',
        type: EditorBlockType.table,
        data: {'rows': rows},
        order: order,
      );

  /// Cria bloco de citação.
  EditorBlock createQuote(String text,
          {String? author, int order = 0}) =>
      EditorBlock(
        id: '${DateTime.now().millisecondsSinceEpoch}_quote',
        type: EditorBlockType.quote,
        data: {'text': text, 'author': author ?? ''},
        order: order,
      );

  /// Cria bloco de observação.
  EditorBlock createObservation(String text, {int order = 0}) => EditorBlock(
        id: '${DateTime.now().millisecondsSinceEpoch}_obs',
        type: EditorBlockType.observation,
        data: {'text': text},
        order: order,
      );

  /// Cria bloco "Fato".
  EditorBlock createFact(String text, {int order = 0}) => EditorBlock(
        id: '${DateTime.now().millisecondsSinceEpoch}_fact',
        type: EditorBlockType.fact,
        data: {'text': text},
        order: order,
      );

  /// Cria bloco "Teoria".
  EditorBlock createTheory(String text, {int order = 0}) => EditorBlock(
        id: '${DateTime.now().millisecondsSinceEpoch}_theory',
        type: EditorBlockType.theory,
        data: {'text': text},
        order: order,
      );

  /// Cria bloco "Em Debate".
  EditorBlock createDebate(String text, {int order = 0}) => EditorBlock(
        id: '${DateTime.now().millisecondsSinceEpoch}_debate',
        type: EditorBlockType.debate,
        data: {'text': text},
        order: order,
      );

  /// Cria nota de rodapé.
  EditorBlock createFootnote(String text, {int number = 1, int order = 0}) =>
      EditorBlock(
        id: '${DateTime.now().millisecondsSinceEpoch}_fn$number',
        type: EditorBlockType.footnote,
        data: {'text': text, 'number': number},
        order: order,
      );

  /// Cria referência automática.
  EditorBlock createReference(String source,
          {String? doi, String? isbn, String? url, int order = 0}) =>
      EditorBlock(
        id: '${DateTime.now().millisecondsSinceEpoch}_ref',
        type: EditorBlockType.reference,
        data: {
          'source': source,
          'doi': doi ?? '',
          'isbn': isbn ?? '',
          'url': url ?? '',
        },
        order: order,
      );

  /// Converte blocos para Markdown.
  String toMarkdown(List<EditorBlock> blocks) {
    final sorted = List<EditorBlock>.from(blocks)
      ..sort((a, b) => a.order.compareTo(b.order));

    final buffer = StringBuffer();
    for (final block in sorted) {
      switch (block.type) {
        case EditorBlockType.heading:
          final level = block.data['level'] as int? ?? 2;
          buffer.writeln('${'#' * level} ${block.data['text'] ?? ''}');
          buffer.writeln();
          break;
        case EditorBlockType.paragraph:
          buffer.writeln(block.data['text'] ?? '');
          buffer.writeln();
          break;
        case EditorBlockType.image:
          buffer.writeln('![${block.data['alt'] ?? ''}](${block.data['url'] ?? ''})');
          if ((block.data['caption'] as String?)?.isNotEmpty == true) {
            buffer.writeln('_${block.data['caption']}_');
          }
          buffer.writeln();
          break;
        case EditorBlockType.video:
          buffer.writeln('[Vídeo](${block.data['url'] ?? ''})');
          buffer.writeln();
          break;
        case EditorBlockType.table:
          final rows = block.data['rows'] as List? ?? [];
          for (var i = 0; i < rows.length; i++) {
            final row = List<String>.from(rows[i] as List);
            buffer.writeln('| ${row.join(' | ')} |');
            if (i == 0) {
              buffer.writeln('| ${row.map((_) => '---').join(' | ')} |');
            }
          }
          buffer.writeln();
          break;
        case EditorBlockType.quote:
          buffer.writeln('> ${block.data['text'] ?? ''}');
          if ((block.data['author'] as String?)?.isNotEmpty == true) {
            buffer.writeln('> — _${block.data['author']}_');
          }
          buffer.writeln();
          break;
        case EditorBlockType.observation:
          buffer.writeln('> **Observação**: ${block.data['text'] ?? ''}');
          buffer.writeln();
          break;
        case EditorBlockType.fact:
          buffer.writeln('> 🟢 **Fato**: ${block.data['text'] ?? ''}');
          buffer.writeln();
          break;
        case EditorBlockType.theory:
          buffer.writeln('> 🟡 **Teoria**: ${block.data['text'] ?? ''}');
          buffer.writeln();
          break;
        case EditorBlockType.debate:
          buffer.writeln('> 🔴 **Em Debate**: ${block.data['text'] ?? ''}');
          buffer.writeln();
          break;
        case EditorBlockType.footnote:
          buffer.writeln('[^${block.data['number']}]: ${block.data['text'] ?? ''}');
          break;
        case EditorBlockType.reference:
          buffer.write('- ${block.data['source'] ?? ''}');
          if ((block.data['doi'] as String?)?.isNotEmpty == true) {
            buffer.write(' DOI: ${block.data['doi']}');
          }
          if ((block.data['isbn'] as String?)?.isNotEmpty == true) {
            buffer.write(' ISBN: ${block.data['isbn']}');
          }
          buffer.writeln();
          break;
      }
    }
    return buffer.toString();
  }

  /// Reordena blocos.
  List<EditorBlock> reorder(List<EditorBlock> blocks, int oldIndex, int newIndex) {
    final list = List<EditorBlock>.from(blocks);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    return List.generate(
      list.length,
      (i) => EditorBlock(
        id: list[i].id,
        type: list[i].type,
        data: list[i].data,
        order: i,
      ),
    );
  }
}
