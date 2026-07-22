-- Migration: Historical Knowledge Graph schema
-- Description: Adiciona tabela de fontes históricas e RPC para descoberta de relacionamentos.

BEGIN;

-- 1. Tabela de fontes históricas (idêntica ao padrão do projeto)
CREATE TABLE IF NOT EXISTS historical_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) NOT NULL UNIQUE,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT NOT NULL,
    autor VARCHAR(255),
    data_criacao INTEGER,
    start_year INTEGER,
    end_year INTEGER,
    civilizacao_id UUID,
    publication_status VARCHAR(50) NOT NULL DEFAULT 'published',
    ativo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

ALTER TABLE historical_sources ADD COLUMN IF NOT EXISTS civilizacao_id UUID;

CREATE INDEX IF NOT EXISTS idx_historical_sources_start_year ON historical_sources(start_year) WHERE start_year IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_historical_sources_civilizacao_id ON historical_sources(civilizacao_id) WHERE civilizacao_id IS NOT NULL;

ALTER TABLE historical_sources ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS policy_historical_sources_select_public ON historical_sources;
CREATE POLICY policy_historical_sources_select_public
ON historical_sources FOR SELECT USING (true);

-- 2. Função RPC para descobrir relacionamentos baseados em regras cronológicas e FKs
CREATE OR REPLACE FUNCTION get_relationships(
    p_entity_type VARCHAR,
    p_entity_id UUID,
    p_limit INTEGER DEFAULT 100
) RETURNS TABLE (
    id UUID,
    slug VARCHAR,
    entity_type VARCHAR,
    title TEXT,
    description TEXT,
    year INTEGER,
    image_url TEXT,
    color VARCHAR(7),
    relation_type VARCHAR(50),
    strength INTEGER
) LANGUAGE plpgsql STABLE
AS $$
DECLARE
    v_year INTEGER;
    v_civ_id UUID;
    v_loc_id UUID;
    v_era_id UUID;
BEGIN
    ------------------------------------------------------------------
    -- Personagem histórico
    ------------------------------------------------------------------
    IF p_entity_type = 'historical_character' THEN
        SELECT hc.start_year, hc.civilizacao_principal_id, hc.local_nascimento_id, hc.era_id
        INTO v_year, v_civ_id, v_loc_id, v_era_id
        FROM historical_characters hc
        WHERE hc.id = p_entity_id AND hc.ativo = true AND hc.publication_status = 'published';

        -- Civilização principal
        RETURN QUERY
        SELECT c.id, c.slug, 'civilization'::VARCHAR, c.name::TEXT, c.description::TEXT,
               c.start_year, NULL::TEXT, NULL::VARCHAR(7), 'Civilização'::VARCHAR(50), 100
        FROM civilizations c
        WHERE c.id = v_civ_id AND c.ativo = true;

        -- Personagens relacionados (mesma civilização ou mesma era)
        RETURN QUERY
        SELECT hc2.id, hc2.slug, 'historical_character'::VARCHAR, hc2.nome::TEXT,
               COALESCE(hc2.descricao_resumida, hc2.descricao)::TEXT,
               hc2.start_year, hc2.imagem_principal,
               hc2.cor_identificacao,
               CASE
                   WHEN hc2.civilizacao_principal_id = v_civ_id THEN 'Personagem Relacionado'
                   ELSE 'Contemporâneo'
               END::VARCHAR(50),
               CASE
                   WHEN hc2.civilizacao_principal_id = v_civ_id THEN 90
                   WHEN hc2.era_id = v_era_id THEN 70
                   ELSE 50
               END
        FROM historical_characters hc2
        WHERE hc2.id <> p_entity_id
          AND hc2.ativo = true AND hc2.publication_status = 'published'
          AND (hc2.civilizacao_principal_id = v_civ_id OR hc2.era_id = v_era_id)
        LIMIT p_limit;

        -- Eventos próximos ao período de vida
        RETURN QUERY
        SELECT he.id, he.slug, 'historical_event'::VARCHAR, he.titulo::TEXT,
               COALESCE(he.descricao_resumida, he.descricao)::TEXT,
               he.start_year, NULL::TEXT, NULL::VARCHAR(7), 'Evento'::VARCHAR(50),
               GREATEST(0, 100 - ABS(COALESCE(he.start_year, 0) - COALESCE(v_year, 0)) / 10)
        FROM historical_events he
        WHERE he.ativo = true AND he.publication_status = 'published'
          AND he.start_year BETWEEN COALESCE(v_year, 0) - 100 AND COALESCE(v_year, 0) + 100
        LIMIT p_limit;

        -- Localizações importantes (nascimento/morte)
        RETURN QUERY
        SELECT hl.id, hl.slug, 'historical_location'::VARCHAR, hl.name::TEXT,
               COALESCE(hl.summary, hl.description)::TEXT, hl.start_year,
               hl.cover_image_url, NULL::VARCHAR(7), 'Localização Importante'::VARCHAR(50), 85
        FROM historical_locations hl
        WHERE hl.id IN (v_loc_id, (SELECT hc.local_morte_id FROM historical_characters hc WHERE hc.id = p_entity_id))
          AND hl.ativo = true;

        -- Artefatos relacionados (mesma civilização ou cronologia próxima)
        RETURN QUERY
        SELECT a.id, a.slug, 'artifact'::VARCHAR, a.name::TEXT,
               COALESCE(a.summary, a.description)::TEXT, a.estimated_year,
               a.cover_image_url, NULL::VARCHAR(7), 'Artefato Relacionado'::VARCHAR(50),
               CASE
                   WHEN a.origin_civilization_id = v_civ_id THEN 80
                   ELSE GREATEST(0, 100 - ABS(a.estimated_year - COALESCE(v_year, 0)) / 10)
               END
        FROM artifacts a
        WHERE a.ativo = true AND a.publication_status = 'published'
          AND (a.origin_civilization_id = v_civ_id
               OR a.estimated_year BETWEEN COALESCE(v_year, 0) - 100 AND COALESCE(v_year, 0) + 100)
        LIMIT p_limit;

        -- Fontes históricas
        RETURN QUERY
        SELECT hs.id, hs.slug, 'historical_source'::VARCHAR, hs.titulo::TEXT,
               hs.descricao::TEXT, hs.start_year, NULL::TEXT, NULL::VARCHAR(7),
               'Fonte Histórica'::VARCHAR(50), 60
        FROM historical_sources hs
        WHERE hs.ativo = true
          AND (hs.civilizacao_id = v_civ_id
               OR hs.start_year BETWEEN COALESCE(v_year, 0) - 100 AND COALESCE(v_year, 0) + 100)
        LIMIT p_limit;

    ------------------------------------------------------------------
    -- Civilização
    ------------------------------------------------------------------
    ELSIF p_entity_type = 'civilization' THEN
        SELECT c.start_year, c.end_year, c.id
        INTO v_year, v_loc_id, v_civ_id
        FROM civilizations c
        WHERE c.id = p_entity_id AND c.ativo = true;

        -- Personagens
        RETURN QUERY
        SELECT hc.id, hc.slug, 'historical_character'::VARCHAR, hc.nome::TEXT,
               COALESCE(hc.descricao_resumida, hc.descricao)::TEXT, hc.start_year,
               hc.imagem_principal, hc.cor_identificacao, 'Personagem'::VARCHAR(50), 95
        FROM historical_characters hc
        WHERE hc.civilizacao_principal_id = p_entity_id AND hc.ativo = true AND hc.publication_status = 'published'
        LIMIT p_limit;

        -- Eventos
        RETURN QUERY
        SELECT he.id, he.slug, 'historical_event'::VARCHAR, he.titulo::TEXT,
               COALESCE(he.descricao_resumida, he.descricao)::TEXT, he.start_year,
               NULL::TEXT, NULL::VARCHAR(7), 'Evento'::VARCHAR(50),
               GREATEST(0, 100 - ABS(he.start_year - COALESCE(v_year, 0)) / 10)
        FROM historical_events he
        WHERE he.ativo = true AND he.publication_status = 'published'
          AND he.start_year BETWEEN COALESCE(v_year, 0) - 200 AND COALESCE(v_loc_id, 0) + 200
        LIMIT p_limit;

        -- Artefatos
        RETURN QUERY
        SELECT a.id, a.slug, 'artifact'::VARCHAR, a.name::TEXT,
               COALESCE(a.summary, a.description)::TEXT, a.estimated_year,
               a.cover_image_url, NULL::VARCHAR(7), 'Artefato'::VARCHAR(50), 90
        FROM artifacts a
        WHERE a.origin_civilization_id = p_entity_id AND a.ativo = true AND a.publication_status = 'published'
        LIMIT p_limit;

        -- Localizações
        RETURN QUERY
        SELECT hl.id, hl.slug, 'historical_location'::VARCHAR, hl.name::TEXT,
               COALESCE(hl.summary, hl.description)::TEXT, hl.start_year,
               hl.cover_image_url, NULL::VARCHAR(7), 'Território'::VARCHAR(50), 70
        FROM historical_locations hl
        WHERE hl.ativo = true
          AND hl.start_year BETWEEN COALESCE(v_year, 0) - 100 AND COALESCE(v_loc_id, 0) + 100
        LIMIT p_limit;

        -- Civilizações contemporâneas
        RETURN QUERY
        SELECT c2.id, c2.slug, 'civilization'::VARCHAR, c2.name::TEXT, c2.description::TEXT,
               c2.start_year, NULL::TEXT, NULL::VARCHAR(7), 'Civilização Contemporânea'::VARCHAR(50), 75
        FROM civilizations c2
        WHERE c2.id <> p_entity_id AND c2.ativo = true
          AND c2.start_year <= COALESCE(v_loc_id, c2.end_year, 0)
          AND COALESCE(c2.end_year, 9999) >= COALESCE(v_year, 0)
        LIMIT p_limit;

        -- Fontes
        RETURN QUERY
        SELECT hs.id, hs.slug, 'historical_source'::VARCHAR, hs.titulo::TEXT,
               hs.descricao::TEXT, hs.start_year, NULL::TEXT, NULL::VARCHAR(7),
               'Fonte'::VARCHAR(50), 60
        FROM historical_sources hs
        WHERE hs.ativo = true AND hs.civilizacao_id = p_entity_id
        LIMIT p_limit;

    ------------------------------------------------------------------
    -- Evento
    ------------------------------------------------------------------
    ELSIF p_entity_type = 'historical_event' THEN
        SELECT he.start_year, he.end_year, he.era_id
        INTO v_year, v_loc_id, v_era_id
        FROM historical_events he
        WHERE he.id = p_entity_id AND he.ativo = true AND he.publication_status = 'published';

        -- Personagens (mesma era ou cronologia próxima)
        RETURN QUERY
        SELECT hc.id, hc.slug, 'historical_character'::VARCHAR, hc.nome::TEXT,
               COALESCE(hc.descricao_resumida, hc.descricao)::TEXT, hc.start_year,
               hc.imagem_principal, hc.cor_identificacao, 'Personagem Envolvido'::VARCHAR(50),
               CASE WHEN hc.era_id = v_era_id THEN 85 ELSE 60 END
        FROM historical_characters hc
        WHERE hc.ativo = true AND hc.publication_status = 'published'
          AND (hc.era_id = v_era_id
               OR hc.start_year BETWEEN COALESCE(v_year, 0) - 80 AND COALESCE(v_loc_id, COALESCE(v_year, 0)) + 80)
        LIMIT p_limit;

        -- Civilizações participantes
        RETURN QUERY
        SELECT c.id, c.slug, 'civilization'::VARCHAR, c.name::TEXT, c.description::TEXT,
               c.start_year, NULL::TEXT, NULL::VARCHAR(7), 'Civilização Participante'::VARCHAR(50), 80
        FROM civilizations c
        WHERE c.ativo = true
          AND c.start_year <= COALESCE(v_loc_id, c.end_year, 0)
          AND COALESCE(c.end_year, 9999) >= COALESCE(v_year, 0)
        LIMIT p_limit;

        -- Eventos anteriores
        RETURN QUERY
        SELECT he2.id, he2.slug, 'historical_event'::VARCHAR, he2.titulo::TEXT,
               COALESCE(he2.descricao_resumida, he2.descricao)::TEXT, he2.start_year,
               NULL::TEXT, NULL::VARCHAR(7), 'Evento Anterior'::VARCHAR(50),
               GREATEST(0, 100 - ABS(COALESCE(v_year, 0) - he2.start_year) / 10)
        FROM historical_events he2
        WHERE he2.id <> p_entity_id AND he2.ativo = true AND he2.publication_status = 'published'
          AND he2.start_year < COALESCE(v_year, 0)
        ORDER BY he2.start_year DESC
        LIMIT p_limit / 2;

        -- Eventos posteriores
        RETURN QUERY
        SELECT he2.id, he2.slug, 'historical_event'::VARCHAR, he2.titulo::TEXT,
               COALESCE(he2.descricao_resumida, he2.descricao)::TEXT, he2.start_year,
               NULL::TEXT, NULL::VARCHAR(7), 'Evento Posterior'::VARCHAR(50),
               GREATEST(0, 100 - ABS(he2.start_year - COALESCE(v_year, 0)) / 10)
        FROM historical_events he2
        WHERE he2.id <> p_entity_id AND he2.ativo = true AND he2.publication_status = 'published'
          AND he2.start_year > COALESCE(v_year, 0)
        ORDER BY he2.start_year ASC
        LIMIT p_limit / 2;

        -- Localizações
        RETURN QUERY
        SELECT hl.id, hl.slug, 'historical_location'::VARCHAR, hl.name::TEXT,
               COALESCE(hl.summary, hl.description)::TEXT, hl.start_year,
               hl.cover_image_url, NULL::VARCHAR(7), 'Localização'::VARCHAR(50), 70
        FROM historical_locations hl
        WHERE hl.ativo = true
          AND hl.start_year BETWEEN COALESCE(v_year, 0) - 100 AND COALESCE(v_loc_id, COALESCE(v_year, 0)) + 100
        LIMIT p_limit;

        -- Artefatos
        RETURN QUERY
        SELECT a.id, a.slug, 'artifact'::VARCHAR, a.name::TEXT,
               COALESCE(a.summary, a.description)::TEXT, a.estimated_year,
               a.cover_image_url, NULL::VARCHAR(7), 'Artefato do Período'::VARCHAR(50), 65
        FROM artifacts a
        WHERE a.ativo = true AND a.publication_status = 'published'
          AND a.estimated_year BETWEEN COALESCE(v_year, 0) - 80 AND COALESCE(v_loc_id, COALESCE(v_year, 0)) + 80
        LIMIT p_limit;

        -- Fontes
        RETURN QUERY
        SELECT hs.id, hs.slug, 'historical_source'::VARCHAR, hs.titulo::TEXT,
               hs.descricao::TEXT, hs.start_year, NULL::TEXT, NULL::VARCHAR(7),
               'Fonte'::VARCHAR(50), 60
        FROM historical_sources hs
        WHERE hs.ativo = true
          AND hs.start_year BETWEEN COALESCE(v_year, 0) - 100 AND COALESCE(v_loc_id, COALESCE(v_year, 0)) + 100
        LIMIT p_limit;

    ------------------------------------------------------------------
    -- Localização
    ------------------------------------------------------------------
    ELSIF p_entity_type = 'historical_location' THEN
        SELECT hl.start_year, hl.end_year
        INTO v_year, v_loc_id
        FROM historical_locations hl
        WHERE hl.id = p_entity_id AND hl.ativo = true;

        -- Eventos ocorridos
        RETURN QUERY
        SELECT he.id, he.slug, 'historical_event'::VARCHAR, he.titulo::TEXT,
               COALESCE(he.descricao_resumida, he.descricao)::TEXT, he.start_year,
               NULL::TEXT, NULL::VARCHAR(7), 'Evento Ocorrido'::VARCHAR(50), 85
        FROM historical_events he
        WHERE he.ativo = true AND he.publication_status = 'published'
          AND he.start_year BETWEEN COALESCE(v_year, 0) - 100 AND COALESCE(v_loc_id, COALESCE(v_year, 0)) + 100
        LIMIT p_limit;

        -- Civilizações
        RETURN QUERY
        SELECT c.id, c.slug, 'civilization'::VARCHAR, c.name::TEXT, c.description::TEXT,
               c.start_year, NULL::TEXT, NULL::VARCHAR(7), 'Civilização'::VARCHAR(50), 80
        FROM civilizations c
        WHERE c.ativo = true
          AND c.start_year <= COALESCE(v_loc_id, c.end_year, 0)
          AND COALESCE(c.end_year, 9999) >= COALESCE(v_year, 0)
        LIMIT p_limit;

        -- Personagens
        RETURN QUERY
        SELECT hc.id, hc.slug, 'historical_character'::VARCHAR, hc.nome::TEXT,
               COALESCE(hc.descricao_resumida, hc.descricao)::TEXT, hc.start_year,
               hc.imagem_principal, hc.cor_identificacao, 'Personagem'::VARCHAR(50), 75
        FROM historical_characters hc
        WHERE hc.ativo = true AND hc.publication_status = 'published'
          AND (hc.local_nascimento_id = p_entity_id OR hc.local_morte_id = p_entity_id)
        LIMIT p_limit;

        -- Artefatos encontrados
        RETURN QUERY
        SELECT a.id, a.slug, 'artifact'::VARCHAR, a.name::TEXT,
               COALESCE(a.summary, a.description)::TEXT, a.estimated_year,
               a.cover_image_url, NULL::VARCHAR(7), 'Artefato Encontrado'::VARCHAR(50), 90
        FROM artifacts a
        WHERE a.origin_location_id = p_entity_id AND a.ativo = true AND a.publication_status = 'published'
        LIMIT p_limit;

        -- Fontes
        RETURN QUERY
        SELECT hs.id, hs.slug, 'historical_source'::VARCHAR, hs.titulo::TEXT,
               hs.descricao::TEXT, hs.start_year, NULL::TEXT, NULL::VARCHAR(7),
               'Fonte'::VARCHAR(50), 60
        FROM historical_sources hs
        WHERE hs.ativo = true
          AND hs.start_year BETWEEN COALESCE(v_year, 0) - 150 AND COALESCE(v_loc_id, COALESCE(v_year, 0)) + 150
        LIMIT p_limit;

    ------------------------------------------------------------------
    -- Artefato
    ------------------------------------------------------------------
    ELSIF p_entity_type = 'artifact' THEN
        SELECT a.estimated_year, a.origin_civilization_id, a.origin_location_id
        INTO v_year, v_civ_id, v_loc_id
        FROM artifacts a
        WHERE a.id = p_entity_id AND a.ativo = true AND a.publication_status = 'published';

        -- Origem civilizacional
        RETURN QUERY
        SELECT c.id, c.slug, 'civilization'::VARCHAR, c.name::TEXT, c.description::TEXT,
               c.start_year, NULL::TEXT, NULL::VARCHAR(7), 'Origem'::VARCHAR(50), 100
        FROM civilizations c
        WHERE c.id = v_civ_id AND c.ativo = true;

        -- Localização de origem
        RETURN QUERY
        SELECT hl.id, hl.slug, 'historical_location'::VARCHAR, hl.name::TEXT,
               COALESCE(hl.summary, hl.description)::TEXT, hl.start_year,
               hl.cover_image_url, NULL::VARCHAR(7), 'Localização'::VARCHAR(50), 95
        FROM historical_locations hl
        WHERE hl.id = v_loc_id AND hl.ativo = true;

        -- Personagens
        RETURN QUERY
        SELECT hc.id, hc.slug, 'historical_character'::VARCHAR, hc.nome::TEXT,
               COALESCE(hc.descricao_resumida, hc.descricao)::TEXT, hc.start_year,
               hc.imagem_principal, hc.cor_identificacao, 'Personagem'::VARCHAR(50), 70
        FROM historical_characters hc
        WHERE hc.ativo = true AND hc.publication_status = 'published'
          AND (hc.civilizacao_principal_id = v_civ_id OR hc.era_id = (SELECT era_id FROM artifacts a WHERE a.id = p_entity_id))
        LIMIT p_limit;

        -- Eventos relacionados
        RETURN QUERY
        SELECT he.id, he.slug, 'historical_event'::VARCHAR, he.titulo::TEXT,
               COALESCE(he.descricao_resumida, he.descricao)::TEXT, he.start_year,
               NULL::TEXT, NULL::VARCHAR(7), 'Evento Relacionado'::VARCHAR(50), 75
        FROM historical_events he
        WHERE he.ativo = true AND he.publication_status = 'published'
          AND he.start_year BETWEEN COALESCE(v_year, 0) - 100 AND COALESCE(v_year, 0) + 100
        LIMIT p_limit;

    ------------------------------------------------------------------
    -- Fonte histórica
    ------------------------------------------------------------------
    ELSIF p_entity_type = 'historical_source' THEN
        SELECT hs.start_year, hs.end_year, hs.civilizacao_id
        INTO v_year, v_loc_id, v_civ_id
        FROM historical_sources hs
        WHERE hs.id = p_entity_id AND hs.ativo = true;

        -- Autores (personagens contemporâneos ou da mesma civilização)
        RETURN QUERY
        SELECT hc.id, hc.slug, 'historical_character'::VARCHAR, hc.nome::TEXT,
               COALESCE(hc.descricao_resumida, hc.descricao)::TEXT, hc.start_year,
               hc.imagem_principal, hc.cor_identificacao, 'Autor'::VARCHAR(50),
               CASE WHEN hc.civilizacao_principal_id = v_civ_id THEN 90 ELSE 60 END
        FROM historical_characters hc
        WHERE hc.ativo = true AND hc.publication_status = 'published'
          AND (hc.civilizacao_principal_id = v_civ_id
               OR hc.start_year BETWEEN COALESCE(v_year, 0) - 80 AND COALESCE(v_loc_id, COALESCE(v_year, 0)) + 80)
        LIMIT p_limit;

        -- Eventos citados
        RETURN QUERY
        SELECT he.id, he.slug, 'historical_event'::VARCHAR, he.titulo::TEXT,
               COALESCE(he.descricao_resumida, he.descricao)::TEXT, he.start_year,
               NULL::TEXT, NULL::VARCHAR(7), 'Evento Citado'::VARCHAR(50), 80
        FROM historical_events he
        WHERE he.ativo = true AND he.publication_status = 'published'
          AND he.start_year BETWEEN COALESCE(v_year, 0) - 100 AND COALESCE(v_loc_id, COALESCE(v_year, 0)) + 100
        LIMIT p_limit;

        -- Civilizações
        RETURN QUERY
        SELECT c.id, c.slug, 'civilization'::VARCHAR, c.name::TEXT, c.description::TEXT,
               c.start_year, NULL::TEXT, NULL::VARCHAR(7), 'Civilização'::VARCHAR(50), 85
        FROM civilizations c
        WHERE c.id = v_civ_id AND c.ativo = true
        LIMIT p_limit;

        -- Artefatos
        RETURN QUERY
        SELECT a.id, a.slug, 'artifact'::VARCHAR, a.name::TEXT,
               COALESCE(a.summary, a.description)::TEXT, a.estimated_year,
               a.cover_image_url, NULL::VARCHAR(7), 'Artefato'::VARCHAR(50), 65
        FROM artifacts a
        WHERE a.ativo = true AND a.publication_status = 'published'
          AND a.estimated_year BETWEEN COALESCE(v_year, 0) - 100 AND COALESCE(v_loc_id, COALESCE(v_year, 0)) + 100
        LIMIT p_limit;
    END IF;
END;
$$;

-- 3. Políticas para a função
COMMENT ON FUNCTION get_relationships IS 'Descobre relacionamentos históricos automáticos entre entidades do CHRONOS';

COMMIT;
