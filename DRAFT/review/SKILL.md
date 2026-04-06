---
name: review
description: |
  Pre-landing code review. Analyzes diff against the base branch for structural
  issues, security risks, design violations, and performance regressions. Five
  sub-roles: :solo (you authored the code), :assist (reviewing someone else's PR),
  :security, :design, :performance. Auto-detects sub-role from commit author and
  diff content. Use when asked to "review", "code review", "check my PR", or
  "pre-landing review".
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

# /review: Pre-Landing Code Review

You are running the `/review` workflow. Analyze the current branch's diff against the
base branch for structural issues that tests do not catch. The review adapts its focus
based on the active sub-role.

---

## Artifact Contract

**PRODUCES:** `review.md` in `.jstack/reviews/`
**REQUIRES:** Code diff (git branch diverged from base, or PR reference)
**READS:** spec.md, plan.md, constitution (all optional but consulted when present)

---

## Sub-Roles

| Sub-Role      | Focus                                       | Trigger                                   |
|---------------|---------------------------------------------|-------------------------------------------|
| `:solo`       | Self-review: scope drift, blind spots       | Commit author matches `git config user.name` |
| `:assist`     | External review: correctness, maintainability | Commit author differs from current user   |
| `:security`   | Auth, crypto, network, injection, secrets   | Chained when auth/crypto/network files touched |
| `:design`     | UI consistency, accessibility, responsiveness | Chained when UI files touched (.tsx, .vue, .svelte, .css, .html) |
| `:performance`| Hot paths, algorithmic complexity, bundle size | Chained when hot paths or O(n^2)+ detected |

### Auto-Detection Logic

1. Get the current user: `git config user.name`
2. Get the commit authors on this branch: `git log origin/<base>..HEAD --format="%aN" | sort -u`
3. If all commit authors match the current user -> `:solo`. Otherwise -> `:assist`.
4. Get changed files: `git diff origin/<base> --name-only`
5. If any file matches auth, crypto, network, secrets, or session patterns -> also chain `:security`
6. If any file matches `.tsx`, `.vue`, `.svelte`, `.css`, `.scss`, `.html` -> also chain `:design`
7. Scan the diff for nested loops, recursive calls, `.filter().map()` chains, or `O(n` comments -> also chain `:performance`

Multiple sub-roles can be active simultaneously. The primary role (`:solo` or `:assist`)
always runs. Chained roles (`:security`, `:design`, `:performance`) add additional passes.

---

## Steps

### Step 1: Pre-flight

1. Run `git branch --show-current` to get the current branch.
2. If on the base branch or no diff exists against it, output: "Nothing to review -- you are on the base branch or have no changes against it." and stop.
3. Run `git fetch origin <base> --quiet && git diff origin/<base> --stat` to confirm a diff exists.

### Step 2: Detect Sub-Role

1. Execute the auto-detection logic above.
2. Print the active sub-roles: `Review mode: :solo + :security` (example).
3. Read spec.md, plan.md, and constitution if they exist. Store context for later steps.

### Step 3: Scope Drift Check

1. Read spec.md and plan.md (if present). Read commit messages: `git log origin/<base>..HEAD --oneline`.
2. Identify the stated intent of this branch.
3. Compare files changed against the stated intent.
4. Flag scope creep (unrelated changes) and missing requirements (stated but undelivered).
5. Output: `Scope Check: [CLEAN | DRIFT DETECTED | REQUIREMENTS MISSING]`
6. This is informational. Proceed regardless.

### Step 4: Primary Review Pass

Run two passes over the full diff (`git diff origin/<base>`):

**Pass 1 (CRITICAL):** SQL and data safety, race conditions, injection vectors,
trust boundary violations, enum/value completeness.

**Pass 2 (INFORMATIONAL):** Dead code, magic strings, conditional side effects,
test gaps, error handling, logging.

For `:solo` mode, apply additional self-review heuristics:
- "Would I understand this in 6 months?"
- "Am I testing the behavior or the implementation?"
- "Did I leave any TODO/FIXME/HACK markers?"

For `:assist` mode, apply external review heuristics:
- "Is the API contract clear?"
- "Are error messages actionable for the end user?"
- "Does this follow established project patterns?"

### Step 5: Chained Passes (conditional)

**:security** -- Auth bypass paths, hardcoded keys, weak crypto, SSRF, header injection,
secrets in logs/URLs, input validation on trust boundaries.

**:design** -- UI consistency vs spec tokens, accessibility (ARIA, keyboard, contrast),
responsive breakpoints, AI slop patterns.

**:performance** -- Hot path identification, O(n^2)+ algorithms, unbounded queries,
N+1 patterns, bundle impact, missing pagination.

### Step 6: Fix-First Resolution

Classify each finding as AUTO-FIX (mechanical) or ASK (judgment call).
Apply AUTO-FIX items directly. Batch ASK items into one AskUserQuestion with
per-item A) Fix / B) Skip. Apply user-approved fixes.

### Step 7: Write Review Artifact

Write `review.md` to `.jstack/reviews/review-<branch>-<date>.md`.

---

## Output Format

```markdown
# Review: <branch-name>

**Date:** YYYY-MM-DD | **Mode:** :solo + :security | **Range:** <base>..HEAD (N commits)

## Scope Check
[CLEAN | DRIFT DETECTED | REQUIREMENTS MISSING]

## Findings
### Critical / Informational / Security / Design / Performance
1. [file:line] Problem -> fix

## Summary
N issues (X critical, Y info). Auto-fixed: M | Asked: K | Skipped: J
```

---

## Important Rules

- Read the FULL diff before commenting. Do not flag issues already addressed in the diff.
- Fix-first, not read-only. AUTO-FIX items are applied directly. ASK items need approval.
- Never commit, push, or create PRs. That is /ship's job.
- Be terse. One line problem, one line fix.
- Only flag real problems. Skip anything that is fine.
- Verify claims: "handled elsewhere" requires citing the handling code.
