-- Migration: Create eras table
-- Description: Tabela base para gerenciar as Eras do ecossistema CHRONOS.
-- Sprint: 4.1.1
-- Date: 18/07/2026
-- Author: Equipe de Engenharia CHRONOS

-- 1. Função global para atualização automática do timestamp 'updated_at' (se não existir)
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Remoção idempotente para garantir consistência em ambientes de teste/desenvolvimento
DROP TABLE IF EXISTS eras CASCADE;

-- 3. Criação da tabela oficial 'eras'
CREATE TABLE eras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    titulo_curto VARCHAR(100) NOT NULL,
    descricao TEXT NOT NULL,
    descricao_resumida TEXT NOT NULL,
    inicio_ano BIGINT NOT NULL,
    fim_ano BIGINT NOT NULL,
    ordem_cronologica INTEGER NOT NULL,
    cor_hex VARCHAR(7) NOT NULL,
    icone VARCHAR(100),
    imagem_capa TEXT,
    latitude_centro NUMERIC(10, 8),
    longitude_centro NUMERIC(11, 8),
    status VARCHAR(50) NOT NULL DEFAULT 'planejado',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints de integridade e validação
    CONSTRAINT uq_eras_slug UNIQUE (slug),
    CONSTRAINT uq_eras_ordem_cronologica UNIQUE (ordem_cronologica),
    CONSTRAINT chk_eras_fim_ano_ge_inicio_ano CHECK (fim_ano >= inicio_ano),
    CONSTRAINT chk_eras_cor_hex_format CHECK (cor_hex ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_eras_status_permitido CHECK (status IN ('planejado', 'em_desenvolvimento', 'em_revisao', 'concluido', 'adiado', 'cancelado', 'ativo', 'inativo')),
    CONSTRAINT chk_eras_latitude CHECK (latitude_centro BETWEEN -90 AND 90),
    CONSTRAINT chk_eras_longitude CHECK (longitude_centro BETWEEN -180 AND 180)
);

-- 4. Criação de índices otimizados para busca e performance
CREATE INDEX idx_eras_slug ON eras(slug);
CREATE INDEX idx_eras_ordem_cronologica ON eras(ordem_cronologica);
CREATE INDEX idx_eras_status ON eras(status);
CREATE INDEX idx_eras_ativo ON eras(ativo);
CREATE INDEX idx_eras_inicio_ano ON eras(inicio_ano);
CREATE INDEX idx_eras_fim_ano ON eras(fim_ano);

-- 5. Registro do trigger para atualização de updated_at
CREATE TRIGGER set_timestamp_eras
BEFORE UPDATE ON eras
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

-- 6. Ativação do Row Level Security (RLS)
ALTER TABLE eras ENABLE ROW LEVEL SECURITY;

-- 7. Definição das Políticas de Acesso Seguro (RLS)

-- SELECT: Permitido para leitura pública geral (usuários anônimos e autenticados)
CREATE POLICY policy_eras_select_public
ON eras
FOR SELECT
USING (true);

-- INSERT: Somente usuários autenticados podem inserir novos registros de eras
CREATE POLICY policy_eras_insert_authenticated
ON eras
FOR INSERT
TO authenticated
WITH CHECK (true);

-- UPDATE: Somente usuários autenticados podem atualizar registros existentes de eras
CREATE POLICY policy_eras_update_authenticated
ON eras
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- DELETE: Somente usuários autenticados podem remover registros de eras
CREATE POLICY policy_eras_delete_authenticated
ON eras
FOR DELETE
TO authenticated
USING (true);

-- 8. Documentação do esquema físico através de comentários SQL ricos (COMMENT ON COLUMN)
COMMENT ON TABLE eras IS 'Tabela que define as Eras históricas no ecossistema CHRONOS, servindo de base para todos os relacionamentos cronológicos futuros.';

COMMENT ON COLUMN eras.id IS 'Identificador único universal (UUID) gerado nativamente pelo PostgreSQL.';
COMMENT ON COLUMN eras.slug IS 'Slug textual único usado para rotas amigáveis na web e buscas indexadas (ex: antiguidade-classica).';
COMMENT ON COLUMN eras.nome IS 'Nome completo e oficial da Era histórica (ex: Idade de Ouro Islâmica).';
COMMENT ON COLUMN eras.titulo_curto IS 'Título simplificado para exibição em layouts densos ou cabeçalhos de timeline.';
COMMENT ON COLUMN eras.descricao IS 'Texto descritivo abrangente detalhando as principais características e marcos da Era.';
COMMENT ON COLUMN eras.descricao_resumida IS 'Resumo conciso de um parágrafo para tooltips, cartões informativos rápidos e pré-visualizações na UI.';
COMMENT ON COLUMN eras.inicio_ano IS 'Ano de início da era. Valores negativos representam anos antes de Cristo (a.C. / BC).';
COMMENT ON COLUMN eras.fim_ano IS 'Ano de término da era. Valores negativos representam anos antes de Cristo (a.C. / BC). Deve ser maior ou igual a inicio_ano.';
COMMENT ON COLUMN eras.ordem_cronologica IS 'Índice de ordenação sequencial único para organizar a ordem de exibição das Eras no aplicativo.';
COMMENT ON COLUMN eras.cor_hex IS 'Código hexadecimal de cor associado à identidade visual da Era, validado no padrão #RRGGBB.';
COMMENT ON COLUMN eras.icone IS 'Identificador do ícone a ser renderizado na interface do usuário (corresponde ao catálogo de ícones do Flutter/Lucide).';
COMMENT ON COLUMN eras.imagem_capa IS 'URL ou caminho do recurso de imagem de capa associado à Era, usado em heros ou cabeçalhos.';
COMMENT ON COLUMN eras.latitude_centro IS 'Latitude geográfica do centro focal ou de origem desta Era para representação em mapas.';
COMMENT ON COLUMN eras.longitude_centro IS 'Longitude geográfica do centro focal ou de origem desta Era para representação em mapas.';
COMMENT ON COLUMN eras.status IS 'Status da Era no ciclo de vida do produto (planejado, em_desenvolvimento, em_revisao, concluido, adiado, cancelado, ativo, inativo).';
COMMENT ON COLUMN eras.ativo IS 'Flag lógico para ocultar ou exibir a Era na interface pública sem remover os dados.';
COMMENT ON COLUMN eras.created_at IS 'Data e hora em que a Era foi registrada no banco de dados.';
COMMENT ON COLUMN eras.updated_at IS 'Data e hora da última atualização dos dados deste registro.';
