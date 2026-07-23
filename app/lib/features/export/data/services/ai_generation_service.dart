import '../../domain/entities/export_entities.dart';
import '../../../presentation_mode/domain/entities/presentation_entities.dart';

/// Tipo de material que a IA poderá gerar futuramente.
enum AiGeneratedMaterialType {
  slides,
  summary,
  studyGuide,
  teacherMaterial,
  questionnaire,
}

/// Request para geração de material por IA (infraestrutura futura).
class AiGenerationRequest {
  final String topic;
  final AiGeneratedMaterialType materialType;
  final List<ExportableContent> sourceContents;
  final String? targetAudience;
  final String? additionalInstructions;
  final int? maxSlides;

  const AiGenerationRequest({
    required this.topic,
    required this.materialType,
    required this.sourceContents,
    this.targetAudience,
    this.additionalInstructions,
    this.maxSlides,
  });
}

/// Resultado da geração IA (infraestrutura futura).
class AiGenerationResult {
  final bool success;
  final AiGeneratedMaterialType materialType;
  final String? generatedContent;
  final List<PresentationSlide>? slides;
  final String? errorMessage;

  const AiGenerationResult({
    required this.success,
    required this.materialType,
    this.generatedContent,
    this.slides,
    this.errorMessage,
  });
}

/// Serviço de preparação para geração automática por IA.
///
/// Nesta Sprint, apenas a arquitetura é preparada.
/// Futuramente o Chronos AI poderá gerar automaticamente:
/// - Slides
/// - Resumos
/// - Apostilas
/// - Materiais para professores
/// - Questionários
class AiGenerationService {
  /// Verifica se a geração por IA está disponível (futuro).
  bool get isAvailable => false;

  /// Prepara um request de geração a partir de conteúdos selecionados.
  AiGenerationRequest prepareRequest({
    required String topic,
    required AiGeneratedMaterialType type,
    required List<ExportableContent> contents,
    String? targetAudience,
    int? maxSlides,
  }) {
    return AiGenerationRequest(
      topic: topic,
      materialType: type,
      sourceContents: contents,
      targetAudience: targetAudience,
      maxSlides: maxSlides ?? _defaultSlideCount(type),
    );
  }

  /// Gera material (stub — retorna infraestrutura não implementada).
  Future<AiGenerationResult> generate(AiGenerationRequest request) async {
    // Infraestrutura preparada para integração futura com Chronos AI
    return AiGenerationResult(
      success: false,
      materialType: request.materialType,
      errorMessage: 'Geração por IA será disponibilizada em sprint futura',
    );
  }

  /// Valida se os conteúdos fonte são suficientes para geração.
  bool canGenerate(List<ExportableContent> contents) {
    return contents.isNotEmpty;
  }

  int _defaultSlideCount(AiGeneratedMaterialType type) {
    switch (type) {
      case AiGeneratedMaterialType.slides:
        return 15;
      case AiGeneratedMaterialType.summary:
        return 5;
      case AiGeneratedMaterialType.studyGuide:
        return 20;
      case AiGeneratedMaterialType.teacherMaterial:
        return 25;
      case AiGeneratedMaterialType.questionnaire:
        return 10;
    }
  }
}
