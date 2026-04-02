-- 003_drop_anon_insert.sql
-- Remove INSERT policies for the anon key. All writes now go through
-- edge functions (which use SUPABASE_SERVICE_ROLE_KEY). Old clients
-- that POST directly to PostgREST will get 403.

DROP POLICY IF EXISTS "anon_insert_only" ON telemetry_events;
DROP POLICY IF EXISTS "anon_insert_only" ON installations;
DROP POLICY IF EXISTS "anon_insert_only" ON update_checks;
