#!/usr/bin/env bash
# Supabase project config for jstack telemetry
# These are PUBLIC keys — safe to commit (like Firebase public config).
# RLS denies all access to the anon key. All reads and writes go through
# edge functions (which use SUPABASE_SERVICE_ROLE_KEY server-side).

JSTACK_SUPABASE_URL="https://dgoyvrnzxpiailzearqg.supabase.co"
JSTACK_SUPABASE_ANON_KEY="sb_publishable_e-C-_r1YjjtL7l71v-FNDw_1xWIYzrQ"
