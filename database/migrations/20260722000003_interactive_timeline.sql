-- Migration: Interactive Historical Timeline schema
-- Description: Otimiza tabelas para timeline, cria funções RPC e índices de performance.

BEGIN;

-- 1. Garante coluna de ano para timeline em todas as entidades principais
ALTER TABLE civilizations ADD COLUMN IF NOT EXISTS start_year INTEGER;
ALTER TABLE civilizations ADD COLUMN IF NOT EXISTS end_year INTEGER;

ALTER TABLE historical_characters ADD COLUMN IF NOT EXISTS start_year INTEGER;
ALTER TABLE historical_characters ADD COLUMN IF NOT EXISTS end_year INTEGER;

ALTER TABLE historical_events ADD COLUMN IF NOT EXISTS start_year INTEGER;
ALTER TABLE historical_events ADD COLUMN IF NOT EXISTS end_year INTEGER;

ALTER TABLE artifacts ADD COLUMN IF NOT EXISTS start_year INTEGER;
ALTER TABLE artifacts ADD COLUMN IF NOT EXISTS estimated_year INTEGER;

ALTER TABLE historical_locations ADD COLUMN IF NOT EXISTS start_year INTEGER;
ALTER TABLE historical_locations ADD COLUMN IF NOT EXISTS end_year INTEGER;

ALTER TABLE historical_sources ADD COLUMN IF NOT EXISTS start_year INTEGER;
ALTER TABLE historical_sources ADD COLUMN IF NOT EXISTS end_year INTEGER;

-- 2. Índices para ordenação e filtragem por ano
CREATE INDEX IF NOT EXISTS idx_civilizations_start_year ON civilizations(start_year) WHERE start_year IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_historical_characters_start_year ON historical_characters(start_year) WHERE start_year IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_historical_events_start_year ON historical_events(start_year) WHERE start_year IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_artifacts_start_year ON artifacts(start_year) WHERE start_year IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_artifacts_estimated_year ON artifacts(estimated_year) WHERE estimated_year IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_historical_locations_start_year ON historical_locations(start_year) WHERE start_year IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_historical_sources_start_year ON historical_sources(start_year) WHERE start_year IS NOT NULL;

-- 3. Função RPC unificada para paginação da Timeline
CREATE OR REPLACE FUNCTION get_timeline(
    p_filter VARCHAR DEFAULT NULL,
    p_start_year INTEGER DEFAULT NULL,
    p_end_year INTEGER DEFAULT NULL,
    p_search TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
) RETURNS TABLE (
    id UUID,
    slug VARCHAR,
    entity_type VARCHAR,
    title TEXT,
    description TEXT,
    year INTEGER,
    image_url TEXT,
    color VARCHAR(7)
) LANGUAGE sql STABLE
AS $$
    WITH timeline AS (
        SELECT
            c.id,
            c.slug,
            'civilization'::VARCHAR AS entity_type,
            c.name::TEXT AS title,
            COALESCE(c.summary, c.description)::TEXT AS description,
            c.start_year AS year,
            c.cover_image_url AS image_url,
            c.color
        FROM civilizations c
        WHERE c.ativo = true AND c.publication_status = 'published'

        UNION ALL

        SELECT
            hc.id,
            hc.slug,
            'historical_character'::VARCHAR,
            hc.nome::TEXT,
            COALESCE(hc.descricao_resumida, hc.descricao)::TEXT,
            hc.start_year,
            hc.imagem_principal AS image_url,
            NULL AS color
        FROM historical_characters hc
        WHERE hc.ativo = true AND hc.publication_status = 'published'

        UNION ALL

        SELECT
            he.id,
            he.slug,
            'historical_event'::VARCHAR,
            he.titulo::TEXT,
            COALESCE(he.descricao_resumida, he.descricao)::TEXT,
            he.start_year,
            NULL::TEXT,
            NULL
        FROM historical_events he
        WHERE he.ativo = true AND he.publication_status = 'published'

        UNION ALL

        SELECT
            a.id,
            a.slug,
            'artifact'::VARCHAR,
            a.name::TEXT,
            a.description::TEXT,
            COALESCE(a.start_year, a.estimated_year),
            a.cover_image_url AS image_url,
            NULL
        FROM artifacts a
        WHERE a.ativo = true AND a.publication_status = 'published'

        UNION ALL

        SELECT
            hl.id,
            hl.slug,
            'historical_location'::VARCHAR,
            hl.name::TEXT,
            hl.description::TEXT,
            hl.start_year,
            hl.cover_image_url AS image_url,
            NULL
        FROM historical_locations hl
        WHERE hl.ativo = true AND hl.publication_status = 'published'

        UNION ALL

        SELECT
            hs.id,
            hs.slug,
            'historical_source'::VARCHAR,
            hs.titulo::TEXT,
            hs.descricao::TEXT,
            hs.start_year,
            NULL::TEXT,
            NULL
        FROM historical_sources hs
        WHERE hs.ativo = true AND hs.publication_status = 'published'
    )
    SELECT *
    FROM timeline
    WHERE (p_filter IS NULL OR entity_type = p_filter)
      AND (p_start_year IS NULL OR year >= p_start_year)
      AND (p_end_year IS NULL OR year <= p_end_year)
      AND (p_search IS NULL OR p_search = '' OR title ILIKE '%' || p_search || '%')
      AND year IS NOT NULL
    ORDER BY year ASC
    LIMIT p_limit OFFSET p_offset;
$$;

-- 4. Função RPC para itens relacionados por proximidade cronológica
CREATE OR REPLACE FUNCTION get_related_items(
    p_entity_type VARCHAR,
    p_entity_id UUID,
    p_radius INTEGER DEFAULT 100
) RETURNS TABLE (
    id UUID,
    slug VARCHAR,
    entity_type VARCHAR,
    title TEXT,
    description TEXT,
    year INTEGER,
    image_url TEXT,
    color VARCHAR(7)
) LANGUAGE plpgsql STABLE
AS $$
DECLARE
    v_year INTEGER;
BEGIN
    SELECT year INTO v_year
    FROM get_timeline(p_filter => p_entity_type)
    WHERE id = p_entity_id
    LIMIT 1;

    IF v_year IS NULL THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT *
    FROM get_timeline()
    WHERE year BETWEEN (v_year - p_radius) AND (v_year + p_radius)
      AND NOT (entity_type = p_entity_type AND id = p_entity_id)
    ORDER BY ABS(year - v_year) ASC
    LIMIT 20;
END;
$$;

-- 5. Políticas de segurança para as funções (RLS já nas tabelas)
COMMENT ON FUNCTION get_timeline IS 'Retorna itens unificados para a Timeline do CHRONOS';
COMMENT ON FUNCTION get_related_items IS 'Retorna itens cronologicamente próximos ao item informado';

COMMIT;
