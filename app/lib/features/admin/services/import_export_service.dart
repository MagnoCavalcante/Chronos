import 'dart:convert';

import '../../../core/utils/logger.dart';
import '../domain/entities/admin_entities.dart';
import '../domain/repositories/admin_repository.dart';

/// Serviço de Importação e Exportação.
///
/// Importa: CSV, JSON, Markdown, lotes de conteúdo.
/// Exporta: JSON, Markdown, PDF, CSV.
/// Mapeamento automático de campos.
class ImportExportService {
  final AdminRepository _repository;
  static const _tag = 'ImportExportService';

  ImportExportService({required AdminRepository repository})
      : _repository = repository;

  // ============================================================
  // Importação
  // ============================================================

  /// Importa conteúdos a partir de JSON.
  Future<ImportResult> importFromJson({
    required String jsonString,
    required AdminEntityType entityType,
    required String userId,
  }) async {
    try {
      final decoded = jsonDecode(jsonString);
      final items = decoded is List ? decoded : [decoded];

      int imported = 0;
      int skipped = 0;
      final errors = <String>[];

      for (final item in items) {
        try {
          final map = item as Map<String, dynamic>;
          final name = map['name'] as String? ?? map['title'] as String? ?? 'Sem nome';
          final now = DateTime.now();
          final content = ManagedContent(
            id: '${now.millisecondsSinceEpoch}_${imported}_import',
            entityType: entityType,
            name: name,
            fields: map,
            createdBy: userId,
            createdAt: now,
            updatedAt: now,
          );
          await _repository.createContent(content);
          imported++;
        } catch (e) {
          errors.add('Item ${imported + skipped}: $e');
          skipped++;
        }
      }

      await _repository.logAudit(AuditLogEntry(
        id: '${DateTime.now().millisecondsSinceEpoch}_import',
        userId: userId,
        action: AuditActionType.importData,
        details: {
          'format': 'json',
          'entity_type': entityType.name,
          'imported': imported,
          'skipped': skipped,
        },
        createdAt: DateTime.now(),
      ));

      ChronosLogger.info(
          'Import JSON: $imported importados, $skipped pulados', tag: _tag);

      return ImportResult(
        totalRecords: items.length,
        imported: imported,
        skipped: skipped,
        errors: errors.length,
        errorMessages: errors,
      );
    } catch (e) {
      return ImportResult(
        errors: 1,
        errorMessages: ['Erro ao parsear JSON: $e'],
      );
    }
  }

  /// Importa conteúdos a partir de CSV.
  Future<ImportResult> importFromCsv({
    required String csvString,
    required AdminEntityType entityType,
    required String userId,
  }) async {
    try {
      final lines = const LineSplitter().convert(csvString);
      if (lines.isEmpty) {
        return const ImportResult(errors: 1, errorMessages: ['CSV vazio']);
      }

      final headers = lines.first.split(',').map((h) => h.trim()).toList();
      int imported = 0;
      int skipped = 0;
      final errors = <String>[];

      for (var i = 1; i < lines.length; i++) {
        try {
          final values = lines[i].split(',').map((v) => v.trim()).toList();
          if (values.length != headers.length) {
            errors.add('Linha $i: número de colunas incompatível');
            skipped++;
            continue;
          }

          final fields = <String, dynamic>{};
          for (var j = 0; j < headers.length; j++) {
            fields[headers[j]] = values[j];
          }

          final name = fields['name'] as String? ??
              fields['title'] as String? ??
              'Linha $i';
          final now = DateTime.now();

          final content = ManagedContent(
            id: '${now.millisecondsSinceEpoch}_${i}_csv',
            entityType: entityType,
            name: name,
            fields: fields,
            createdBy: userId,
            createdAt: now,
            updatedAt: now,
          );
          await _repository.createContent(content);
          imported++;
        } catch (e) {
          errors.add('Linha $i: $e');
          skipped++;
        }
      }

      await _repository.logAudit(AuditLogEntry(
        id: '${DateTime.now().millisecondsSinceEpoch}_importCsv',
        userId: userId,
        action: AuditActionType.importData,
        details: {
          'format': 'csv',
          'entity_type': entityType.name,
          'imported': imported,
          'skipped': skipped,
        },
        createdAt: DateTime.now(),
      ));

      ChronosLogger.info(
          'Import CSV: $imported importados, $skipped pulados', tag: _tag);

      return ImportResult(
        totalRecords: lines.length - 1,
        imported: imported,
        skipped: skipped,
        errors: errors.length,
        errorMessages: errors,
      );
    } catch (e) {
      return ImportResult(
        errors: 1,
        errorMessages: ['Erro ao parsear CSV: $e'],
      );
    }
  }

  // ============================================================
  // Exportação
  // ============================================================

  /// Exporta conteúdos como JSON.
  Future<String> exportToJson(AdminEntityType entityType,
      {EditorialStatus? status}) async {
    final contents = await _repository.listContents(entityType,
        status: status, limit: 10000);
    final json = contents.map((c) => c.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  /// Exporta conteúdos como CSV.
  Future<String> exportToCsv(AdminEntityType entityType,
      {EditorialStatus? status}) async {
    final contents = await _repository.listContents(entityType,
        status: status, limit: 10000);
    if (contents.isEmpty) return '';

    // Headers dinâmicos a partir dos fields do primeiro item
    final allKeys = <String>{'id', 'name', 'status', 'entity_type'};
    for (final c in contents) {
      allKeys.addAll(c.fields.keys);
    }
    final headers = allKeys.toList();

    final buffer = StringBuffer();
    buffer.writeln(headers.join(','));

    for (final c in contents) {
      final row = headers.map((h) {
        switch (h) {
          case 'id': return c.id;
          case 'name': return c.name;
          case 'status': return c.status.name;
          case 'entity_type': return c.entityType.name;
          default: return (c.fields[h] ?? '').toString().replaceAll(',', ';');
        }
      }).toList();
      buffer.writeln(row.join(','));
    }

    return buffer.toString();
  }

  /// Exporta conteúdo como Markdown.
  Future<String> exportToMarkdown(AdminEntityType entityType,
      {EditorialStatus? status}) async {
    final contents = await _repository.listContents(entityType,
        status: status, limit: 10000);
    final buffer = StringBuffer();
    buffer.writeln('# ${entityType.label}\n');

    for (final c in contents) {
      buffer.writeln('## ${c.name}\n');
      buffer.writeln('**Status**: ${c.status.name}');
      buffer.writeln('**Versão**: ${c.currentVersion}\n');
      for (final entry in c.fields.entries) {
        buffer.writeln('**${entry.key}**: ${entry.value}');
      }
      buffer.writeln('\n---\n');
    }

    return buffer.toString();
  }

  /// Registra exportação na auditoria.
  Future<void> logExport({
    required String userId,
    required DataFormat format,
    required AdminEntityType entityType,
    int count = 0,
  }) async {
    await _repository.logAudit(AuditLogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_export',
      userId: userId,
      action: AuditActionType.exportData,
      details: {
        'format': format.name,
        'entity_type': entityType.name,
        'count': count,
      },
      createdAt: DateTime.now(),
    ));
  }
}
