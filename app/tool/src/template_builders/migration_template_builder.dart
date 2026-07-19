import '../feature_context.dart';
import 'template_builder.dart';

class MigrationTemplateBuilder implements TemplateBuilder {
  @override
  String build(FeatureContext context) {
    return '''-- Migration para a tabela de ${context.featurePascal} no ecossistema CHRONOS

CREATE TABLE IF NOT EXISTS public.${context.featureName} (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) NOT NULL UNIQUE,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT NOT NULL,
    publication_status VARCHAR(50) NOT NULL DEFAULT 'draft',
    ativo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Ativação da Segurança de Linhas (Row Level Security - RLS)
ALTER TABLE public.${context.featureName} ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS para acesso público de leitura
CREATE POLICY "Leitura pública permitida para registros ativos" ON public.${context.featureName}
    FOR SELECT USING (ativo = true AND publication_status = 'published');
''';
  }
}
