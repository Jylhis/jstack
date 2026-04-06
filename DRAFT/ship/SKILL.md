---
name: ship
description: |
  Ship workflow: run tests, review diff, bump version, update changelog, commit,
  push, create PR, optionally deploy. Three sub-roles: :pr (create PR only),
  :deploy (deploy existing PR), :full (PR then deploy). Use when asked to "ship",
  "create a PR", "push to main", "deploy", or "merge and push".
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

# /ship: Automated Ship Workflow

You are running the `/ship` workflow. This is a non-interactive, fully automated
workflow. Do NOT ask for confirmation at any step unless specifically noted. The
user said `/ship` which means DO IT.

---

## Artifact Contract

**PRODUCES:**
- `deploy.md` in `.jstack/deploys/` (deployment record)
- PR/MR on the hosting platform (GitHub PR or GitLab MR)
- Deployment record (for `:deploy` and `:full`)

**REQUIRES:** Passing tests, reviewed code (review.md recommended but not gating)
**READS:** spec.md, constitution (optional but consulted when present)

---

## Sub-Roles

| Sub-Role  | Scope                            | Trigger                          |
|-----------|----------------------------------|----------------------------------|
| `:pr`     | Tests + review + version + PR    | Default when no deploy config    |
| `:deploy` | Deploy an existing merged PR     | User says "deploy" with merged PR |
| `:full`   | PR workflow then deploy          | User says "ship and deploy", deploy config exists |

### Auto-Detection Logic

1. Check if deploy configuration exists (`.jstack/deploy.yaml`, fly.toml, vercel.json,
   render.yaml, netlify.toml, Procfile, or similar).
2. If deploy config exists AND user says "ship" or "ship and deploy" -> `:full`
3. If deploy config exists AND user says "deploy" -> `:deploy`
4. If no deploy config OR user says "create PR" -> `:pr`

---

## Steps

### Step 1: Pre-flight

1. Check the current branch. If on the base branch, abort: "Ship from a feature branch."
2. Run `git status` (never use `-uall`). Uncommitted changes are always included.
3. Run `git diff <base>...HEAD --stat` and `git log <base>..HEAD --oneline` to understand scope.
4. Check for prior review: look for `review.md` in `.jstack/reviews/`.
   If no review found, note: "No prior review found -- ship will run its own pre-landing review."

### Step 2: Merge Base Branch

`git fetch origin <base> && git merge origin/<base> --no-edit`. Auto-resolve simple
conflicts (VERSION, CHANGELOG). STOP on complex conflicts.

### Step 3: Run Tests

Detect test command, run full suite. In-branch failures -> STOP. Pre-existing on
base branch -> note and continue.

### Step 4: Pre-Landing Review

No prior review.md: run condensed review (same categories as /review), AUTO-FIX
mechanical issues, ASK for judgment calls, commit fixes and re-test if needed.
Prior review.md exists: verify reviewed commit matches HEAD, run delta if changed.

### Step 5: Version Bump

Read VERSION. Auto-decide: <50 lines -> MICRO/PATCH, medium -> PATCH, large
features -> ASK MINOR, breaking -> ASK MAJOR. Write new version.

### Step 6: Changelog

Enumerate commits, read diff, group by theme, write CHANGELOG entry. Every commit
must map to at least one bullet point.

### Step 7: Commit + Push

Bisectable chunks: one logical change per commit, ordered by dependency. Each
independently valid. Push with `git push -u origin <branch>`. Never force push.

### Step 8: Create PR/MR (for :pr and :full)

PR body sections: Summary (all commits grouped), Test Results, Pre-Landing Review,
Test plan checklist.

### Step 9: Deploy (for :deploy and :full)

Detect platform, run deployment, wait for completion, health check production URL.
If health check fails, warn. Do NOT auto-rollback without approval.
Write `deploy.md` to `.jstack/deploys/deploy-<version>-<date>.md`.

---

## Output Format

```markdown
# Ship: <branch-name>

**Date:** YYYY-MM-DD | **Version:** X.Y.Z -> A.B.C | **Mode:** :pr | :deploy | :full

## Pre-flight
Branch: <name> | Commits: N | Files changed: M | Prior review: yes/no

## Tests
Suite: PASS (N tests, 0 failures) | Evals: PASS/SKIP

## Review
Findings: N (X auto-fixed, Y asked, Z skipped)

## Version + Changelog
Bump: MICRO/PATCH/MINOR/MAJOR -> A.B.C
<Excerpt of the new CHANGELOG entry>

## PR/MR
URL: <link> | Title: <title>

## Deploy (if applicable)
Platform: <name> | Status: SUCCESS/FAILED | Health: PASS/FAIL | URL: <link>
```

---

## Important Rules

- Never skip tests. If tests fail on in-branch code, stop.
- Never skip the pre-landing review. If review checklist is unreadable, stop.
- Never force push.
- Never ask for trivial confirmations. Only stop for: MINOR/MAJOR version bumps,
  ASK-classified review findings, and deployment failures.
- Always use bisectable commits. Each commit = one logical change.
- Date format in CHANGELOG: YYYY-MM-DD.
- The goal is: user says /ship, next thing they see is the PR URL.
