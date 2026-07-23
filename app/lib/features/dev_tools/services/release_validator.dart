/// Resultado de uma verificação de release.
class ReleaseCheck {
  final String name;
  final bool passed;
  final String? detail;

  const ReleaseCheck({
    required this.name,
    required this.passed,
    this.detail,
  });
}

/// Relatório completo de validação de release.
class ReleaseReport {
  final String version;
  final DateTime timestamp;
  final List<ReleaseCheck> checks;

  const ReleaseReport({
    required this.version,
    required this.timestamp,
    required this.checks,
  });

  bool get isApproved => checks.every((c) => c.passed);
  int get passedCount => checks.where((c) => c.passed).length;
  int get failedCount => checks.where((c) => !c.passed).length;
  int get totalCount => checks.length;
  double get score => totalCount > 0 ? (passedCount / totalCount) * 100 : 0;
}

/// Validador de Release do CHRONOS.
///
/// O build somente é considerado aprovado se:
/// - flutter analyze sem erros
/// - flutter test aprovado
/// - Sem warnings críticos
/// - Sem telas órfãs
/// - Sem rotas quebradas
/// - Sem placeholders
/// - Sem assets ausentes
/// - Build Android funcionando
/// - Build iOS preparado
class ReleaseValidator {
  static const String _version = '1.0.0';

  /// Executa validação completa do release (informacional, não executa CLI).
  ReleaseReport validate({
    required bool analyzeClean,
    required bool testsPass,
    required bool noCriticalWarnings,
    required bool noOrphanScreens,
    required bool noBrokenRoutes,
    required bool noPlaceholders,
    required bool noMissingAssets,
    required bool androidBuildOk,
    required bool iosPrepared,
  }) {
    final checks = <ReleaseCheck>[
      ReleaseCheck(
        name: 'flutter analyze sem erros',
        passed: analyzeClean,
      ),
      ReleaseCheck(
        name: 'flutter test aprovado',
        passed: testsPass,
      ),
      ReleaseCheck(
        name: 'Sem warnings críticos',
        passed: noCriticalWarnings,
      ),
      ReleaseCheck(
        name: 'Sem telas órfãs',
        passed: noOrphanScreens,
      ),
      ReleaseCheck(
        name: 'Sem rotas quebradas',
        passed: noBrokenRoutes,
      ),
      ReleaseCheck(
        name: 'Sem placeholders',
        passed: noPlaceholders,
      ),
      ReleaseCheck(
        name: 'Sem assets ausentes',
        passed: noMissingAssets,
      ),
      ReleaseCheck(
        name: 'Build Android funcionando',
        passed: androidBuildOk,
      ),
      ReleaseCheck(
        name: 'Build iOS preparado',
        passed: iosPrepared,
      ),
    ];

    return ReleaseReport(
      version: _version,
      timestamp: DateTime.now(),
      checks: checks,
    );
  }

  /// Gera relatório em Markdown.
  String generateMarkdown(ReleaseReport report) {
    final buffer = StringBuffer();
    buffer.writeln('# Release Validation Report');
    buffer.writeln('');
    buffer.writeln('**Versão:** ${report.version}');
    buffer.writeln('**Data:** ${report.timestamp.toIso8601String().split('T').first}');
    buffer.writeln('**Score:** ${report.score.toStringAsFixed(1)}%');
    buffer.writeln('**Status:** ${report.isApproved ? '✅ APROVADO' : '❌ REPROVADO'}');
    buffer.writeln('');
    buffer.writeln('## Checklist');
    buffer.writeln('');
    for (final check in report.checks) {
      final icon = check.passed ? '✅' : '❌';
      buffer.writeln('- $icon ${check.name}');
      if (check.detail != null) {
        buffer.writeln('  - ${check.detail}');
      }
    }
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln('Resultado: ${report.passedCount}/${report.totalCount} verificações aprovadas.');
    return buffer.toString();
  }
}
