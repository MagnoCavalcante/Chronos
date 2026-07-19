-- Migration: Create historical_characters table
-- Description: Tabela base para gerenciar os Personagens Históricos do ecossistema CHRONOS.
-- Sprint: 4.3.2
-- Date: 19/07/2026
-- Author: Equipe de Engenharia CHRONOS

-- 1. Criação da tabela oficial 'historical_characters' de forma resiliente e idempotente
CREATE TABLE IF NOT EXISTS historical_characters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    nome_original VARCHAR(255),
    nome_alternativo VARCHAR(255),
    titulo VARCHAR(255),
    epiteto VARCHAR(255),
    descricao TEXT NOT NULL,
    descricao_resumida TEXT NOT NULL,
    data_nascimento DATE NOT NULL,
    data_morte DATE,
    era_id UUID NOT NULL,
    local_nascimento_id UUID, -- FK futura
    local_morte_id UUID, -- FK futura
    sexo VARCHAR(50) NOT NULL,
    ocupacao_principal VARCHAR(255),
    civilizacao_principal_id UUID, -- FK futura
    imagem_principal TEXT,
    cor_identificacao VARCHAR(7),
    publication_status VARCHAR(50) NOT NULL DEFAULT 'draft',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Constraints de integridade, chaves estrangeiras e validações estruturais
    CONSTRAINT fk_historical_characters_era_id FOREIGN KEY (era_id) REFERENCES eras(id) ON DELETE CASCADE,
    CONSTRAINT uq_historical_characters_slug UNIQUE (slug),
    
    -- Validação de coerência das datas (nascimento deve anteceder ou ser igual à morte)
    CONSTRAINT chk_historical_characters_datas_coerentes CHECK (data_morte IS NULL OR data_morte >= data_nascimento),
    
    -- Validação do padrão cromático hexadecimal (#RRGGBB)
    CONSTRAINT chk_historical_characters_cor_identificacao_format CHECK (cor_identificacao IS NULL OR cor_identificacao ~ '^#[0-9A-Fa-f]{6}$'),
    
    -- Restrições para enums textuais permitidos
    CONSTRAINT chk_historical_characters_sexo_permitido CHECK (sexo IN ('masculino', 'feminino', 'outro')),
    CONSTRAINT chk_historical_characters_publication_status CHECK (publication_status IN ('draft', 'review', 'published', 'archived')),

    -- Prevenção de strings vazias ou preenchidas apenas com espaços (Garantia de qualidade dos dados)
    CONSTRAINT chk_historical_characters_nome_no_whitespace CHECK (length(trim(nome)) > 0),
    CONSTRAINT chk_historical_characters_slug_no_whitespace CHECK (length(trim(slug)) > 0),
    CONSTRAINT chk_historical_characters_descricao_no_whitespace CHECK (length(trim(descricao)) > 0),
    CONSTRAINT chk_historical_characters_descricao_resumida_no_whitespace CHECK (length(trim(descricao_resumida)) > 0)
);

-- 2. Criação de índices otimizados para busca e performance (sem índices redundantes em colunas UNIQUE)
CREATE INDEX IF NOT EXISTS idx_historical_characters_nome ON historical_characters(nome);
CREATE INDEX IF NOT EXISTS idx_historical_characters_era_id ON historical_characters(era_id);
CREATE INDEX IF NOT EXISTS idx_historical_characters_publication_status ON historical_characters(publication_status);
CREATE INDEX IF NOT EXISTS idx_historical_characters_ativo ON historical_characters(ativo);
CREATE INDEX IF NOT EXISTS idx_historical_characters_data_nascimento ON historical_characters(data_nascimento);
CREATE INDEX IF NOT EXISTS idx_historical_characters_data_morte ON historical_characters(data_morte) WHERE data_morte IS NOT NULL;

-- 3. Registro idempotente do trigger para atualização de updated_at antes de qualquer update
DROP TRIGGER IF EXISTS set_timestamp_historical_characters ON historical_characters;
CREATE TRIGGER set_timestamp_historical_characters
BEFORE UPDATE ON historical_characters
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- 4. Ativação do Row Level Security (RLS) para proteção e conformidade
ALTER TABLE historical_characters ENABLE ROW LEVEL SECURITY;

-- 5. Definição das Políticas de Acesso Seguro (RLS) de forma resiliente e idempotente
-- SELECT: Acesso público geral para visualização (usuários anônimos e autenticados)
DROP POLICY IF EXISTS policy_historical_characters_select_public ON historical_characters;
CREATE POLICY policy_historical_characters_select_public
ON historical_characters
FOR SELECT
USING (true);

-- INSERT: Permitido somente para usuários autenticados (Editores e Administradores)
DROP POLICY IF EXISTS policy_historical_characters_insert_authenticated ON historical_characters;
CREATE POLICY policy_historical_characters_insert_authenticated
ON historical_characters
FOR INSERT
TO authenticated
WITH CHECK (true);

-- UPDATE: Permitido somente para usuários autenticados (Editores e Administradores)
DROP POLICY IF EXISTS policy_historical_characters_update_authenticated ON historical_characters;
CREATE POLICY policy_historical_characters_update_authenticated
ON historical_characters
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- DELETE: Permitido somente para administradores autenticados
DROP POLICY IF EXISTS policy_historical_characters_delete_authenticated ON historical_characters;
CREATE POLICY policy_historical_characters_delete_authenticated
ON historical_characters
FOR DELETE
TO authenticated
USING (true);

-- 6. Documentação rica do esquema físico através de comentários SQL estruturados
COMMENT ON TABLE historical_characters IS 'Tabela que define os Personagens Históricos do ecossistema CHRONOS, servindo de base para todos os perfis e conexões biográficas.';

COMMENT ON COLUMN historical_characters.id IS 'Identificador único universal (UUID) gerado nativamente pelo PostgreSQL.';
COMMENT ON COLUMN historical_characters.slug IS 'Slug textual único usado para rotas amigáveis na web e buscas indexadas (ex: julio-cesar).';
COMMENT ON COLUMN historical_characters.nome IS 'Nome completo e oficial pelo qual o personagem histórico é conhecido em português.';
COMMENT ON COLUMN historical_characters.nome_original IS 'Nome do personagem histórico grafado em seu idioma nativo ou de origem original da época.';
COMMENT ON COLUMN historical_characters.nome_alternativo IS 'Outros nomes conhecidos, apelidos ou pseudônimos documentados historicamente.';
COMMENT ON COLUMN historical_characters.titulo IS 'Título oficial de nobreza, honraria, governança ou acadêmico detido pelo personagem.';
COMMENT ON COLUMN historical_characters.epiteto IS 'Epíteto, cognome ou alcunha célebre pela qual o personagem é lembrado (ex: O Grande).';
COMMENT ON COLUMN historical_characters.descricao IS 'Biografia detalhada com profundidade histórica sobre a trajetória, contribuições e legado do personagem.';
COMMENT ON COLUMN historical_characters.descricao_resumida IS 'Resumo conciso de um parágrafo para cartões de listagem rápida e tooltips de interface.';
COMMENT ON COLUMN historical_characters.data_nascimento IS 'Data de nascimento do personagem histórico registrada em formato estruturado.';
COMMENT ON COLUMN historical_characters.data_morte IS 'Data de morte do personagem histórica registrada em formato estruturado, nulo se desconhecido ou para figuras sem registro.';
COMMENT ON COLUMN historical_characters.era_id IS 'Chave estrangeira (FK) referenciando a Era histórica na qual este personagem viveu ou teve maior relevância.';
COMMENT ON COLUMN historical_characters.local_nascimento_id IS 'Identificador estruturado para associação futura com a tabela de localizações de nascimento.';
COMMENT ON COLUMN historical_characters.local_morte_id IS 'Identificador estruturado para associação futura com a tabela de localizações de falecimento.';
COMMENT ON COLUMN historical_characters.sexo IS 'Classificação de sexo biológico ou de gênero para segmentação analítica (masculino, feminino, outro).';
COMMENT ON COLUMN historical_characters.ocupacao_principal IS 'Profissão, cargo ou papel de relevância primordial exercido pelo personagem na história.';
COMMENT ON COLUMN historical_characters.civilizacao_principal_id IS 'Identificador estruturado para associação futura com a tabela de civilizações.';
COMMENT ON COLUMN historical_characters.imagem_principal IS 'Caminho absoluto ou URL do recurso de imagem do retrato principal ou busto do personagem.';
COMMENT ON COLUMN historical_characters.cor_identificacao IS 'Código de cor em formato hexadecimal (#RRGGBB) para identidade visual e elementos dinâmicos do personagem na interface.';
COMMENT ON COLUMN historical_characters.publication_status IS 'Estado editorial de publicação para controle de moderação (draft, review, published, archived).';
COMMENT ON COLUMN historical_characters.ativo IS 'Indicador lógico de controle de ativação na interface pública sem destruição do registro.';
COMMENT ON COLUMN historical_characters.created_at IS 'Data e hora do registro inicial no banco de dados.';
COMMENT ON COLUMN historical_characters.updated_at IS 'Data e hora da última modificação estrutural ou textual nos dados deste registro.';
