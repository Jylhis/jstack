---
name: audit
description: |
  Comprehensive codebase audit for existing projects. Maps architecture,
  inventories tech debt, assesses test coverage, evaluates dependency health,
  reviews security posture, and analyzes CI/CD and git history patterns.
  No sub-roles -- single behavior that adapts depth to codebase size.
  Use when onboarding to an existing project, before major refactors,
  or when you need a ground-truth snapshot of project health.
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

# Audit

You are running the `/audit` workflow. Your job is to produce an honest,
comprehensive snapshot of the current codebase state. This document becomes
the ground truth that other skills reference for architecture decisions,
scoped brainstorming, and onboarding.

**HARD GATE:** Do NOT fix anything. Do NOT refactor, patch, or modify code.
Your only output is `audit.md`. Fixes happen in downstream skills.

---

## Artifact Contract

```
PRODUCES: audit.md
REQUIRES: existing codebase (meaningful .git history or source files)
OPTIONAL: nothing
CONSUMED BY: /onboard, /constitution, /brainstorm:scoped, /plan, /specify
```

**Pre-flight check:** If no codebase exists (no .git directory, no source files),
STOP and tell the user: "Nothing to audit -- this appears to be a new project.
Use `/brainstorm` to explore ideas or `/constitution` to set up principles."

---

## Steps

### Step 1: Codebase Discovery

1. Run `git log --oneline -1` to confirm a codebase exists.
2. Read `CLAUDE.md`, `README.md`, `package.json`, `Cargo.toml`, `pyproject.toml`,
   `go.mod`, or equivalent project manifest to identify the tech stack.
3. Run directory listing to understand top-level structure:
   ```bash
   ls -la
   ```
4. Use Glob to map the full file tree (skip node_modules, .git, dist, build):
   ```bash
   find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/build/*' | head -200
   ```
5. Estimate codebase size: file count, line count for main source directories.

### Step 2: Architecture Map

1. Identify the primary architectural pattern (monolith, microservices, serverless,
   library, CLI tool, etc.).
2. Map the major modules/packages and their responsibilities.
3. Identify entry points (main files, route definitions, exported APIs).
4. Trace the data flow for one representative path through the system.
5. Note any unusual patterns or architectural decisions.

Produce a text-based architecture diagram using indented bullets or ASCII art.

### Step 3: Tech Debt Inventory

1. Search for TODO, FIXME, HACK, XXX, WORKAROUND comments:
   ```
   Grep for: TODO|FIXME|HACK|XXX|WORKAROUND
   ```
2. Identify code duplication patterns (similar function names, copy-pasted blocks).
3. Look for dead code signals: unused exports, commented-out blocks, unreachable paths.
4. Check for outdated patterns that conflict with current framework best practices.
5. Categorize each item: low / medium / high severity.

### Step 4: Test Coverage Assessment

1. Identify the test framework and test directory structure.
2. Count test files vs source files. Calculate the test-to-source ratio.
3. Check for test configuration (jest.config, vitest.config, pytest.ini, etc.).
4. Assess test quality signals:
   - Are there integration tests or only unit tests?
   - Do tests assert behavior or just check for no-crash?
   - Is there a CI pipeline that runs tests?
5. Identify untested areas: modules with no corresponding test files.

### Step 5: Dependency Health

1. Read the dependency manifest (package.json, Cargo.toml, requirements.txt, go.mod).
2. Count direct vs transitive dependencies.
3. Check for pinned vs floating versions.
4. Look for known-problematic dependencies (abandoned, security issues).
5. Check dependency age: when was the lockfile last updated?
6. Run `npm audit`, `cargo audit`, `pip-audit`, or equivalent if available.

### Step 6: Security Posture

1. Search for hardcoded secrets, API keys, tokens:
   ```
   Grep for: (password|secret|token|api.?key|private.?key)\s*[:=]
   ```
2. Check .gitignore for common sensitive file patterns (.env, credentials, keys).
3. Review authentication and authorization patterns if present.
4. Check for common vulnerability patterns (SQL injection, XSS, path traversal).
5. Note: this is a surface-level scan, not a penetration test.

### Step 7: CI/CD Review

1. Look for CI configuration (.github/workflows, .gitlab-ci.yml, Jenkinsfile, etc.).
2. Assess pipeline completeness: lint, test, build, deploy stages.
3. Check for automated quality gates (test pass required, coverage thresholds).
4. Note deployment strategy if visible (manual, auto-deploy on merge, canary).

### Step 8: Git History Patterns

1. Run `git log --oneline -50` to see recent commit patterns.
2. Assess commit hygiene: conventional commits, atomic changes, meaningful messages.
3. Check branch strategy: `git branch -r` to see remote branches.
4. Look at contributor patterns: `git shortlog -sn --no-merges -20`.
5. Identify churn hotspots: files that change most frequently.
   ```bash
   git log --pretty=format: --name-only --since="6 months ago" | sort | uniq -c | sort -rn | head -20
   ```

### Step 9: Write Artifact

Write `audit.md` with the following structure.

---

## Output Format

```markdown
# Audit: {project name}

Generated by /audit on {date}
Status: SNAPSHOT

## Executive Summary
{3-5 sentences: overall health, biggest strengths, biggest risks}

## Tech Stack
{Language, framework, runtime, key dependencies -- bullet list}

## Architecture Map
{Text diagram or structured description of major components and data flow}

### Entry Points
- {entry point 1}: {what it does}
- {entry point 2}: {what it does}

### Module Map
| Module | Responsibility | Size (files/LOC) |
|--------|---------------|-------------------|
| ...    | ...           | ...               |

## Tech Debt Inventory

| # | Location | Description | Severity | Category |
|---|----------|-------------|----------|----------|
| 1 | file:line | ...        | High/Med/Low | TODO / Dead code / Duplication / Outdated pattern |

**Summary:** {X high, Y medium, Z low severity items}

## Test Health

| Metric | Value |
|--------|-------|
| Test framework | ... |
| Test files | N |
| Source files | N |
| Test:source ratio | N:1 |
| Integration tests | Yes/No |
| CI runs tests | Yes/No |

### Untested Areas
- {module or area with no test coverage}

## Dependency Health

| Metric | Value |
|--------|-------|
| Direct dependencies | N |
| Lockfile age | {date} |
| Pinned versions | N% |
| Known vulnerabilities | N |

### Flagged Dependencies
- {dependency}: {concern}

## Security Posture
{Surface-level assessment. Not a penetration test.}
- Hardcoded secrets: {found / none found}
- .gitignore coverage: {adequate / gaps noted}
- Auth patterns: {description if present}
- Common vulnerabilities: {any patterns found}

## CI/CD
{Pipeline description, quality gates, deployment strategy}

## Git Health
- Commit style: {conventional / inconsistent / descriptive}
- Branch strategy: {trunk-based / gitflow / ad-hoc}
- Contributors (last 6 months): {N}
- Churn hotspots: {top 3-5 files}

## Top Risks
1. {Highest risk with reasoning}
2. {Second risk}
3. {Third risk}

## Recommendations
{Prioritized list of what to address first -- but do NOT fix anything here}
```

---

## Important Rules

- **Read-only.** Do not modify any files. Audit observes; it does not fix.
- **Be honest.** A flattering audit is useless. State problems clearly with evidence.
- **Quantify where possible.** "Some tech debt" is not useful. "14 TODOs, 3 high severity" is.
- **Adapt depth to size.** A 50-file project gets a quick audit. A 500-file project gets more structure.
- **Flag what you cannot assess.** If you lack access to CI logs, runtime metrics, or production data, say so.
- **No recommendations to rewrite.** "Rewrite in Rust" is never a valid audit finding. Work with what exists.
