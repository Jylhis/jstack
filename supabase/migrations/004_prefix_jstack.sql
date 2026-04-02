-- 004_prefix_jstack.sql
-- Prefix all tables, views, and indexes with jstack_ so multiple
-- applications can share the same Supabase project without collisions.

-- Drop views first (they depend on the old table names)
DROP VIEW IF EXISTS crash_clusters;
DROP VIEW IF EXISTS skill_sequences;

-- Rename tables
ALTER TABLE telemetry_events RENAME TO jstack_telemetry_events;
ALTER TABLE installations RENAME TO jstack_installations;
ALTER TABLE update_checks RENAME TO jstack_update_checks;
ALTER TABLE community_pulse_cache RENAME TO jstack_community_pulse_cache;

-- Rename indexes
ALTER INDEX idx_telemetry_session_ts RENAME TO idx_jstack_telemetry_session_ts;
ALTER INDEX idx_telemetry_error RENAME TO idx_jstack_telemetry_error;

-- Recreate views with jstack_ prefix and new table references
CREATE VIEW jstack_crash_clusters AS
SELECT
  error_class,
  jstack_version,
  COUNT(*) as total_occurrences,
  COUNT(DISTINCT installation_id) as identified_users,
  COUNT(*) - COUNT(installation_id) as anonymous_occurrences,
  MIN(event_timestamp) as first_seen,
  MAX(event_timestamp) as last_seen
FROM jstack_telemetry_events
WHERE outcome = 'error' AND error_class IS NOT NULL
GROUP BY error_class, jstack_version
ORDER BY total_occurrences DESC;

CREATE VIEW jstack_skill_sequences AS
SELECT
  a.skill as skill_a,
  b.skill as skill_b,
  COUNT(DISTINCT a.session_id) as co_occurrences
FROM jstack_telemetry_events a
JOIN jstack_telemetry_events b ON a.session_id = b.session_id
  AND a.skill != b.skill
  AND a.event_timestamp < b.event_timestamp
WHERE a.event_type = 'skill_run' AND b.event_type = 'skill_run'
GROUP BY a.skill, b.skill
HAVING COUNT(DISTINCT a.session_id) >= 10
ORDER BY co_occurrences DESC;

-- Revoke view access from anon (matching 002 behavior)
REVOKE SELECT ON jstack_crash_clusters FROM anon;
REVOKE SELECT ON jstack_skill_sequences FROM anon;
