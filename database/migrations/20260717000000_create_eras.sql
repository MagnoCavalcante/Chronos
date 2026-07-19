-- Migration: Create eras table
-- Description: Tabela base para gerenciar as Eras do ecossistema CHRONOS.
-- Sprint: 4.1.1
-- Date: 18/07/2026
-- Author: Equipe de Engenharia CHRONOS

-- 1. Função global para atualização automática do timestamp 'updated_at' (se não existir)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Documentação da função global reutilizável
COMMENT ON FUNCTION update_updated_at_column() IS 'Função utilitária global responsável por atualizar automaticamente a coluna updated_at com o timestamp corrente antes de qualquer operação de UPDATE.';

-- 2. Criação da tabela oficial 'eras' de forma resiliente
CREATE TABLE IF NOT EXISTS eras (
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
    icon_key VARCHAR(100),
    cover_image_url TEXT,
    publication_status VARCHAR(50) NOT NULL DEFAULT 'draft',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints de integridade e validação
    CONSTRAINT uq_eras_slug UNIQUE (slug),
    CONSTRAINT uq_eras_ordem_cronologica UNIQUE (ordem_cronologica),
    CONSTRAINT chk_eras_fim_ano_ge_inicio_ano CHECK (fim_ano >= inicio_ano),
    CONSTRAINT chk_eras_cor_hex_format CHECK (cor_hex ~ '^#[0-9A-Fa-f]{6}$'),
    CONSTRAINT chk_eras_publication_status_permitido CHECK (publication_status IN ('draft', 'review', 'published', 'archived')),
    
    -- Validações para impedir strings compostas apenas por espaços em branco (Robustez de dados)
    CONSTRAINT chk_eras_nome_no_whitespace CHECK (length(trim(nome)) > 0),
    CONSTRAINT chk_eras_slug_no_whitespace CHECK (length(trim(slug)) > 0),
    CONSTRAINT chk_eras_titulo_curto_no_whitespace CHECK (length(trim(titulo_curto)) > 0),
    CONSTRAINT chk_eras_descricao_resumida_no_whitespace CHECK (length(trim(descricao_resumida)) > 0)
);

-- 3. Criação de índices otimizados para busca e performance (sem índices redundantes em colunas UNIQUE)
CREATE INDEX IF NOT EXISTS idx_eras_publication_status ON eras(publication_status);
CREATE INDEX IF NOT EXISTS idx_eras_ativo ON eras(ativo);
CREATE INDEX IF NOT EXISTS idx_eras_inicio_ano ON eras(inicio_ano);
CREATE INDEX IF NOT EXISTS idx_eras_fim_ano ON eras(fim_ano);

-- 4. Registro idempotente do trigger para atualização de updated_at
DROP TRIGGER IF EXISTS set_timestamp_eras ON eras;
CREATE TRIGGER set_timestamp_eras
BEFORE UPDATE ON eras
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- 5. Ativação do Row Level Security (RLS)
ALTER TABLE eras ENABLE ROW LEVEL SECURITY;

-- 6. Definição das Políticas de Acesso Seguro (RLS) de forma resiliente (idempotente)

-- SELECT: Permitido para leitura pública geral (usuários anônimos e autenticados)
DROP POLICY IF EXISTS policy_eras_select_public ON eras;
CREATE POLICY policy_eras_select_public
ON eras
FOR SELECT
USING (true);

-- INSERT: Somente usuários autenticados podem inserir novos registros de eras
DROP POLICY IF EXISTS policy_eras_insert_authenticated ON eras;
CREATE POLICY policy_eras_insert_authenticated
ON eras
FOR INSERT
TO authenticated
WITH CHECK (true);

-- UPDATE: Somente usuários autenticados podem atualizar registros existentes de eras
DROP POLICY IF EXISTS policy_eras_update_authenticated ON eras;
CREATE POLICY policy_eras_update_authenticated
ON eras
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- DELETE: Somente usuários autenticados podem remover registros de eras
DROP POLICY IF EXISTS policy_eras_delete_authenticated ON eras;
CREATE POLICY policy_eras_delete_authenticated
ON eras
FOR DELETE
TO authenticated
USING (true);

-- 7. Documentação do esquema físico através de comentários SQL ricos (COMMENT ON COLUMN)
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
COMMENT ON COLUMN eras.icon_key IS 'Identificador textual livre do ícone a ser renderizado na interface do usuário (desacoplado de bibliotecas específicas).';
COMMENT ON COLUMN eras.cover_image_url IS 'URL absoluto ou caminho do recurso de imagem de capa associado à Era, usado em heros ou cabeçalhos.';
COMMENT ON COLUMN eras.publication_status IS 'Estado de publicação editorial da Era para controle de fluxo de conteúdo (draft, review, published, archived).';
COMMENT ON COLUMN eras.ativo IS 'Flag lógico para ocultar ou exibir a Era na interface pública sem remover os dados.';
COMMENT ON COLUMN eras.created_at IS 'Data e hora em que a Era foi registrada no banco de dados.';
COMMENT ON COLUMN eras.updated_at IS 'Data e hora da última atualização dos dados deste registro.';
