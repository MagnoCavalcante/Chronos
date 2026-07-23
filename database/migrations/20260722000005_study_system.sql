-- Migration: Study System, Collections & Learning Progress
-- Description: Cria tabelas de coleções, progresso, notas, tags, metas, planos e revisão.

BEGIN;

-- 1. Coleções personalizadas do usuário
CREATE TABLE IF NOT EXISTS collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    slug VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    cover_url TEXT,
    is_public BOOLEAN NOT NULL DEFAULT false,
    ativo BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    UNIQUE(user_id, slug)
);

CREATE INDEX IF NOT EXISTS idx_collections_user_id ON collections(user_id);
CREATE INDEX IF NOT EXISTS idx_collections_ativo ON collections(ativo);

-- 2. Itens de coleções (referência polimórfica a entidades)
CREATE TABLE IF NOT EXISTS collection_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    order_index INTEGER NOT NULL DEFAULT 0,
    notes TEXT,
    added_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    UNIQUE(collection_id, entity_type, entity_id)
);

CREATE INDEX IF NOT EXISTS idx_collection_items_collection_id ON collection_items(collection_id);
CREATE INDEX IF NOT EXISTS idx_collection_items_entity ON collection_items(entity_type, entity_id);

-- 3. Progresso individual do usuário por entidade
CREATE TABLE IF NOT EXISTS study_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'not_started' CHECK (status IN ('not_started','in_study','completed','review')),
    progress_percent INTEGER NOT NULL DEFAULT 0 CHECK (progress_percent BETWEEN 0 AND 100),
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    total_study_time_seconds INTEGER NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    UNIQUE(user_id, entity_type, entity_id)
);

CREATE INDEX IF NOT EXISTS idx_study_progress_user_id ON study_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_study_progress_entity ON study_progress(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_study_progress_status ON study_progress(status);

-- 4. Notas pessoais do usuário por entidade
CREATE TABLE IF NOT EXISTS notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    content TEXT,
    summary TEXT,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    UNIQUE(user_id, entity_type, entity_id)
);

CREATE INDEX IF NOT EXISTS idx_notes_user_id ON notes(user_id);

-- 5. Marcações em trechos
CREATE TABLE IF NOT EXISTS highlights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    selected_text TEXT NOT NULL,
    note TEXT,
    color VARCHAR(7) DEFAULT '#FFD700',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_highlights_user_entity ON highlights(user_id, entity_type, entity_id);

-- 6. Tags pessoais
CREATE TABLE IF NOT EXISTS tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7) DEFAULT '#888888',
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    UNIQUE(user_id, name)
);

CREATE INDEX IF NOT EXISTS idx_tags_user_id ON tags(user_id);

-- 7. Ligação coleção ↔ tag
CREATE TABLE IF NOT EXISTS collection_tags (
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (collection_id, tag_id)
);

-- 8. Metas de estudo
CREATE TABLE IF NOT EXISTS study_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    target_type VARCHAR(50) NOT NULL CHECK (target_type IN ('time_minutes','items_count','collections_completed','streak_days')),
    target_value INTEGER NOT NULL,
    current_value INTEGER NOT NULL DEFAULT 0,
    deadline DATE,
    completed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_study_goals_user_id ON study_goals(user_id);

-- 9. Planos de estudo cronológicos
CREATE TABLE IF NOT EXISTS study_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_study_plans_user_id ON study_plans(user_id);

-- 10. Itens de plano de estudo
CREATE TABLE IF NOT EXISTS study_plan_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID NOT NULL REFERENCES study_plans(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    completed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_study_plan_items_plan_id ON study_plan_items(plan_id);

-- 11. Itens marcados para revisão futura
CREATE TABLE IF NOT EXISTS review_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    review_date DATE NOT NULL,
    interval_days INTEGER NOT NULL DEFAULT 1,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_review_items_user_date ON review_items(user_id, review_date);
CREATE INDEX IF NOT EXISTS idx_review_items_user_entity ON review_items(user_id, entity_type, entity_id);

-- 12. Estatísticas do usuário
CREATE TABLE IF NOT EXISTS user_stats (
    user_id UUID PRIMARY KEY,
    total_study_time_seconds INTEGER NOT NULL DEFAULT 0,
    items_studied INTEGER NOT NULL DEFAULT 0,
    collections_completed INTEGER NOT NULL DEFAULT 0,
    streak_days INTEGER NOT NULL DEFAULT 0,
    last_study_date DATE,
    weekly_progress JSONB DEFAULT '{}',
    monthly_progress JSONB DEFAULT '{}',
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- 13. Sessões de estudo
CREATE TABLE IF NOT EXISTS study_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    duration_seconds INTEGER DEFAULT 0,
    entity_type VARCHAR(50),
    entity_id UUID
);

CREATE INDEX IF NOT EXISTS idx_study_sessions_user_id ON study_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_study_sessions_entity ON study_sessions(entity_type, entity_id);

-- 14. Ativar RLS em todas as tabelas de usuário
ALTER TABLE collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE collection_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE highlights ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE collection_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_plan_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_sessions ENABLE ROW LEVEL SECURITY;

-- 15. Políticas: cada usuário acessa apenas seus próprios dados
DO $$
DECLARE
    tables TEXT[] := ARRAY[
        'collections','study_progress','notes','highlights',
        'tags','study_goals','study_plans',
        'review_items','user_stats','study_sessions'
    ];
    t TEXT;
BEGIN
    FOREACH t IN ARRAY tables LOOP
        EXECUTE format('DROP POLICY IF EXISTS policy_%s_user_isolation ON %s', t, t);
        EXECUTE format(
            'CREATE POLICY policy_%s_user_isolation ON %s FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid())',
            t, t
        );
    END LOOP;
END;
$$;

-- collection_items: isolamento via proprietário da coleção
DROP POLICY IF EXISTS policy_collection_items_user_isolation ON collection_items;
CREATE POLICY policy_collection_items_user_isolation ON collection_items
FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM collections WHERE id = collection_items.collection_id AND user_id = auth.uid()))
WITH CHECK (EXISTS (SELECT 1 FROM collections WHERE id = collection_items.collection_id AND user_id = auth.uid()));

-- study_plan_items: isolamento via proprietário do plano
DROP POLICY IF EXISTS policy_study_plan_items_user_isolation ON study_plan_items;
CREATE POLICY policy_study_plan_items_user_isolation ON study_plan_items
FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM study_plans WHERE id = study_plan_items.plan_id AND user_id = auth.uid()))
WITH CHECK (EXISTS (SELECT 1 FROM study_plans WHERE id = study_plan_items.plan_id AND user_id = auth.uid()));

-- collection_tags herda permissões implícitas via FK, mas cria política de segurança adicional
DROP POLICY IF EXISTS policy_collection_tags_user_isolation ON collection_tags;
CREATE POLICY policy_collection_tags_user_isolation ON collection_tags
FOR ALL TO authenticated
USING (
    collection_id IN (SELECT id FROM collections WHERE user_id = auth.uid())
    AND tag_id IN (SELECT id FROM tags WHERE user_id = auth.uid())
)
WITH CHECK (
    collection_id IN (SELECT id FROM collections WHERE user_id = auth.uid())
    AND tag_id IN (SELECT id FROM tags WHERE user_id = auth.uid())
);

COMMIT;
