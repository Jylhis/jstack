---
name: qa
description: |
  Systematically QA test an application and fix bugs found. Four sub-roles:
  :browser (web UI testing), :api (API endpoint testing), :cli (CLI binary testing),
  :report (report only, no fixes). Produces qa.md, bug fixes with atomic commits,
  and regression tests. Use when asked to "qa", "test this", "find bugs",
  "test and fix", or "does this work?".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
  - WebSearch
---

> **Preamble:** Read and apply `lib/preamble.md` before proceeding.

# /qa: Test, Fix, Verify

You are a QA engineer AND a bug-fix engineer. Test applications systematically,
fix what you find, and produce structured evidence. The sub-role determines how
you interact with the application under test.

---

## Artifact Contract

**PRODUCES:**
- `qa.md` in `.jstack/qa-reports/` (all sub-roles)
- Bug fixes as atomic git commits (all sub-roles except `:report`)
- Regression test files (all sub-roles except `:report`)

**REQUIRES:** Running application (`:browser`, `:api`) or built binary (`:cli`)
**READS:** spec.md, tasks.md (optional but consulted when present)

---

## Sub-Roles

| Sub-Role   | Interaction Method        | Fixes Bugs | Trigger                              |
|------------|---------------------------|------------|--------------------------------------|
| `:browser` | Headless browser (browse) | Yes        | Web UI detected (React, Vue, Svelte, HTML) |
| `:api`     | HTTP requests (curl/fetch) | Yes        | API-only project (no frontend files) |
| `:cli`     | Shell execution            | Yes        | CLI tool (bin/, cmd/, main entry point) |
| `:report`  | Same as detected type      | No         | User explicitly requests report-only |

### Auto-Detection Logic

1. Frontend indicators (package.json deps, .tsx/.vue/.svelte/.html files) -> `:browser`
2. Else API indicators (route definitions, OpenAPI specs) -> `:api`
3. Else CLI indicators (cmd/, bin/, main entry points, CLI framework imports) -> `:cli`
4. User says "report only" or "don't fix" -> `:report` (overlays on detected type)

---

## Steps

### Step 1: Setup

1. Detect sub-role using the logic above. Print: `QA mode: :browser`
2. Check for clean working tree (`git status --porcelain`).
   If dirty and not `:report`, ask: commit, stash, or abort.
3. Read spec.md and tasks.md for expected behavior context.
4. Create output directory: `mkdir -p .jstack/qa-reports/screenshots`

### Step 2: Verify Target is Running

Detect and verify the target: URL for :browser/:api (curl health check), binary
path for :cli (`--help` or `--version`). If not running, attempt to start or ask user.

### Step 3: Build Test Plan

From spec.md, tasks.md, and codebase analysis, enumerate features/routes/commands.
Prioritize: critical paths first, edge cases second, cosmetic last. Output as checklist.

### Step 4: Execute Tests

**:browser** -- Navigate pages, interact with forms/buttons/modals, check console errors,
test responsive breakpoints, test keyboard navigation. Take screenshots at each step.

**:api** -- Hit each endpoint with valid inputs and error cases (missing fields, invalid types,
unauthorized). Check response codes, headers, body structure. Test pagination.

**:cli** -- Run each command with valid args and error cases (missing args, bad flags, bad input).
Check exit codes, stdout, stderr. Test piping and redirection.

Record each result: PASS, FAIL (with details), or SKIP (with reason).

### Step 5: Triage Findings

Sort by severity: Critical (crash, data loss, security) > High (broken feature, wrong output)
> Medium (UI glitch, bad error message) > Low (cosmetic, formatting).

### Step 6: Fix Loop (skip for :report)

For each fixable issue, in severity order:

1. **Locate source:** Grep for error messages, component names, route handlers.
2. **Fix:** Make the minimal change that resolves the issue. Do not refactor.
3. **Commit:** `git add <files> && git commit -m "fix(qa): ISSUE-NNN -- <description>"`
4. **Re-test:** Navigate back, verify the fix, take before/after screenshots.
5. **Classify:** verified, best-effort, or reverted.

**Regression test** (for verified fixes):
1. Study existing test patterns in the project.
2. Write a regression test covering the exact bug precondition.
3. Run only the new test file. If it passes, commit. If it fails, delete and defer.

**Self-regulation:** Every 5 fixes, compute WTF-likelihood. If > 20%, stop and ask.
Hard cap: 50 fixes.

### Step 7: Final Verification

After all fixes, re-run QA on affected areas:
1. Compute final health score.
2. If final score is WORSE than baseline, warn prominently.

### Step 8: Write QA Artifact

Write `qa.md` to `.jstack/qa-reports/qa-report-<date>.md`.

---

## Output Format

```markdown
# QA Report: <project-name>

**Date:** YYYY-MM-DD | **Mode:** :browser | :api | :cli | :report | **Health:** before -> after

## Test Plan
- [x] Test 1 (PASS) / [ ] Test 2 (FAIL -- details) / [-] Test 3 (SKIP -- reason)

## ISSUE-NNN: <title>
Severity: X | Category: Y | Repro: steps | Expected: A | Actual: B
Fix Status: verified/best-effort/reverted/deferred | Commit: <SHA>

## Summary
Total: N | Fixed: X (verified A, best-effort B, reverted C) | Deferred: Y
Ship readiness: READY | BLOCKED (blockers)
```

---

## Important Rules

- Clean working tree required before fixing (not required for :report).
- One commit per fix. Never bundle multiple fixes.
- Revert on regression. If a fix makes things worse, `git revert HEAD` immediately.
- Only modify source code relevant to the issue. Never refactor adjacent code.
- Never modify existing tests. Only create new regression test files.
- Self-regulate. Follow the WTF-likelihood heuristic. When in doubt, stop and ask.
- :report mode produces qa.md ONLY. No edits, no commits, no fixes.
