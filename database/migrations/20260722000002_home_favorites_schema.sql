-- Migration: Home intelligent, favorites and navigation history schema
-- Description: Cria tabelas de favoritos, histórico de navegação, popularidade e destaques.

BEGIN;

-- 1. Favoritos dos usuários com snapshot denormalizado para exibição rápida
CREATE TABLE IF NOT EXISTS user_favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    title TEXT NOT NULL,
    image_url TEXT,
    category VARCHAR(100),
    chronology TEXT,
    user_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(entity_type, entity_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_created_at ON user_favorites(created_at);

-- 2. Histórico de navegação com snapshot denormalizado
CREATE TABLE IF NOT EXISTS navigation_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    title TEXT NOT NULL,
    image_url TEXT,
    category VARCHAR(100),
    chronology TEXT,
    user_id UUID,
    accessed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_navigation_history_user_id ON navigation_history(user_id);
CREATE INDEX IF NOT EXISTS idx_navigation_history_accessed_at ON navigation_history(accessed_at DESC);

-- 3. Popularidade das entidades (visualizações e favoritamentos)
CREATE TABLE IF NOT EXISTS entity_popularity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    view_count INTEGER NOT NULL DEFAULT 0,
    favorite_count INTEGER NOT NULL DEFAULT 0,
    UNIQUE(entity_type, entity_id)
);

CREATE INDEX IF NOT EXISTS idx_entity_popularity_views ON entity_popularity(view_count DESC);
CREATE INDEX IF NOT EXISTS idx_entity_popularity_favorites ON entity_popularity(favorite_count DESC);

-- 4. Destaques editoriais curados
CREATE TABLE IF NOT EXISTS entity_highlights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    weight INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(entity_type, entity_id)
);

CREATE INDEX IF NOT EXISTS idx_entity_highlights_weight ON entity_highlights(weight DESC, created_at DESC);

-- Triggers de atualização automática do updated_at para tabelas que possuem a coluna
DROP TRIGGER IF EXISTS set_timestamp_user_favorites ON user_favorites;
CREATE TRIGGER set_timestamp_user_favorites
BEFORE UPDATE ON user_favorites
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS set_timestamp_navigation_history ON navigation_history;
CREATE TRIGGER set_timestamp_navigation_history
BEFORE UPDATE ON navigation_history
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS set_timestamp_entity_popularity ON entity_popularity;
CREATE TRIGGER set_timestamp_entity_popularity
BEFORE UPDATE ON entity_popularity
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS set_timestamp_entity_highlights ON entity_highlights;
CREATE TRIGGER set_timestamp_entity_highlights
BEFORE UPDATE ON entity_highlights
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE navigation_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE entity_popularity ENABLE ROW LEVEL SECURITY;
ALTER TABLE entity_highlights ENABLE ROW LEVEL SECURITY;

-- Políticas públicas de leitura
DROP POLICY IF EXISTS policy_user_favorites_select_public ON user_favorites;
CREATE POLICY policy_user_favorites_select_public ON user_favorites FOR SELECT USING (true);

DROP POLICY IF EXISTS policy_navigation_history_select_public ON navigation_history;
CREATE POLICY policy_navigation_history_select_public ON navigation_history FOR SELECT USING (true);

DROP POLICY IF EXISTS policy_entity_popularity_select_public ON entity_popularity;
CREATE POLICY policy_entity_popularity_select_public ON entity_popularity FOR SELECT USING (true);

DROP POLICY IF EXISTS policy_entity_highlights_select_public ON entity_highlights;
CREATE POLICY policy_entity_highlights_select_public ON entity_highlights FOR SELECT USING (true);

-- Políticas de escrita para usuários anônimos e autenticados
DROP POLICY IF EXISTS policy_user_favorites_write_public ON user_favorites;
CREATE POLICY policy_user_favorites_write_public ON user_favorites FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS policy_navigation_history_write_public ON navigation_history;
CREATE POLICY policy_navigation_history_write_public ON navigation_history FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS policy_entity_popularity_write_public ON entity_popularity;
CREATE POLICY policy_entity_popularity_write_public ON entity_popularity FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS policy_entity_highlights_write_public ON entity_highlights;
CREATE POLICY policy_entity_highlights_write_public ON entity_highlights FOR ALL TO public USING (true) WITH CHECK (true);

-- 5. Função RPC para incrementar popularidade de forma atômica
CREATE OR REPLACE FUNCTION upsert_popularity(
    p_entity_type VARCHAR,
    p_entity_id UUID,
    p_views INTEGER DEFAULT 0,
    p_favorites INTEGER DEFAULT 0
) RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO entity_popularity (entity_type, entity_id, view_count, favorite_count)
    VALUES (p_entity_type, p_entity_id, GREATEST(p_views, 0), GREATEST(p_favorites, 0))
    ON CONFLICT (entity_type, entity_id)
    DO UPDATE SET
        view_count = GREATEST(entity_popularity.view_count + p_views, 0),
        favorite_count = GREATEST(entity_popularity.favorite_count + p_favorites, 0);
END;
$$;

COMMIT;
