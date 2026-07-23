-- CHRONOS Sprint 8.3.0 - Learning Paths Schema
-- Trilhas de aprendizagem: trilhas, módulos, conteúdos, progresso, certificados

-- ============================================================
-- Limpar tabelas de execuções anteriores
-- ============================================================
DROP TABLE IF EXISTS path_certificates CASCADE;
DROP TABLE IF EXISTS module_progress CASCADE;
DROP TABLE IF EXISTS path_progress CASCADE;
DROP TABLE IF EXISTS path_contents CASCADE;
DROP TABLE IF EXISTS path_modules CASCADE;
DROP TABLE IF EXISTS learning_paths CASCADE;

-- ============================================================
-- Trilhas de Aprendizagem
-- ============================================================
CREATE TABLE learning_paths (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  image_url TEXT,
  category TEXT NOT NULL DEFAULT 'antiquity',
  difficulty TEXT NOT NULL DEFAULT 'beginner' CHECK (difficulty IN ('beginner', 'intermediate', 'advanced', 'expert')),
  estimated_minutes INT DEFAULT 60,
  total_modules INT DEFAULT 0,
  total_contents INT DEFAULT 0,
  xp_reward INT DEFAULT 100,
  badge_code TEXT,
  author_id TEXT,
  author_name TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  locale TEXT DEFAULT 'pt_BR',
  "order" INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Módulos de uma trilha
-- ============================================================
CREATE TABLE path_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  path_id UUID NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  "order" INT NOT NULL DEFAULT 0,
  total_contents INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Conteúdos de um módulo
-- ============================================================
CREATE TABLE path_contents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID NOT NULL REFERENCES path_modules(id) ON DELETE CASCADE,
  entity_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_name TEXT NOT NULL DEFAULT '',
  content_type TEXT NOT NULL DEFAULT 'text' CHECK (content_type IN ('text', 'video', 'audio', 'quiz', 'optional')),
  "order" INT NOT NULL DEFAULT 0,
  is_optional BOOLEAN DEFAULT FALSE,
  is_prerequisite BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Progresso do usuário em uma trilha
-- ============================================================
CREATE TABLE path_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  path_id UUID NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
  path_name TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'notStarted' CHECK (status IN ('notStarted', 'inProgress', 'completed')),
  completed_modules INT DEFAULT 0,
  completed_contents INT DEFAULT 0,
  total_modules INT DEFAULT 0,
  total_contents INT DEFAULT 0,
  total_time_seconds INT DEFAULT 0,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  last_access_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, path_id)
);

-- ============================================================
-- Progresso do usuário em um módulo
-- ============================================================
CREATE TABLE module_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  module_id UUID NOT NULL REFERENCES path_modules(id) ON DELETE CASCADE,
  path_id UUID NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'locked' CHECK (status IN ('locked', 'unlocked', 'inProgress', 'completed')),
  completed_contents INT DEFAULT 0,
  total_contents INT DEFAULT 0,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, module_id)
);

-- ============================================================
-- Certificados
-- ============================================================
CREATE TABLE path_certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  user_name TEXT NOT NULL DEFAULT '',
  path_id UUID NOT NULL REFERENCES learning_paths(id) ON DELETE CASCADE,
  path_name TEXT NOT NULL DEFAULT '',
  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  total_time_seconds INT DEFAULT 0,
  total_contents_completed INT DEFAULT 0,
  xp_earned INT DEFAULT 0,
  pdf_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Índices
-- ============================================================
CREATE INDEX idx_learning_paths_category ON learning_paths(category);
CREATE INDEX idx_learning_paths_difficulty ON learning_paths(difficulty);
CREATE INDEX idx_learning_paths_order ON learning_paths("order");
CREATE INDEX idx_path_modules_path ON path_modules(path_id, "order");
CREATE INDEX idx_path_contents_module ON path_contents(module_id, "order");
CREATE INDEX idx_path_contents_entity ON path_contents(entity_id);
CREATE INDEX idx_path_progress_user ON path_progress(user_id);
CREATE INDEX idx_path_progress_path ON path_progress(path_id);
CREATE INDEX idx_module_progress_user ON module_progress(user_id);
CREATE INDEX idx_module_progress_module ON module_progress(module_id);
CREATE INDEX idx_path_certificates_user ON path_certificates(user_id);

-- ============================================================
-- RLS + Policies
-- ============================================================
ALTER TABLE learning_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE path_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE path_contents ENABLE ROW LEVEL SECURITY;
ALTER TABLE path_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE module_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE path_certificates ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "learning_paths_read" ON learning_paths FOR SELECT USING (true);
  CREATE POLICY "path_modules_read" ON path_modules FOR SELECT USING (true);
  CREATE POLICY "path_contents_read" ON path_contents FOR SELECT USING (true);
  CREATE POLICY "path_progress_all" ON path_progress FOR ALL USING (true);
  CREATE POLICY "module_progress_all" ON module_progress FOR ALL USING (true);
  CREATE POLICY "path_certificates_all" ON path_certificates FOR ALL USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
