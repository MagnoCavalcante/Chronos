-- CHRONOS Sprint 8.5.0 - AI Teacher Schema
-- Sessões de estudo guiadas e memória do tutor

-- ============================================================
-- Limpar tabelas de execuções anteriores
-- ============================================================
DROP TABLE IF EXISTS tutor_memory CASCADE;
DROP TABLE IF EXISTS tutor_sessions CASCADE;

-- ============================================================
-- Sessões de Estudo Guiadas
-- ============================================================
CREATE TABLE tutor_sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT 'local_user',
  topic TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed', 'abandoned')),
  steps JSONB DEFAULT '[]',
  level TEXT DEFAULT 'intermediate' CHECK (level IN ('basic', 'intermediate', 'advanced', 'academic')),
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Memória do Tutor
-- ============================================================
CREATE TABLE tutor_memory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  entity_id TEXT NOT NULL DEFAULT '',
  entity_name TEXT NOT NULL DEFAULT '',
  type TEXT NOT NULL DEFAULT 'doubt' CHECK (type IN ('doubt', 'difficulty', 'mastered', 'progress', 'preference')),
  content TEXT NOT NULL DEFAULT '',
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Índices
-- ============================================================
CREATE INDEX idx_tutor_sessions_user ON tutor_sessions(user_id);
CREATE INDEX idx_tutor_sessions_status ON tutor_sessions(user_id, status);
CREATE INDEX idx_tutor_memory_user ON tutor_memory(user_id);
CREATE INDEX idx_tutor_memory_type ON tutor_memory(user_id, type);
CREATE INDEX idx_tutor_memory_entity ON tutor_memory(entity_id);

-- ============================================================
-- RLS + Policies
-- ============================================================
ALTER TABLE tutor_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE tutor_memory ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "tutor_sessions_all" ON tutor_sessions FOR ALL USING (true);
  CREATE POLICY "tutor_memory_all" ON tutor_memory FOR ALL USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
