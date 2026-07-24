-- CHRONOS Sprint 8.4.0 - Adaptive Learning Schema
-- Tutor inteligente, perfil de aprendizagem, recomendações, planos, relatórios

-- ============================================================
-- Limpar tabelas de execuções anteriores
-- ============================================================
DROP TABLE IF EXISTS adaptive_recommendations CASCADE;
DROP TABLE IF EXISTS learning_reports CASCADE;
DROP TABLE IF EXISTS study_plans CASCADE;
DROP TABLE IF EXISTS learner_profiles CASCADE;

-- ============================================================
-- Perfil de Aprendizagem (versionado)
-- ============================================================
CREATE TABLE learner_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  version INT NOT NULL DEFAULT 1,
  estimated_level TEXT NOT NULL DEFAULT 'beginner' CHECK (estimated_level IN ('beginner', 'intermediate', 'advanced')),
  mastered_topics JSONB DEFAULT '[]',
  difficult_topics JSONB DEFAULT '[]',
  favorite_topics JSONB DEFAULT '[]',
  avg_study_speed DOUBLE PRECISION DEFAULT 10.0,
  quiz_accuracy_rate DOUBLE PRECISION DEFAULT 0.0,
  avg_time_per_content DOUBLE PRECISION DEFAULT 600.0,
  format_preferences JSONB DEFAULT '["text"]',
  primary_objective TEXT DEFAULT 'curiosity' CHECK (primary_objective IN ('enem', 'vestibular', 'university', 'curiosity', 'professional')),
  available_minutes_per_day INT DEFAULT 30,
  topic_accuracy JSONB DEFAULT '{}',
  last_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, version)
);

-- ============================================================
-- Planos de Estudo
-- ============================================================
CREATE TABLE study_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  title TEXT NOT NULL DEFAULT '',
  objective TEXT DEFAULT 'curiosity',
  available_minutes_per_day INT DEFAULT 30,
  week_start TIMESTAMPTZ NOT NULL,
  week_end TIMESTAMPTZ NOT NULL,
  daily_plans JSONB DEFAULT '[]',
  target_xp INT DEFAULT 100,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Relatórios de Aprendizagem
-- ============================================================
CREATE TABLE learning_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  period TEXT NOT NULL DEFAULT 'weekly' CHECK (period IN ('weekly', 'monthly')),
  period_start TIMESTAMPTZ NOT NULL,
  period_end TIMESTAMPTZ NOT NULL,
  total_study_time_seconds INT DEFAULT 0,
  contents_completed INT DEFAULT 0,
  quiz_accuracy DOUBLE PRECISION DEFAULT 0.0,
  quiz_answered INT DEFAULT 0,
  mastered_topics JSONB DEFAULT '[]',
  topics_to_review JSONB DEFAULT '[]',
  topic_evolution JSONB DEFAULT '{}',
  recommendations JSONB DEFAULT '[]',
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Recomendações Adaptativas
-- ============================================================
CREATE TABLE adaptive_recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  entity_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_name TEXT NOT NULL DEFAULT '',
  type TEXT NOT NULL DEFAULT 'newContent',
  reason TEXT NOT NULL DEFAULT '',
  score DOUBLE PRECISION DEFAULT 0.0,
  priority INT DEFAULT 0,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  dismissed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Índices
-- ============================================================
CREATE INDEX idx_learner_profiles_user ON learner_profiles(user_id);
CREATE INDEX idx_study_plans_user ON study_plans(user_id);
CREATE INDEX idx_study_plans_week ON study_plans(week_start, week_end);
CREATE INDEX idx_learning_reports_user ON learning_reports(user_id);
CREATE INDEX idx_learning_reports_period ON learning_reports(period_start, period_end);
CREATE INDEX idx_adaptive_rec_user ON adaptive_recommendations(user_id, dismissed);
CREATE INDEX idx_adaptive_rec_priority ON adaptive_recommendations(user_id, priority DESC);

-- ============================================================
-- RLS + Policies
-- ============================================================
ALTER TABLE learner_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE adaptive_recommendations ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "learner_profiles_all" ON learner_profiles FOR ALL USING (true);
  CREATE POLICY "study_plans_all" ON study_plans FOR ALL USING (true);
  CREATE POLICY "learning_reports_all" ON learning_reports FOR ALL USING (true);
  CREATE POLICY "adaptive_rec_all" ON adaptive_recommendations FOR ALL USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
