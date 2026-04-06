---
name: second-opinion
description: |
  Independent second review using a different model or clean context. Compares
  findings against an existing review to surface agreement, disagreement, blind
  spots, and conflicts. Use when asked for "second opinion", "cross-check review",
  "independent review", or "verify the review".
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

# /second-opinion: Independent Review Cross-Check

You are running the `/second-opinion` workflow. Perform an independent review of
the same code diff, then structurally compare your findings against the original
review to surface blind spots and conflicts.

---

## Artifact Contract

**PRODUCES:** `second-opinion.md` in `.jstack/reviews/`
**REQUIRES:** review.md OR code diff (at least one)
**READS:** constitution, spec.md (optional but consulted when present)

---

## Sub-Roles

| Sub-Role  | Method                                    | Trigger                              |
|-----------|-------------------------------------------|--------------------------------------|
| `:model`  | Route to a different AI model for review  | Multiple models configured in environment |
| `:clean`  | Same model, fresh context (no prior review visible) | Default when only one model available |

### Auto-Detection Logic

1. Check if alternative model configuration exists (e.g., CODEX_CLI, GEMINI_API_KEY,
   or other model endpoints in environment or config).
2. If multiple models are available -> `:model`. Use the alternative model for the
   independent review.
3. If only one model available -> `:clean`. Perform the review in a clean context
   without reading the original review.md first.

---

## Steps

### Step 1: Gather Inputs

1. Locate the original review: search `.jstack/reviews/` for the most recent `review-*.md`.
2. Get the code diff: `git fetch origin <base> --quiet && git diff origin/<base>`
3. Read spec.md and constitution if they exist.
4. If neither review.md nor a code diff exists, stop: "Nothing to second-opinion -- no review or diff found."

### Step 2: Independent Review

**Critical: Do NOT read the original review.md before completing this step.**

For `:clean` mode:
1. Analyze the diff independently, as if no prior review exists.
2. Apply the same review categories: SQL/data safety, race conditions, trust boundaries,
   dead code, test gaps, error handling, security, performance.
3. Record all findings with file:line references.

For `:model` mode:
1. Prepare the diff and spec context as a prompt for the alternative model.
2. Route the review request to the alternative model.
3. Parse and normalize the alternative model's findings into the standard format.

### Step 3: Read Original Review

Now read the original `review.md`. Parse each finding into a normalized form:
`{file, line, category, severity, description}`.

### Step 4: Structural Comparison

Classify each finding into exactly one bucket:
- **Agreement** -- both found the same issue. HIGH confidence. Proceed with fixes.
- **Second-Opinion Only** -- original missed it. MEDIUM confidence. Present for triage.
- **Original Only** -- second opinion missed it. MEDIUM confidence. Verify, may be FP.
- **Conflicts** -- disagree on severity/fix at same location. LOW confidence. Present both perspectives.

### Step 5: Write Second-Opinion Artifact

Write `second-opinion.md` to `.jstack/reviews/second-opinion-<branch>-<date>.md`.

---

## Output Format

```markdown
# Second Opinion: <branch-name>

**Date:** YYYY-MM-DD | **Mode:** :clean | :model (<name>) | **Concordance:** X%

## Agreement (N) -- high confidence, proceed with fixes
| # | File:Line | Category | Severity | Description |

## Second-Opinion Only (N) -- blind spots, triage needed
| # | File:Line | Category | Severity | Description |

## Original Only (N) -- verify, may be FP
| # | File:Line | Category | Severity | Description |

## Conflicts (N) -- human judgment needed
| # | File:Line | Original Says | Second Says | Recommendation |
```

---

## Important Rules

- Never read the original review before completing the independent review step.
- The value of a second opinion is independence. Contamination defeats the purpose.
- When using :model mode, normalize findings to a common format before comparison.
- Concordance below 50% suggests one reviewer may have a fundamentally different
  understanding of the codebase. Flag this prominently.
- Never auto-fix from second-opinion. Present findings for the user to triage.
