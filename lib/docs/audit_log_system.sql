-- =========================================================
-- EXTENSIONS
-- =========================================================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =========================================================
-- CLEANUP (SAFE RE-RUN)
-- =========================================================
DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN
    SELECT tgname, relname
    FROM pg_trigger
    JOIN pg_class ON pg_class.oid = tgrelid
    WHERE tgname LIKE 'audit_%'
  LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS %I ON %I',
      r.tgname,
      r.relname
    );
  END LOOP;
END $$;

DROP FUNCTION IF EXISTS audit_trigger_func() CASCADE;
DROP FUNCTION IF EXISTS log_audit(TEXT, TEXT, TEXT, JSONB, JSONB) CASCADE;

-- =========================================================
-- AUDIT LOGS TABLE
-- =========================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    table_name TEXT NOT NULL,
    action TEXT NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    record_id TEXT,

    old_data JSONB,
    new_data JSONB,

    actor UUID, -- auth.uid()

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =========================================================
-- FOREIGN KEY (ACTOR → USERS)
-- =========================================================
ALTER TABLE audit_logs
DROP CONSTRAINT IF EXISTS fk_audit_actor;

ALTER TABLE audit_logs
ADD CONSTRAINT fk_audit_actor
FOREIGN KEY (actor)
REFERENCES users(auth_id)
ON DELETE SET NULL;

-- =========================================================
-- INDEXES
-- =========================================================
CREATE INDEX IF NOT EXISTS idx_audit_logs_table_name
    ON audit_logs(table_name);

CREATE INDEX IF NOT EXISTS idx_audit_logs_action
    ON audit_logs(action);

CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at
    ON audit_logs(created_at);

CREATE INDEX IF NOT EXISTS idx_audit_logs_actor
    ON audit_logs(actor);

-- =========================================================
-- AUDIT INSERT FUNCTION
-- =========================================================
CREATE OR REPLACE FUNCTION log_audit(
    p_table_name TEXT,
    p_action TEXT,
    p_record_id TEXT,
    p_old_data JSONB,
    p_new_data JSONB
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO audit_logs (
        table_name,
        action,
        record_id,
        old_data,
        new_data,
        actor
    )
    VALUES (
        p_table_name,
        p_action,
        p_record_id,
        p_old_data,
        p_new_data,
        auth.uid()  -- NULL if not authenticated (OK)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- GENERIC AUDIT TRIGGER FUNCTION
-- =========================================================
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        PERFORM log_audit(
            TG_TABLE_NAME,
            'INSERT',
            NEW.id::TEXT,
            NULL,
            to_jsonb(NEW)
        );
        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        PERFORM log_audit(
            TG_TABLE_NAME,
            'UPDATE',
            NEW.id::TEXT,
            to_jsonb(OLD),
            to_jsonb(NEW)
        );
        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        PERFORM log_audit(
            TG_TABLE_NAME,
            'DELETE',
            OLD.id::TEXT,
            to_jsonb(OLD),
            NULL
        );
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================
-- AUTO-ATTACH AUDIT TRIGGERS TO ALL TABLES
-- =========================================================
DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN
    SELECT tablename
    FROM pg_tables
    WHERE schemaname = 'public'
      AND tablename <> 'audit_logs'
  LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS audit_%I ON %I',
      r.tablename,
      r.tablename
    );

    EXECUTE format(
      'CREATE TRIGGER audit_%I
       AFTER INSERT OR UPDATE OR DELETE ON %I
       FOR EACH ROW
       EXECUTE FUNCTION audit_trigger_func()',
      r.tablename,
      r.tablename
    );
  END LOOP;
END $$;
