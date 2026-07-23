-- CHRONOS Sprint 8.2.0 - Learning Engine Schema
-- Sistema de aprendizagem: histórico, revisão espaçada, quiz, metas, conquistas, gamificação

-- ============================================================
-- Limpar tabelas parciais de execuções anteriores
-- ============================================================
DROP TABLE IF EXISTS quiz_answers CASCADE;
DROP TABLE IF EXISTS quiz_questions CASCADE;
DROP TABLE IF EXISTS study_history CASCADE;
DROP TABLE IF EXISTS study_progress CASCADE;
DROP TABLE IF EXISTS study_reviews CASCADE;
DROP TABLE IF EXISTS study_goals CASCADE;
DROP TABLE IF EXISTS achievements CASCADE;
DROP TABLE IF EXISTS user_study_stats CASCADE;
DROP TABLE IF EXISTS study_challenges CASCADE;

-- ============================================================
-- Histórico de atividades de estudo
-- ============================================================
CREATE TABLE IF NOT EXISTS study_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  entity_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_name TEXT NOT NULL DEFAULT '',
  activity_type TEXT NOT NULL DEFAULT 'view' CHECK (activity_type IN ('view', 'read', 'quiz', 'review', 'bookmark', 'share', 'askAI')),
  duration_seconds INT DEFAULT 0,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Progresso do usuário por entidade
-- ============================================================
CREATE TABLE IF NOT EXISTS study_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  entity_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_name TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'notStarted' CHECK (status IN ('notStarted', 'inProgress', 'studied', 'reviewLater', 'veryImportant', 'difficult', 'mastered')),
  total_read_time_seconds INT DEFAULT 0,
  view_count INT DEFAULT 0,
  first_access TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_access TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_review TIMESTAMPTZ,
  review_count INT DEFAULT 0,
  mastery_level DOUBLE PRECISION DEFAULT 0.0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, entity_id)
);

-- ============================================================
-- Revisões espaçadas (Spaced Repetition)
-- ============================================================
CREATE TABLE IF NOT EXISTS study_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  entity_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_name TEXT NOT NULL DEFAULT '',
  scheduled_for TIMESTAMPTZ NOT NULL,
  interval_days INT NOT NULL DEFAULT 1,
  repetition INT DEFAULT 0,
  ease_factor DOUBLE PRECISION DEFAULT 2.5,
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Perguntas de quiz
-- ============================================================
CREATE TABLE IF NOT EXISTS quiz_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  question TEXT NOT NULL,
  options JSONB NOT NULL DEFAULT '[]'::jsonb,
  correct_index INT NOT NULL DEFAULT 0,
  explanation TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Respostas do usuário a quizzes
-- ============================================================
CREATE TABLE IF NOT EXISTS quiz_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  question_id UUID NOT NULL REFERENCES quiz_questions(id),
  entity_id TEXT NOT NULL,
  selected_index INT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  response_time_ms INT DEFAULT 0,
  answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Metas de estudo
-- ============================================================
CREATE TABLE IF NOT EXISTS study_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  type TEXT NOT NULL DEFAULT 'dailyMinutes' CHECK (type IN ('dailyMinutes', 'readCharacters', 'readEvents', 'readCivilizations', 'completeCivilization', 'quizScore', 'consecutiveDays', 'totalContents')),
  target_value INT NOT NULL,
  current_value INT DEFAULT 0,
  deadline TIMESTAMPTZ,
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Conquistas / Badges
-- ============================================================
CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  code TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  icon TEXT DEFAULT '🏆',
  tier TEXT NOT NULL DEFAULT 'bronze' CHECK (tier IN ('bronze', 'silver', 'gold', 'platinum', 'diamond')),
  required_value INT NOT NULL DEFAULT 1,
  current_value INT DEFAULT 0,
  unlocked BOOLEAN DEFAULT FALSE,
  unlocked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, code)
);

-- ============================================================
-- Estatísticas do usuário
-- ============================================================
CREATE TABLE IF NOT EXISTS user_study_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL UNIQUE DEFAULT 'local_user',
  total_study_time_seconds INT DEFAULT 0,
  total_contents_viewed INT DEFAULT 0,
  total_characters_studied INT DEFAULT 0,
  total_events_studied INT DEFAULT 0,
  total_civilizations_studied INT DEFAULT 0,
  total_artifacts_studied INT DEFAULT 0,
  total_sources_consulted INT DEFAULT 0,
  total_quiz_answered INT DEFAULT 0,
  total_quiz_correct INT DEFAULT 0,
  consecutive_days INT DEFAULT 0,
  longest_streak INT DEFAULT 0,
  total_xp INT DEFAULT 0,
  level TEXT DEFAULT 'novice',
  hourly_distribution JSONB DEFAULT '{}'::jsonb,
  weekly_progress JSONB DEFAULT '{}'::jsonb,
  monthly_progress JSONB DEFAULT '{}'::jsonb,
  last_study_date TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Desafios (diários e semanais)
-- ============================================================
CREATE TABLE IF NOT EXISTS study_challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL DEFAULT 'local_user',
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  type TEXT NOT NULL DEFAULT 'daily' CHECK (type IN ('daily', 'weekly')),
  target_value INT NOT NULL,
  current_value INT DEFAULT 0,
  xp_reward INT DEFAULT 50,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Garantir colunas existem (segurança se tabela já existia parcial)
-- ============================================================
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS user_id TEXT NOT NULL DEFAULT 'local_user';
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS entity_id TEXT NOT NULL DEFAULT '';
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS entity_type TEXT NOT NULL DEFAULT '';
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS entity_name TEXT NOT NULL DEFAULT '';
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'notStarted';
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS total_read_time_seconds INT DEFAULT 0;
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS view_count INT DEFAULT 0;
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS first_access TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS last_access TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS last_review TIMESTAMPTZ;
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS review_count INT DEFAULT 0;
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS mastery_level DOUBLE PRECISION DEFAULT 0.0;
ALTER TABLE study_progress ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE study_history ADD COLUMN IF NOT EXISTS entity_name TEXT NOT NULL DEFAULT '';
ALTER TABLE study_history ADD COLUMN IF NOT EXISTS activity_type TEXT NOT NULL DEFAULT 'view';
ALTER TABLE study_history ADD COLUMN IF NOT EXISTS duration_seconds INT DEFAULT 0;
ALTER TABLE study_history ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;
ALTER TABLE study_history ADD COLUMN IF NOT EXISTS metadata JSONB;

-- ============================================================
-- Índices para performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_study_history_user ON study_history(user_id);
CREATE INDEX IF NOT EXISTS idx_study_history_entity ON study_history(entity_id);
CREATE INDEX IF NOT EXISTS idx_study_history_started ON study_history(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_study_progress_user ON study_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_study_progress_last ON study_progress(last_access DESC);
CREATE INDEX IF NOT EXISTS idx_study_reviews_user ON study_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_study_reviews_scheduled ON study_reviews(scheduled_for);
CREATE INDEX IF NOT EXISTS idx_study_reviews_pending ON study_reviews(user_id, completed, scheduled_for);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_entity ON quiz_questions(entity_id);
CREATE INDEX IF NOT EXISTS idx_quiz_answers_user ON quiz_answers(user_id);
CREATE INDEX IF NOT EXISTS idx_study_goals_user ON study_goals(user_id);
CREATE INDEX IF NOT EXISTS idx_achievements_user ON achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_study_challenges_user ON study_challenges(user_id);

-- ============================================================
-- RLS + Policies
-- ============================================================
ALTER TABLE study_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_study_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_challenges ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'study_history_read') THEN
    CREATE POLICY "study_history_read" ON study_history FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'study_history_write') THEN
    CREATE POLICY "study_history_write" ON study_history FOR INSERT WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'study_progress_all') THEN
    CREATE POLICY "study_progress_all" ON study_progress FOR ALL USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'study_reviews_all') THEN
    CREATE POLICY "study_reviews_all" ON study_reviews FOR ALL USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'quiz_questions_read') THEN
    CREATE POLICY "quiz_questions_read" ON quiz_questions FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'quiz_answers_all') THEN
    CREATE POLICY "quiz_answers_all" ON quiz_answers FOR ALL USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'study_goals_all') THEN
    CREATE POLICY "study_goals_all" ON study_goals FOR ALL USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'achievements_all') THEN
    CREATE POLICY "achievements_all" ON achievements FOR ALL USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'user_study_stats_all') THEN
    CREATE POLICY "user_study_stats_all" ON user_study_stats FOR ALL USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'study_challenges_all') THEN
    CREATE POLICY "study_challenges_all" ON study_challenges FOR ALL USING (true);
  END IF;
END $$;
