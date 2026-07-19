-- Migration: Create historical_events table
-- Description: Tabela núcleo para gerenciar os Eventos Históricos do ecossistema CHRONOS, associados a Eras.
-- Sprint: 4.2.1
-- Date: 18/07/2026
-- Author: Equipe de Engenharia CHRONOS

-- 1. Criação da tabela oficial 'historical_events' de forma resiliente e idempotente
CREATE TABLE IF NOT EXISTS historical_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    era_id UUID NOT NULL,
    slug VARCHAR(255) NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    titulo_curto VARCHAR(100) NOT NULL,
    descricao TEXT NOT NULL,
    descricao_resumida TEXT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    date_precision VARCHAR(50) NOT NULL DEFAULT 'year',
    start_year BIGINT NOT NULL,
    end_year BIGINT,
    latitude NUMERIC(10, 8),
    longitude NUMERIC(11, 8),
    importance_score INTEGER NOT NULL DEFAULT 3,
    publication_status VARCHAR(50) NOT NULL DEFAULT 'draft',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints de integridade, chave estrangeira e validação relacional
    CONSTRAINT fk_historical_events_era_id FOREIGN KEY (era_id) REFERENCES eras(id) ON DELETE CASCADE,
    CONSTRAINT uq_historical_events_slug UNIQUE (slug),
    
    -- Verificações de limites lógicos temporais e geográficos
    CONSTRAINT chk_historical_events_end_year_ge_start_year CHECK (end_year IS NULL OR end_year >= start_year),
    CONSTRAINT chk_historical_events_latitude CHECK (latitude IS NULL OR (latitude BETWEEN -90.0 AND 90.0)),
    CONSTRAINT chk_historical_events_longitude CHECK (longitude IS NULL OR (longitude BETWEEN -180.0 AND 180.0)),
    CONSTRAINT chk_historical_events_importance_score CHECK (importance_score BETWEEN 1 AND 5),
    
    -- Validações de limites e valores de enums textuais
    CONSTRAINT chk_historical_events_publication_status CHECK (publication_status IN ('draft', 'review', 'published', 'archived')),
    CONSTRAINT chk_historical_events_event_type CHECK (event_type IN ('political', 'military', 'social', 'cultural', 'scientific', 'religious', 'economic', 'other')),
    CONSTRAINT chk_historical_events_date_precision CHECK (date_precision IN ('exact', 'century', 'decade', 'year', 'month', 'day', 'approximate')),

    -- Prevenção de strings vazias ou compostas puramente por espaços em branco para higienização dos dados
    CONSTRAINT chk_historical_events_titulo_no_whitespace CHECK (length(trim(titulo)) > 0),
    CONSTRAINT chk_historical_events_slug_no_whitespace CHECK (length(trim(slug)) > 0),
    CONSTRAINT chk_historical_events_titulo_curto_no_whitespace CHECK (length(trim(titulo_curto)) > 0),
    CONSTRAINT chk_historical_events_descricao_no_whitespace CHECK (length(trim(descricao)) > 0),
    CONSTRAINT chk_historical_events_descricao_resumida_no_whitespace CHECK (length(trim(descricao_resumida)) > 0)
);

-- 2. Criação de índices para máxima performance de buscas, filtros e relacionamentos
CREATE INDEX IF NOT EXISTS idx_historical_events_era_id ON historical_events(era_id);
CREATE INDEX IF NOT EXISTS idx_historical_events_publication_status ON historical_events(publication_status);
CREATE INDEX IF NOT EXISTS idx_historical_events_ativo ON historical_events(ativo);
CREATE INDEX IF NOT EXISTS idx_historical_events_start_year ON historical_events(start_year);
CREATE INDEX IF NOT EXISTS idx_historical_events_end_year ON historical_events(end_year) WHERE end_year IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_historical_events_event_type ON historical_events(event_type);
CREATE INDEX IF NOT EXISTS idx_historical_events_importance_score ON historical_events(importance_score);
CREATE INDEX IF NOT EXISTS idx_historical_events_geo ON historical_events(latitude, longitude) WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- 3. Trigger para atualização automática da coluna 'updated_at' antes de qualquer update
DROP TRIGGER IF EXISTS set_timestamp_historical_events ON historical_events;
CREATE TRIGGER set_timestamp_historical_events
BEFORE UPDATE ON historical_events
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- 4. Ativação do Row Level Security (RLS) para proteção de dados e isolamento seguro
ALTER TABLE historical_events ENABLE ROW LEVEL SECURITY;

-- 5. Políticas de Row Level Security (RLS) seguras e idempotentes
-- SELECT: Permitido de forma pública e geral (usuários anônimos e autenticados) para consumo da UI
DROP POLICY IF EXISTS policy_historical_events_select_public ON historical_events;
CREATE POLICY policy_historical_events_select_public
ON historical_events
FOR SELECT
USING (true);

-- INSERT: Permitido somente para usuários autenticados (Editores e Administradores)
DROP POLICY IF EXISTS policy_historical_events_insert_authenticated ON historical_events;
CREATE POLICY policy_historical_events_insert_authenticated
ON historical_events
FOR INSERT
TO authenticated
WITH CHECK (true);

-- UPDATE: Permitido somente para usuários autenticados (Editores e Administradores)
DROP POLICY IF EXISTS policy_historical_events_update_authenticated ON historical_events;
CREATE POLICY policy_historical_events_update_authenticated
ON historical_events
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- DELETE: Permitido somente para usuários autenticados (Administradores)
DROP POLICY IF EXISTS policy_historical_events_delete_authenticated ON historical_events;
CREATE POLICY policy_historical_events_delete_authenticated
ON historical_events
FOR DELETE
TO authenticated
USING (true);

-- 6. Comentários semânticos estruturados (COMMENT ON TABLE e COMMENT ON COLUMN) para enriquecer o catálogo de dados
COMMENT ON TABLE historical_events IS 'Tabela que define os Eventos Históricos do ecossistema CHRONOS, servindo como âncora relacional principal e conectando-se cronologicamente a Eras.';

COMMENT ON COLUMN historical_events.id IS 'Identificador único universal (UUID) do evento histórico gerado nativamente pelo PostgreSQL.';
COMMENT ON COLUMN historical_events.era_id IS 'Chave estrangeira (FK) referenciando a Era histórica na qual este evento está categorizado.';
COMMENT ON COLUMN historical_events.slug IS 'Slug textual único usado para rotas amigáveis de roteamento web/móvel e buscas diretas (ex: queda-de-roma).';
COMMENT ON COLUMN historical_events.titulo IS 'Título oficial detalhado do evento histórico (ex: A Queda de Constantinopla).';
COMMENT ON COLUMN historical_events.titulo_curto IS 'Título abreviado e conciso do evento histórico para exibição em interfaces com espaço visual denso.';
COMMENT ON COLUMN historical_events.descricao IS 'Descrição de profundidade acadêmica retratando os acontecimentos, antecedentes e impactos históricos do evento.';
COMMENT ON COLUMN historical_events.descricao_resumida IS 'Resumo conciso de um parágrafo para cartões de listagem rápida e tooltips de interface.';
COMMENT ON COLUMN historical_events.event_type IS 'Categoria do evento para filtros de classificação temática (political, military, social, cultural, scientific, religious, economic, other).';
COMMENT ON COLUMN historical_events.date_precision IS 'Nível de precisão temporal atribuído à data do evento (exact, century, decade, year, month, day, approximate).';
COMMENT ON COLUMN historical_events.start_year IS 'Ano de início do acontecimento histórico. Números negativos indicam datas Antes de Cristo (a.C.).';
COMMENT ON COLUMN historical_events.end_year IS 'Ano de término do acontecimento histórico. Nulo para eventos de natureza pontual ou instantânea.';
COMMENT ON COLUMN historical_events.latitude IS 'Latitude GPS decimal (-90 a 90) para renderização espacial e cálculos geográficos.';
COMMENT ON COLUMN historical_events.longitude IS 'Longitude GPS decimal (-180 a 180) para renderização espacial e cálculos geográficos.';
COMMENT ON COLUMN historical_events.importance_score IS 'Pontuação de relevância do evento (de 1 a 5) usada para determinar filtros de nível de detalhe dinâmico de zoom na UI.';
COMMENT ON COLUMN historical_events.publication_status IS 'Estado de moderação e fluxo de trabalho editorial do registro (draft, review, published, archived).';
COMMENT ON COLUMN historical_events.ativo IS 'Inindicador lógico para ativação ou arquivamento temporário de exibição pública na UI sem deleção dos dados.';
COMMENT ON COLUMN historical_events.created_at IS 'Data e hora do registro inicial de cadastro do evento histórico no banco de dados.';
COMMENT ON COLUMN historical_events.updated_at IS 'Data e hora em que ocorreu a última alteração estrutural ou textual nos dados deste registro.';
