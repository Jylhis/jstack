---
name: git-flow
description: |
  Establish and document the git workflow for a project. Two sub-roles:
  :init (interactive setup from scratch), :detect (infer conventions from
  existing git history). Produces git-flow.md with branching strategy,
  commit conventions, and merge policy. Includes the jstack default discipline.
  Use when asked to "set up git flow", "git conventions", "branching strategy",
  or "how should we use git".
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

# /git-flow: Git Workflow Setup

You are running the `/git-flow` workflow. Establish, document, and optionally
enforce a git workflow for the project. Can either interactively configure from
scratch or infer conventions from existing history.

---

## Artifact Contract

**PRODUCES:** `git-flow.md` in `.jstack/`
**REQUIRES:** Git repository
**READS (optional):** audit.md, existing CONTRIBUTING.md, existing .github/ config

---

## Sub-Roles

| Sub-Role  | Method                              | Trigger                           |
|-----------|-------------------------------------|-----------------------------------|
| `:init`   | Interactive setup from scratch      | New repo, no history, or explicit |
| `:detect` | Infer from existing git history     | Existing repo with 20+ commits   |

### Auto-Detection Logic

1. Count commits: `git rev-list --count HEAD 2>/dev/null || echo 0`
2. If < 20 commits or user explicitly asks to "set up" -> `:init`
3. If >= 20 commits -> `:detect`

---

## jstack Default Git Discipline

The following conventions are the jstack defaults. They are used as the baseline
for `:init` mode and as the comparison standard for `:detect` mode.

### Branch Naming

Format: `<type>/<short-description>`
Types: `feat`, `fix`, `refactor`, `docs`, `infra`, `chore`
Examples: `feat/user-auth`, `fix/null-pointer-dashboard`, `refactor/split-monolith`

### Commit Conventions (Conventional Commits)

Format: `<type>(<scope>): <description>` -- imperative mood, lowercase, max 72 chars.
Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`, `build`
Body explains "why" not "what". Footer for `BREAKING CHANGE:`, `Fixes #123`, `Co-authored-by:`

### Commit Discipline

Atomic commits (one logical change per commit), bisectable (every commit builds and
passes tests), no WIP commits on shared branches.

### Merge Strategy

Squash merge to main. Rebase before merge. Linear history (no merge commits).
PR required even for solo projects.

### Versioning

Semantic Versioning with annotated tags: `vMAJOR.MINOR.PATCH` (or 4-digit `MAJOR.MINOR.PATCH.MICRO`).
CHANGELOG.md updated with every version bump.

### Branch Protection (recommended)

Require PR reviews, require CI to pass, no force push to main, delete branches after merge.

---

## Steps (:init mode)

### Step 1: Survey

Check for CONTRIBUTING.md, .github/.gitlab/ config, audit.md. Detect platform.

### Step 2: Present Defaults & Choose

Show jstack defaults. Ask: A) Adopt all  B) Customize interactively  C) Switch to :detect

### Step 3: Customize (if B) + Enforcement (optional)

Walk each section interactively. Offer tooling: commitlint, husky/lefthook, branch
protection via `gh api`, PR templates.

### Step 4: Write Artifacts

Write `git-flow.md` to `.jstack/`. Optionally update CONTRIBUTING.md, create PR template.

---

## Steps (:detect mode)

### Step 1: Analyze + Infer

Run in parallel: branch patterns, commit messages (last 100), merge strategy,
tags, commit prefixes. Infer current conventions for each area.

### Step 2: Compare + Recommend

Build comparison table (Current vs jstack Default, status: ALIGNED/CLOSE/DIVERGENT).
For each DIVERGENT item, explain the benefit. Ask: A) Adopt all  B) Cherry-pick  C) Keep.

### Step 3: Write Artifacts

Write `git-flow.md` documenting final conventions. Offer to update CONTRIBUTING.md.

---

## Output Format

```markdown
# Git Flow: <project-name>

**Date:** YYYY-MM-DD | **Mode:** :init | :detect | **Platform:** GitHub | GitLab | Local

## Conventions
- **Branches:** <type>/<short-description> (feat, fix, refactor, docs, infra, chore)
- **Commits:** Conventional Commits -- <type>(<scope>): <description>
- **Merge:** Squash to main, rebase before merge, linear history, PR required
- **Versioning:** Semantic Versioning with annotated tags, CHANGELOG.md maintained

## Protection & Enforcement
- [ ] PR reviews required | [ ] CI required | [ ] No force push | [ ] Auto-delete branches
- [ ] commitlint | [ ] Git hooks | [ ] PR template | [ ] CI checks

## Detection Results (if :detect)
| Area | Current | Recommended | Status |
|------|---------|-------------|--------|
```

---

## Important Rules

- Never force a workflow. Present defaults, allow customization.
- :detect requires 100+ commits for representative analysis.
- Document what IS, not just what SHOULD BE. Accuracy over aspiration.
- Never modify git history or branch protection without explicit approval.
- git-flow.md is the single source of truth. Other skills (review, ship) reference it.
- Explain WHY, not just WHAT. "Squash keeps main bisectable" > "use squash merge."
