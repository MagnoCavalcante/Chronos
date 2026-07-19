import '../feature_context.dart';
import 'template_builder.dart';

class SeedTemplateBuilder implements TemplateBuilder {
  @override
  String build(FeatureContext context) {
    return '''-- Seed de exemplo para ${context.featurePascal} no ecossistema CHRONOS

INSERT INTO public.${context.featureName} (id, slug, nome, descricao, publication_status, ativo)
VALUES 
('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'primeiro-item', 'Exemplo de ${context.singularPascal} 1', 'Descrição detalhada do primeiro exemplo gerado pelo CHRONOS Feature Generator.', 'published', true),
('f6e5d4c3-b2a1-0f9e-8d7c-6b5a4f3e2d1c', 'segundo-item', 'Exemplo de ${context.singularPascal} 2', 'Descrição detalhada do segundo exemplo gerado pelo CHRONOS Feature Generator.', 'published', true)
ON CONFLICT (slug) DO NOTHING;
''';
  }
}
