-- CHRONOS Sprint 8.1.0 - Knowledge Graph Enhancements
-- Suporta relações bidirecionais, busca reversa e navegação inteligente
-- NOTA: Requer que 001_knowledge_base_schema.sql já tenha sido aplicado.

-- ============================================================
-- Garantir que as tabelas base existem (segurança caso 001 não tenha rodado)
-- ============================================================
CREATE TABLE IF NOT EXISTS knowledge_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id TEXT NOT NULL,
  entity_type TEXT NOT NULL CHECK (entity_type IN ('character', 'event', 'civilization', 'artifact', 'location', 'era')),
  nome TEXT NOT NULL,
  nome_original TEXT,
  imagem_url TEXT,
  banner_url TEXT,
  periodo_historico TEXT,
  civilizacao TEXT,
  local_nascimento TEXT,
  local_morte TEXT,
  resumo TEXT NOT NULL,
  conteudo_completo TEXT,
  principais_feitos JSONB DEFAULT '[]'::jsonb,
  influencia_historica TEXT,
  consenso JSONB,
  linha_do_tempo JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(entity_id, entity_type)
);

CREATE TABLE IF NOT EXISTS knowledge_relations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_entity_id TEXT NOT NULL,
  target_id TEXT NOT NULL,
  target_type TEXT NOT NULL CHECK (target_type IN ('character', 'event', 'civilization', 'artifact', 'location', 'era')),
  target_name TEXT NOT NULL,
  relation_type TEXT NOT NULL,
  descricao TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS knowledge_sources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id TEXT NOT NULL,
  autor TEXT NOT NULL,
  titulo TEXT NOT NULL,
  livro TEXT,
  artigo TEXT,
  documento TEXT,
  capitulo TEXT,
  pagina TEXT,
  url TEXT,
  ano_publicacao INT,
  confiabilidade TEXT DEFAULT 'fact' CHECK (confiabilidade IN ('fact', 'theory', 'hypothesis', 'disputed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS knowledge_debates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id TEXT NOT NULL,
  titulo TEXT NOT NULL,
  descricao TEXT NOT NULL,
  posicoes JSONB DEFAULT '[]'::jsonb,
  status_atual TEXT DEFAULT 'disputed' CHECK (status_atual IN ('fact', 'theory', 'hypothesis', 'disputed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS knowledge_curiosities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id TEXT NOT NULL,
  titulo TEXT NOT NULL,
  conteudo TEXT NOT NULL,
  tipo TEXT DEFAULT 'curiosidade' CHECK (tipo IN ('curiosidade', 'mito', 'equivoco')),
  confiabilidade TEXT DEFAULT 'fact' CHECK (confiabilidade IN ('fact', 'theory', 'hypothesis', 'disputed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Enhancements: colunas para relações bidirecionais
-- ============================================================
ALTER TABLE knowledge_relations ADD COLUMN IF NOT EXISTS source_type TEXT DEFAULT 'character';
ALTER TABLE knowledge_relations ADD COLUMN IF NOT EXISTS source_name TEXT DEFAULT '';

-- ============================================================
-- Índices para performance do Knowledge Graph
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_knowledge_entries_entity ON knowledge_entries(entity_id, entity_type);
CREATE INDEX IF NOT EXISTS idx_knowledge_sources_entity ON knowledge_sources(entity_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_debates_entity ON knowledge_debates(entity_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_curiosities_entity ON knowledge_curiosities(entity_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_relations_source ON knowledge_relations(source_entity_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_relations_target ON knowledge_relations(target_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_relations_type ON knowledge_relations(relation_type);
CREATE INDEX IF NOT EXISTS idx_knowledge_relations_target_type ON knowledge_relations(target_type);

-- ============================================================
-- RLS + Policies (idempotente)
-- ============================================================
ALTER TABLE knowledge_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_debates ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_curiosities ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_relations ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'knowledge_entries_read') THEN
    CREATE POLICY "knowledge_entries_read" ON knowledge_entries FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'knowledge_sources_read') THEN
    CREATE POLICY "knowledge_sources_read" ON knowledge_sources FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'knowledge_debates_read') THEN
    CREATE POLICY "knowledge_debates_read" ON knowledge_debates FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'knowledge_curiosities_read') THEN
    CREATE POLICY "knowledge_curiosities_read" ON knowledge_curiosities FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'knowledge_relations_read') THEN
    CREATE POLICY "knowledge_relations_read" ON knowledge_relations FOR SELECT USING (true);
  END IF;
END $$;

-- ============================================================
-- Atualizar source_type e source_name nas relações existentes
-- ============================================================
UPDATE knowledge_relations kr
SET source_type = ke.entity_type,
    source_name = ke.nome
FROM knowledge_entries ke
WHERE kr.source_entity_id = ke.entity_id
  AND (kr.source_name IS NULL OR kr.source_name = '');
