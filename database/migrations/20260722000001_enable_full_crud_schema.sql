-- Migration: Enable full CRUD schema for Sprint 6.2.0
-- Description: Adiciona colunas e tabelas necessárias para criação, edição e exclusão de todos os módulos.

BEGIN;

-- 1. Civilizações: campos de cor e imagem
ALTER TABLE civilizations
ADD COLUMN IF NOT EXISTS color VARCHAR(7),
ADD COLUMN IF NOT EXISTS cover_image_url TEXT;

-- 2. Eventos: referências opcionais a civilização e localização
ALTER TABLE historical_events
ADD COLUMN IF NOT EXISTS civilization_id UUID,
ADD COLUMN IF NOT EXISTS location_id UUID;

CREATE INDEX IF NOT EXISTS idx_historical_events_civilization_id ON historical_events(civilization_id) WHERE civilization_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_historical_events_location_id ON historical_events(location_id) WHERE location_id IS NOT NULL;

-- 3. Tabela de Artefatos
CREATE TABLE IF NOT EXISTS artifacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(255),
    description TEXT NOT NULL,
    summary TEXT,
    artifact_type VARCHAR(100) NOT NULL DEFAULT 'other',
    origin_civilization_id UUID,
    origin_location_id UUID,
    estimated_year INTEGER,
    material VARCHAR(255),
    current_location VARCHAR(255),
    cover_image_url TEXT,
    publication_status VARCHAR(50) NOT NULL DEFAULT 'published',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS set_timestamp_artifacts ON artifacts;
CREATE TRIGGER set_timestamp_artifacts
BEFORE UPDATE ON artifacts
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE artifacts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS policy_artifacts_select_public ON artifacts;
CREATE POLICY policy_artifacts_select_public
ON artifacts FOR SELECT USING (true);

DROP POLICY IF EXISTS policy_artifacts_insert_authenticated ON artifacts;
CREATE POLICY policy_artifacts_insert_authenticated
ON artifacts FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS policy_artifacts_update_authenticated ON artifacts;
CREATE POLICY policy_artifacts_update_authenticated
ON artifacts FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS policy_artifacts_delete_authenticated ON artifacts;
CREATE POLICY policy_artifacts_delete_authenticated
ON artifacts FOR DELETE TO authenticated USING (true);

-- 4. Tabela de Fontes Históricas
CREATE TABLE IF NOT EXISTS historical_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) NOT NULL UNIQUE,
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(255) NOT NULL,
    url TEXT,
    descricao TEXT NOT NULL,
    publication_status VARCHAR(50) NOT NULL DEFAULT 'published',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS set_timestamp_historical_sources ON historical_sources;
CREATE TRIGGER set_timestamp_historical_sources
BEFORE UPDATE ON historical_sources
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE historical_sources ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS policy_historical_sources_select_public ON historical_sources;
CREATE POLICY policy_historical_sources_select_public
ON historical_sources FOR SELECT USING (true);

DROP POLICY IF EXISTS policy_historical_sources_insert_authenticated ON historical_sources;
CREATE POLICY policy_historical_sources_insert_authenticated
ON historical_sources FOR INSERT TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS policy_historical_sources_update_authenticated ON historical_sources;
CREATE POLICY policy_historical_sources_update_authenticated
ON historical_sources FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS policy_historical_sources_delete_authenticated ON historical_sources;
CREATE POLICY policy_historical_sources_delete_authenticated
ON historical_sources FOR DELETE TO authenticated USING (true);

COMMIT;
