-- Migration: Create civilizations table
-- Description: Tabela base para gerenciar as Civilizations do ecossistema CHRONOS.
-- Sprint: 4.4.2
-- Date: 19/07/2026
-- Author: Equipe de Engenharia CHRONOS

-- 1. Criação da tabela oficial 'civilizations' de forma resiliente e idempotente
CREATE TABLE IF NOT EXISTS civilizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(100),
    description TEXT NOT NULL,
    summary TEXT NOT NULL,
    start_year INTEGER,
    end_year INTEGER,
    publication_status VARCHAR(50) NOT NULL DEFAULT 'draft',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints de integridade e validações estruturais
    CONSTRAINT uq_civilizations_slug UNIQUE (slug),
    CONSTRAINT chk_civilizations_publication_status CHECK (publication_status IN ('draft', 'review', 'published', 'archived')),
    CONSTRAINT chk_civilizations_years CHECK (
        (start_year IS NULL AND end_year IS NULL) OR
        (start_year IS NOT NULL AND end_year IS NOT NULL AND end_year >= start_year) OR
        (start_year IS NOT NULL AND end_year IS NULL)
    ),
    CONSTRAINT chk_civilizations_name_no_whitespace CHECK (length(trim(name)) > 0),
    CONSTRAINT chk_civilizations_slug_no_whitespace CHECK (length(trim(slug)) > 0),
    CONSTRAINT chk_civilizations_description_no_whitespace CHECK (length(trim(description)) > 0),
    CONSTRAINT chk_civilizations_summary_no_whitespace CHECK (length(trim(summary)) > 0)
);

-- 2. Criação de índices otimizados para busca e filtragem
CREATE INDEX IF NOT EXISTS idx_civilizations_slug ON civilizations(slug);
CREATE INDEX IF NOT EXISTS idx_civilizations_publication_status ON civilizations(publication_status);
CREATE INDEX IF NOT EXISTS idx_civilizations_active ON civilizations(active);
CREATE INDEX IF NOT EXISTS idx_civilizations_start_year ON civilizations(start_year) WHERE start_year IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_civilizations_end_year ON civilizations(end_year) WHERE end_year IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_civilizations_name ON civilizations(name);

-- 3. Trigger para atualização automática da coluna updated_at antes de qualquer update
DROP TRIGGER IF EXISTS set_timestamp_civilizations ON civilizations;
CREATE TRIGGER set_timestamp_civilizations
BEFORE UPDATE ON civilizations
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- 4. Ativação do Row Level Security (RLS)
ALTER TABLE civilizations ENABLE ROW LEVEL SECURITY;

-- 5. Políticas de acesso seguro (RLS)
DROP POLICY IF EXISTS policy_civilizations_select_public ON civilizations;
CREATE POLICY policy_civilizations_select_public
ON civilizations
FOR SELECT
USING (true);

DROP POLICY IF EXISTS policy_civilizations_insert_authenticated ON civilizations;
CREATE POLICY policy_civilizations_insert_authenticated
ON civilizations
FOR INSERT
TO authenticated
WITH CHECK (true);

DROP POLICY IF EXISTS policy_civilizations_update_authenticated ON civilizations;
CREATE POLICY policy_civilizations_update_authenticated
ON civilizations
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS policy_civilizations_delete_authenticated ON civilizations;
CREATE POLICY policy_civilizations_delete_authenticated
ON civilizations
FOR DELETE
TO authenticated
USING (true);

-- 6. Comentários SQL para documentação estrutural
COMMENT ON TABLE civilizations IS 'Tabela que define as Civilizations do ecossistema CHRONOS, servindo como base de identidade histórica e editorial.';
COMMENT ON COLUMN civilizations.id IS 'Identificador único universal (UUID) gerado pelo PostgreSQL.';
COMMENT ON COLUMN civilizations.slug IS 'Slug único usado para identificações amigáveis e URLs semânticas.';
COMMENT ON COLUMN civilizations.name IS 'Nome principal da civilização.';
COMMENT ON COLUMN civilizations.short_name IS 'Nome curto ou sigla editorial da civilização.';
COMMENT ON COLUMN civilizations.description IS 'Descrição detalhada da civilização.';
COMMENT ON COLUMN civilizations.summary IS 'Resumo conciso para listagens e cartões.';
COMMENT ON COLUMN civilizations.start_year IS 'Ano inicial do período da civilização.';
COMMENT ON COLUMN civilizations.end_year IS 'Ano final do período da civilização.';
COMMENT ON COLUMN civilizations.publication_status IS 'Estado editorial da civilização.';
COMMENT ON COLUMN civilizations.active IS 'Indicador de visibilidade ativa na interface.';
COMMENT ON COLUMN civilizations.created_at IS 'Data e hora de criação do registro.';
COMMENT ON COLUMN civilizations.updated_at IS 'Data e hora da última atualização do registro.';
