-- Migration: Gamification, Achievements & Challenges
-- Description: Tabelas de perfil, XP, conquistas, títulos, desafios, resumo semanal e ranking.

BEGIN;

-- 1. Perfis de usuário com dados gamificados
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,
    display_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    title_id UUID,
    total_xp INTEGER NOT NULL DEFAULT 0,
    current_level INTEGER NOT NULL DEFAULT 1,
    streak_days INTEGER NOT NULL DEFAULT 0,
    last_study_date DATE,
    joined_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);

-- 2. Catálogo de conquistas (badges)
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(100) NOT NULL DEFAULT 'emoji_events',
    category VARCHAR(50) NOT NULL CHECK (category IN ('study','collection','exploration','streak','special')),
    criteria_type VARCHAR(50) NOT NULL CHECK (criteria_type IN ('first_study','first_collection','view_count','complete_count','streak_days','study_minutes','search_count','custom')),
    criteria_value INTEGER NOT NULL DEFAULT 1,
    xp_reward INTEGER NOT NULL DEFAULT 0,
    title_unlocked_slug VARCHAR(255),
    special_collection_slug VARCHAR(255)
);

CREATE INDEX IF NOT EXISTS idx_achievements_category ON achievements(category);

-- 3. Conquistas desbloqueadas por usuário
CREATE TABLE IF NOT EXISTS user_achievements (
    user_id UUID NOT NULL,
    achievement_id UUID NOT NULL,
    progress INTEGER NOT NULL DEFAULT 0,
    unlocked_at TIMESTAMPTZ,
    PRIMARY KEY (user_id, achievement_id),
    CONSTRAINT fk_user_achievements_achievement FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);

-- 4. Títulos de historiador
CREATE TABLE IF NOT EXISTS titles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    min_level INTEGER NOT NULL DEFAULT 1,
    min_xp INTEGER NOT NULL DEFAULT 0,
    icon VARCHAR(100) NOT NULL DEFAULT 'workspace_premium'
);

CREATE INDEX IF NOT EXISTS idx_titles_min_level ON titles(min_level);

-- 5. Títulos desbloqueados por usuário
CREATE TABLE IF NOT EXISTS user_titles (
    user_id UUID NOT NULL,
    title_id UUID NOT NULL,
    unlocked_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    PRIMARY KEY (user_id, title_id),
    CONSTRAINT fk_user_titles_title FOREIGN KEY (title_id) REFERENCES titles(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_user_titles_user_id ON user_titles(user_id);

-- 6. Eventos de XP
CREATE TABLE IF NOT EXISTS xp_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    amount INTEGER NOT NULL CHECK (amount > 0),
    source VARCHAR(50) NOT NULL CHECK (source IN ('view_content','complete_study','complete_collection','daily_goal','challenge','achievement','streak','custom')),
    reference_id UUID,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_xp_events_user_id ON xp_events(user_id);
CREATE INDEX IF NOT EXISTS idx_xp_events_created_at ON xp_events(user_id, created_at);

-- 7. Desafios diários/semanais/mensais
CREATE TABLE IF NOT EXISTS challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('daily','weekly','monthly')),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    criteria_type VARCHAR(50) NOT NULL CHECK (criteria_type IN ('study_minutes','view_count','complete_count','search_count','create_collection','custom')),
    target_value INTEGER NOT NULL DEFAULT 1,
    current_value INTEGER NOT NULL DEFAULT 0,
    reward_xp INTEGER NOT NULL DEFAULT 0,
    completed BOOLEAN NOT NULL DEFAULT false,
    completed_at TIMESTAMPTZ,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_challenges_user_id ON challenges(user_id);
CREATE INDEX IF NOT EXISTS idx_challenges_active ON challenges(user_id, ends_at) WHERE completed = false;

-- 8. Resumos semanais
CREATE TABLE IF NOT EXISTS weekly_summaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    total_xp INTEGER NOT NULL DEFAULT 0,
    hours_studied INTEGER NOT NULL DEFAULT 0,
    achievements_count INTEGER NOT NULL DEFAULT 0,
    collections_started INTEGER NOT NULL DEFAULT 0,
    collections_completed INTEGER NOT NULL DEFAULT 0,
    top_categories JSONB DEFAULT '[]' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    UNIQUE(user_id, week_start)
);

CREATE INDEX IF NOT EXISTS idx_weekly_summaries_user_id ON weekly_summaries(user_id);

-- 9. Preparação para ranking
CREATE TABLE IF NOT EXISTS ranking_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    period VARCHAR(50) NOT NULL CHECK (period IN ('daily','weekly','monthly','all_time')),
    total_xp INTEGER NOT NULL DEFAULT 0,
    rank INTEGER,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    UNIQUE(user_id, period)
);

CREATE INDEX IF NOT EXISTS idx_ranking_entries_period ON ranking_entries(period, total_xp DESC);

-- 10. RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_titles ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE ranking_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE titles ENABLE ROW LEVEL SECURITY;

-- Políticas de isolamento por usuário
DROP POLICY IF EXISTS policy_user_profiles_user_isolation ON user_profiles;
CREATE POLICY policy_user_profiles_user_isolation ON user_profiles
FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS policy_user_achievements_user_isolation ON user_achievements;
CREATE POLICY policy_user_achievements_user_isolation ON user_achievements
FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS policy_user_titles_user_isolation ON user_titles;
CREATE POLICY policy_user_titles_user_isolation ON user_titles
FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS policy_xp_events_user_isolation ON xp_events;
CREATE POLICY policy_xp_events_user_isolation ON xp_events
FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS policy_challenges_user_isolation ON challenges;
CREATE POLICY policy_challenges_user_isolation ON challenges
FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS policy_weekly_summaries_user_isolation ON weekly_summaries;
CREATE POLICY policy_weekly_summaries_user_isolation ON weekly_summaries
FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS policy_ranking_entries_user_isolation ON ranking_entries;
CREATE POLICY policy_ranking_entries_user_isolation ON ranking_entries
FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Catálogos públicos de leitura
DROP POLICY IF EXISTS policy_achievements_public_read ON achievements;
CREATE POLICY policy_achievements_public_read ON achievements FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS policy_titles_public_read ON titles;
CREATE POLICY policy_titles_public_read ON titles FOR SELECT TO authenticated USING (true);

-- 11. Seed de conquistas iniciais
INSERT INTO achievements (slug, name, description, icon, category, criteria_type, criteria_value, xp_reward, title_unlocked_slug, special_collection_slug)
VALUES
('first_study', 'Primeiro Estudo', 'Inicie seu primeiro estudo em qualquer conteúdo.', 'menu_book', 'study', 'first_study', 1, 10, NULL, NULL),
('first_collection', 'Primeira Coleção', 'Crie sua primeira coleção de estudos.', 'collections_bookmark', 'collection', 'first_collection', 1, 20, NULL, NULL),
('expert_rome', 'Especialista em Roma', 'Complete 10 estudos sobre Roma Antiga.', 'account_balance', 'special', 'complete_count', 10, 100, NULL, 'a-ascensao-do-imperio-romano'),
('expert_egypt', 'Especialista em Egito', 'Complete 10 estudos sobre Egito Antigo.', 'temple_buddhist', 'special', 'complete_count', 10, 100, NULL, NULL),
('characters_100', '100 Personagens', 'Estude 100 personagens históricos.', 'groups', 'exploration', 'complete_count', 100, 250, NULL, NULL),
('events_100', '100 Eventos', 'Estude 100 eventos históricos.', 'event_note', 'exploration', 'complete_count', 100, 250, NULL, NULL),
('week_streak', 'Primeira Semana', 'Mantenha uma sequência de 7 dias de estudos.', 'local_fire_department', 'streak', 'streak_days', 7, 50, NULL, NULL),
('month_streak', '30 Dias Consecutivos', 'Mantenha uma sequência de 30 dias de estudos.', 'whatshot', 'streak', 'streak_days', 30, 150, NULL, NULL),
('historian', 'Historiador', 'Alcance o nível 10.', 'workspace_premium', 'study', 'custom', 10, 500, 'historian', NULL),
('explorer', 'Explorador', 'Visualize 50 conteúdos diferentes.', 'travel_explore', 'exploration', 'view_count', 50, 75, NULL, NULL),
('researcher', 'Pesquisador', 'Realize 50 pesquisas.', 'search', 'exploration', 'search_count', 50, 75, NULL, NULL)
ON CONFLICT (slug) DO NOTHING;

-- 12. Seed de títulos
INSERT INTO titles (slug, name, description, min_level, min_xp, icon)
VALUES
('apprentice', 'Aprendiz', 'Início da jornada histórica.', 1, 0, 'school'),
('researcher', 'Pesquisador', 'Você já explora o passado com curiosidade.', 3, 250, 'search'),
('chronicler', 'Cronista', 'Registra e organiza conhecimento.', 5, 500, 'edit_note'),
('historian', 'Historiador', 'Reconhecido como estudioso da história.', 10, 1000, 'menu_book'),
('archivist', 'Arquivista', 'Guarda segredos de civilizações.', 15, 2500, 'inventory_2'),
('sage', 'Sábio', 'Sua sabedoria atravessa eras.', 20, 5000, 'psychology'),
('guardian', 'Guardião da História', 'Protetor lendário do conhecimento.', 30, 10000, 'shield')
ON CONFLICT (slug) DO NOTHING;

COMMIT;
