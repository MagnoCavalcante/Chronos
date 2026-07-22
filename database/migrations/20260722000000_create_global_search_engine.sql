CREATE TABLE IF NOT EXISTS historical_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) NOT NULL UNIQUE,
    titulo VARCHAR(255) NOT NULL,
    autor VARCHAR(255),
    descricao TEXT NOT NULL,
    descricao_resumida TEXT,
    url TEXT,
    publication_status VARCHAR(50) NOT NULL DEFAULT 'published',
    ativo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS entity_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    tag VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_entity_tags_type_id_tag UNIQUE (entity_type, entity_id, tag)
);

CREATE INDEX IF NOT EXISTS idx_historical_sources_publication ON historical_sources(publication_status, ativo);
CREATE INDEX IF NOT EXISTS idx_historical_sources_titulo ON historical_sources(titulo);
CREATE INDEX IF NOT EXISTS idx_entity_tags_lookup ON entity_tags(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_entity_tags_tag ON entity_tags(tag);

ALTER TABLE historical_sources ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS policy_historical_sources_select_public ON historical_sources;
CREATE POLICY policy_historical_sources_select_public
ON historical_sources FOR SELECT USING (true);

CREATE EXTENSION IF NOT EXISTS unaccent;

DROP FUNCTION IF EXISTS search_chronos(TEXT, TEXT, TEXT, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION search_chronos(
    p_query TEXT DEFAULT '',
    p_category TEXT DEFAULT NULL,
    p_sort TEXT DEFAULT 'relevance',
    p_limit INTEGER DEFAULT 30,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    entity_type TEXT,
    entity_id UUID,
    title TEXT,
    subtitle TEXT,
    summary TEXT,
    image_url TEXT,
    chronology_value BIGINT,
    created_at TIMESTAMPTZ,
    tags TEXT[],
    relevance INTEGER
)
LANGUAGE SQL
STABLE
AS $$
WITH parameters AS (
    SELECT NULLIF(regexp_replace(BTRIM(unaccent(p_query)), '\s+', ' ', 'g'), '') AS query
), records AS (
    SELECT
        'historical_character'::TEXT AS entity_type,
        c.id AS entity_id,
        c.nome::TEXT AS title,
        COALESCE(c.titulo, c.nome)::TEXT AS subtitle,
        c.descricao_resumida::TEXT AS summary,
        c.imagem_principal::TEXT AS image_url,
        EXTRACT(YEAR FROM c.data_nascimento)::BIGINT AS chronology_value,
        c.created_at,
        COALESCE((SELECT ARRAY_AGG(et.tag ORDER BY et.tag) FROM entity_tags et WHERE et.entity_type = 'historical_character' AND et.entity_id = c.id), ARRAY[]::TEXT[]) AS tags,
        CASE WHEN unaccent(c.nome) ILIKE (SELECT query || '%' FROM parameters) THEN 100 WHEN unaccent(c.nome) ILIKE (SELECT '%' || query || '%' FROM parameters) THEN 70 ELSE 20 END AS relevance
    FROM historical_characters c
    WHERE c.ativo = true AND c.publication_status = 'published'
    UNION ALL
    SELECT 'civilization', c.id, c.name, COALESCE(c.short_name, c.name), c.summary, NULL, c.start_year::BIGINT, c.created_at,
        COALESCE((SELECT ARRAY_AGG(et.tag ORDER BY et.tag) FROM entity_tags et WHERE et.entity_type = 'civilization' AND et.entity_id = c.id), ARRAY[]::TEXT[]),
        CASE WHEN unaccent(c.name) ILIKE (SELECT query || '%' FROM parameters) THEN 100 WHEN unaccent(c.name) ILIKE (SELECT '%' || query || '%' FROM parameters) THEN 70 ELSE 20 END
    FROM civilizations c WHERE c.ativo = true AND c.publication_status = 'published'
    UNION ALL
    SELECT 'historical_event', e.id, e.titulo, e.titulo_curto, e.descricao_resumida, NULL, e.start_year, e.created_at,
        COALESCE((SELECT ARRAY_AGG(et.tag ORDER BY et.tag) FROM entity_tags et WHERE et.entity_type = 'historical_event' AND et.entity_id = e.id), ARRAY[]::TEXT[]),
        CASE WHEN unaccent(e.titulo) ILIKE (SELECT query || '%' FROM parameters) THEN 100 WHEN unaccent(e.titulo) ILIKE (SELECT '%' || query || '%' FROM parameters) THEN 70 ELSE 20 END
    FROM historical_events e WHERE e.ativo = true AND e.publication_status = 'published'
    UNION ALL
    SELECT 'era', e.id, e.nome, COALESCE(e.titulo_curto, e.nome), e.descricao_resumida, NULL, e.inicio_ano::BIGINT, e.created_at,
        COALESCE((SELECT ARRAY_AGG(et.tag ORDER BY et.tag) FROM entity_tags et WHERE et.entity_type = 'era' AND et.entity_id = e.id), ARRAY[]::TEXT[]),
        CASE WHEN unaccent(e.nome) ILIKE (SELECT query || '%' FROM parameters) THEN 100 WHEN unaccent(e.nome) ILIKE (SELECT '%' || query || '%' FROM parameters) THEN 70 ELSE 20 END
    FROM eras e WHERE e.ativo = true AND e.publication_status = 'published'
    UNION ALL
    SELECT 'artifact', a.id, a.name, COALESCE(a.short_name, a.artifact_type), a.summary, a.cover_image_url, a.estimated_year::BIGINT, a.created_at,
        COALESCE((SELECT ARRAY_AGG(et.tag ORDER BY et.tag) FROM entity_tags et WHERE et.entity_type = 'artifact' AND et.entity_id = a.id), ARRAY[]::TEXT[]),
        CASE WHEN unaccent(a.name) ILIKE (SELECT query || '%' FROM parameters) THEN 100 WHEN unaccent(a.name) ILIKE (SELECT '%' || query || '%' FROM parameters) THEN 70 ELSE 20 END
    FROM artifacts a WHERE a.ativo = true AND a.publication_status = 'published'
    UNION ALL
    SELECT 'historical_location', l.id, l.name, COALESCE(l.short_name, l.modern_country), l.summary, l.cover_image_url, l.start_year::BIGINT, l.created_at,
        COALESCE((SELECT ARRAY_AGG(et.tag ORDER BY et.tag) FROM entity_tags et WHERE et.entity_type = 'historical_location' AND et.entity_id = l.id), ARRAY[]::TEXT[]),
        CASE WHEN unaccent(l.name) ILIKE (SELECT query || '%' FROM parameters) THEN 100 WHEN unaccent(l.name) ILIKE (SELECT '%' || query || '%' FROM parameters) THEN 70 ELSE 20 END
    FROM historical_locations l WHERE l.ativo = true AND l.publication_status = 'published'
    UNION ALL
    SELECT 'historical_source', s.id, s.titulo, COALESCE(s.autor, 'Fonte Histórica'), COALESCE(s.descricao_resumida, s.descricao), NULL, NULL, s.created_at,
        COALESCE((SELECT ARRAY_AGG(et.tag ORDER BY et.tag) FROM entity_tags et WHERE et.entity_type = 'historical_source' AND et.entity_id = s.id), ARRAY[]::TEXT[]),
        CASE WHEN unaccent(s.titulo) ILIKE (SELECT query || '%' FROM parameters) THEN 100 WHEN unaccent(s.titulo) ILIKE (SELECT '%' || query || '%' FROM parameters) THEN 70 ELSE 20 END
    FROM historical_sources s WHERE s.ativo = true AND s.publication_status = 'published'
), filtered AS (
    SELECT * FROM records r, parameters p
    WHERE (p_category IS NULL OR p_category = '' OR r.entity_type = p_category)
      AND (
          p.query IS NULL
          OR unaccent(r.title) ILIKE '%' || p.query || '%'
          OR unaccent(r.subtitle) ILIKE '%' || p.query || '%'
          OR unaccent(r.summary) ILIKE '%' || p.query || '%'
          OR EXISTS (SELECT 1 FROM UNNEST(r.tags) tag WHERE unaccent(tag) ILIKE '%' || p.query || '%')
          OR r.chronology_value::TEXT = p.query
      )
)
SELECT entity_type, entity_id, title, subtitle, summary, image_url, chronology_value, created_at, tags, relevance
FROM filtered
ORDER BY
    CASE WHEN p_sort = 'name_asc' THEN title END ASC,
    CASE WHEN p_sort = 'name_desc' THEN title END DESC,
    CASE WHEN p_sort = 'newest' THEN created_at END DESC,
    CASE WHEN p_sort = 'oldest' THEN created_at END ASC,
    CASE WHEN p_sort = 'relevance' THEN relevance END DESC,
    title ASC
LIMIT LEAST(GREATEST(p_limit, 1), 100)
OFFSET GREATEST(p_offset, 0);
$$;

GRANT EXECUTE ON FUNCTION search_chronos(TEXT, TEXT, TEXT, INTEGER, INTEGER) TO anon, authenticated;
