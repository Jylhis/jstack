---
name: retro
description: |
  Engineering retrospective analyzing commit history, work patterns, and code
  quality metrics. Two sub-roles: :project (single repo, default), :global
  (cross-project analysis). Supports configurable time windows.
  Use when asked to "retro", "weekly retro", "what did we ship", or
  "engineering retrospective".
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - AskUserQuestion
  - WebSearch
---

> **Preamble:** Read and apply `lib/preamble.md` before proceeding.

# /retro: Engineering Retrospective

You are running the `/retro` workflow. Analyze git history, work patterns, and
code quality to produce an actionable retrospective. Designed for a senior IC or
CTO-level builder using AI coding tools as a force multiplier.

---

## Artifact Contract

**PRODUCES:** `retro.md` in `.jstack/retros/`
**REQUIRES:** Git history (for :project), telemetry data (for :global)
**READS (optional):** All other artifacts for context -- spec.md, plan.md,
  review.md, qa.md, deploy.md, tasks.md

---

## Sub-Roles

| Sub-Role   | Scope                  | Trigger                        |
|------------|------------------------|--------------------------------|
| `:project` | Single repository      | Default, or explicit `/retro`  |
| `:global`  | Cross-project analysis | `/retro global` or explicit    |

### Auto-Detection Logic

1. If user passes `global` argument -> `:global`
2. Otherwise -> `:project`

### Arguments

- `/retro` -- default: last 7 days, :project mode
- `/retro 24h` -- last 24 hours
- `/retro 14d` -- last 14 days
- `/retro 30d` -- last 30 days
- `/retro compare` -- compare current window vs prior same-length window
- `/retro global` -- cross-project retro (7d default)
- `/retro global 14d` -- cross-project with explicit window

---

## Steps (:project mode)

### Step 1: Gather Raw Data

Fetch origin, identify current user (`git config user.name`). Run in parallel:
commits with author/timestamps/stats, commit timestamps for session detection,
file hotspot analysis (name-only + uniq -c), per-author commit counts (shortlog).
Read existing artifacts if present: qa.md, review.md, deploy.md, tasks.md.

### Step 2: Compute Metrics

- **Velocity:** commits/day, lines changed/day, PRs merged.
- **Sessions:** detect from commit timestamps (gap > 2h = new session). Avg/max length.
- **File hotspots:** top 10 most-modified files. Flag any changed in >50% of commits.
- **Test-to-code ratio:** test lines vs production lines in window.
- **Commit hygiene:** conventional commit compliance, avg message length, commits >10 files.

### Step 3: Analyze Patterns

Assess: what went well (shipped features, coverage gains), what could improve
(hotspots needing refactor, large commits), risks (high-churn files without tests,
stale TODOs). For multi-author repos, per-person breakdown with praise and growth areas.

### Step 4: Compare Mode (if `compare` argument)

Compute same metrics for prior window of equal length. Show deltas and trends
(improving, stable, degrading).

### Step 5: Generate Recommendations

3-5 actionable recommendations, each citing specific evidence. Frame as opportunities.

### Step 6: Write Retro Artifact

Write `retro.md` to `.jstack/retros/retro-<date>.md`.

---

## Steps (:global mode)

1. **Discover:** Scan `~/.jstack/projects/` and common workspace dirs for repos with recent activity.
2. **Gather:** For each project, read artifacts (retro.md, qa.md, deploy.md) and compute high-level metrics.
3. **Analyze:** Time allocation per project, context switching frequency, shipping cadence, quality trends.
4. **Write:** `~/.jstack/retros/global-retro-<date>.md`.

---

## Output Format

```markdown
# Retro: <project-name>

**Period:** YYYY-MM-DD to YYYY-MM-DD | **Mode:** :project | :global

## Velocity
Commits: N (X/day) | Lines: +A/-B | PRs: M | Deploys: D

## Sessions
N sessions (avg X hrs, max Y hrs) | Active: A/B days | Peak day: <weekday>

## Hotspots
| # | File | Changes | Risk |

## Quality
Test ratio: X:1 | Hygiene: N/10 | Review coverage: M%

## Analysis
**Went well:** ... | **Improve:** ... | **Risks:** ...

## Recommendations
1-5 actionable items with evidence citations.

## Comparison (if compare)
| Metric | Prior | Current | Delta |
```

---

## Important Rules

- Always use midnight-aligned windows for day units. Use explicit `T00:00:00` suffix.
- All times in the user's local timezone. Never set TZ.
- Frame growth areas constructively. "Consider splitting large commits" not
  "commits are too big."
- Every observation must cite evidence from the data. No vague claims.
- For :global mode, respect project boundaries. Do not read code from other projects,
  only their artifacts and git metadata.
- Persist retro history so trends can be tracked across retros.
