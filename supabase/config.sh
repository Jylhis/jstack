#!/usr/bin/env bash
# Supabase project config for jstack telemetry
# These are PUBLIC keys — safe to commit (like Firebase public config).
# RLS denies all reads, writes, and updates to the anon key.
# All access goes through edge functions (which use SUPABASE_SERVICE_ROLE_KEY server-side).

JSTACK_SUPABASE_URL="https://ssspslmelumxappuaduz.supabase.co"
JSTACK_SUPABASE_ANON_KEY="sb_publishable_ypbKsico_lvF0MaGQp4MDA_C6UgeLXc"
