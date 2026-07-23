import '../../domain/entities/export_entities.dart';

/// Serviço responsável por gerar a assinatura digital incluída em toda exportação.
///
/// Toda exportação contém automaticamente:
/// - Nome do aplicativo
/// - Versão
/// - Data da exportação
/// - QR Code (dados para geração)
/// - Rodapé com direitos autorais
/// - Link do Chronos
class SignatureService {
  static const String _appName = 'CHRONOS';
  static const String _version = '1.0.0';
  static const String _copyright = '© CHRONOS - Todos os direitos reservados';
  static const String _url = 'https://chronos.app';

  /// Gera a assinatura digital para o momento atual.
  ExportSignature generate() {
    return ExportSignature(
      appName: _appName,
      version: _version,
      exportDate: DateTime.now(),
      qrCodeData: _buildQrData(),
      copyright: _copyright,
      chronosUrl: _url,
    );
  }

  /// Gera dados para QR Code contendo informações da exportação.
  String _buildQrData() {
    final now = DateTime.now();
    return 'chronos://export?app=$_appName&v=$_version&date=${now.toIso8601String().split('T').first}';
  }
}
