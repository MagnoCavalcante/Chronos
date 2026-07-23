-- CHRONOS Knowledge Base Schema
-- Sprint 8.0.0 - Base de Conhecimento Histórica

-- Tabela principal de entries de conhecimento
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

-- Tabela de fontes/referências
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

-- Tabela de debates históricos
CREATE TABLE IF NOT EXISTS knowledge_debates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id TEXT NOT NULL,
  titulo TEXT NOT NULL,
  descricao TEXT NOT NULL,
  posicoes JSONB DEFAULT '[]'::jsonb,
  status_atual TEXT DEFAULT 'disputed' CHECK (status_atual IN ('fact', 'theory', 'hypothesis', 'disputed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de curiosidades
CREATE TABLE IF NOT EXISTS knowledge_curiosities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id TEXT NOT NULL,
  titulo TEXT NOT NULL,
  conteudo TEXT NOT NULL,
  tipo TEXT DEFAULT 'curiosidade' CHECK (tipo IN ('curiosidade', 'mito', 'equivoco')),
  confiabilidade TEXT DEFAULT 'fact' CHECK (confiabilidade IN ('fact', 'theory', 'hypothesis', 'disputed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de relações (grafo de conhecimento)
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

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_knowledge_entries_entity ON knowledge_entries(entity_id, entity_type);
CREATE INDEX IF NOT EXISTS idx_knowledge_entries_nome ON knowledge_entries(nome);
CREATE INDEX IF NOT EXISTS idx_knowledge_sources_entity ON knowledge_sources(entity_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_debates_entity ON knowledge_debates(entity_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_curiosities_entity ON knowledge_curiosities(entity_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_relations_source ON knowledge_relations(source_entity_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_relations_target ON knowledge_relations(target_id);

-- Row Level Security
ALTER TABLE knowledge_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_debates ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_curiosities ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_relations ENABLE ROW LEVEL SECURITY;

-- Policies de leitura pública
CREATE POLICY "knowledge_entries_read" ON knowledge_entries FOR SELECT USING (true);
CREATE POLICY "knowledge_sources_read" ON knowledge_sources FOR SELECT USING (true);
CREATE POLICY "knowledge_debates_read" ON knowledge_debates FOR SELECT USING (true);
CREATE POLICY "knowledge_curiosities_read" ON knowledge_curiosities FOR SELECT USING (true);
CREATE POLICY "knowledge_relations_read" ON knowledge_relations FOR SELECT USING (true);
