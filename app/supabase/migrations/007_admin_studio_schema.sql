-- CHRONOS Sprint 9.4.0 - Admin Studio Schema
-- CMS especializado em História: conteúdo, editorial, versões, auditoria, mídia, usuários

-- ============================================================
-- Limpar tabelas de execuções anteriores
-- ============================================================
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS content_versions CASCADE;
DROP TABLE IF EXISTS editorial_flow CASCADE;
DROP TABLE IF EXISTS media_library CASCADE;
DROP TABLE IF EXISTS managed_contents CASCADE;
DROP TABLE IF EXISTS admin_users CASCADE;

-- ============================================================
-- Usuários Administrativos
-- ============================================================
CREATE TABLE admin_users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL DEFAULT '',
  email TEXT NOT NULL DEFAULT '',
  role TEXT NOT NULL DEFAULT 'freeUser'
    CHECK (role IN ('superAdmin','admin','editor','reviewer','translator','moderator','premiumUser','freeUser')),
  permissions JSONB DEFAULT '[]',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ
);

-- ============================================================
-- Conteúdo Gerenciável (wrapper genérico para todas as entidades)
-- ============================================================
CREATE TABLE managed_contents (
  id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL DEFAULT 'character'
    CHECK (entity_type IN ('character','event','civilization','artifact','location','source','learningPath','quiz')),
  name TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','inReview','approved','published','archived')),
  fields JSONB DEFAULT '{}',
  tags JSONB DEFAULT '[]',
  blocks JSONB DEFAULT '[]',
  created_by TEXT NOT NULL DEFAULT 'system',
  updated_by TEXT,
  current_version INT DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Fluxo Editorial
-- ============================================================
CREATE TABLE editorial_flow (
  id TEXT PRIMARY KEY,
  entity_id TEXT NOT NULL DEFAULT '',
  entity_type TEXT NOT NULL DEFAULT 'character'
    CHECK (entity_type IN ('character','event','civilization','artifact','location','source','learningPath','quiz')),
  status TEXT NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','inReview','approved','published','archived')),
  created_by TEXT NOT NULL DEFAULT '',
  reviewed_by TEXT,
  approved_by TEXT,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  approved_at TIMESTAMPTZ,
  published_at TIMESTAMPTZ,
  archived_at TIMESTAMPTZ
);

-- ============================================================
-- Versionamento de Conteúdo
-- ============================================================
CREATE TABLE content_versions (
  id TEXT PRIMARY KEY,
  entity_id TEXT NOT NULL DEFAULT '',
  entity_type TEXT NOT NULL DEFAULT 'character',
  version_number INT NOT NULL DEFAULT 1,
  data JSONB DEFAULT '{}',
  author_id TEXT NOT NULL DEFAULT '',
  author_name TEXT DEFAULT '',
  change_description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Logs de Auditoria
-- ============================================================
CREATE TABLE audit_logs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT '',
  user_name TEXT DEFAULT '',
  action TEXT NOT NULL DEFAULT 'login'
    CHECK (action IN ('login','logout','create','update','delete','publish','archive','restore','approve','reject','importData','exportData','roleChange','permissionChange')),
  entity_id TEXT,
  entity_type TEXT,
  entity_name TEXT,
  details JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Biblioteca de Mídia
-- ============================================================
CREATE TABLE media_library (
  id TEXT PRIMARY KEY,
  file_name TEXT NOT NULL DEFAULT '',
  url TEXT NOT NULL DEFAULT '',
  type TEXT NOT NULL DEFAULT 'image'
    CHECK (type IN ('image','video','document','audio','thumbnail')),
  size_bytes INT DEFAULT 0,
  folder TEXT,
  tags JSONB DEFAULT '[]',
  uploaded_by TEXT NOT NULL DEFAULT '',
  alt_text TEXT,
  width INT,
  height INT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Índices
-- ============================================================
CREATE INDEX idx_managed_contents_type ON managed_contents(entity_type);
CREATE INDEX idx_managed_contents_status ON managed_contents(status);
CREATE INDEX idx_managed_contents_type_status ON managed_contents(entity_type, status);
CREATE INDEX idx_editorial_flow_entity ON editorial_flow(entity_id);
CREATE INDEX idx_editorial_flow_status ON editorial_flow(status);
CREATE INDEX idx_content_versions_entity ON content_versions(entity_id);
CREATE INDEX idx_content_versions_number ON content_versions(entity_id, version_number);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_date ON audit_logs(created_at);
CREATE INDEX idx_media_library_type ON media_library(type);
CREATE INDEX idx_media_library_folder ON media_library(folder);
CREATE INDEX idx_admin_users_role ON admin_users(role);

-- ============================================================
-- RLS + Policies
-- ============================================================
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE managed_contents ENABLE ROW LEVEL SECURITY;
ALTER TABLE editorial_flow ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE media_library ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY "admin_users_all" ON admin_users FOR ALL USING (true);
  CREATE POLICY "managed_contents_all" ON managed_contents FOR ALL USING (true);
  CREATE POLICY "editorial_flow_all" ON editorial_flow FOR ALL USING (true);
  CREATE POLICY "content_versions_all" ON content_versions FOR ALL USING (true);
  CREATE POLICY "audit_logs_all" ON audit_logs FOR ALL USING (true);
  CREATE POLICY "media_library_all" ON media_library FOR ALL USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
