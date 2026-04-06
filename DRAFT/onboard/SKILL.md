---
name: onboard
description: |
  Reverse-engineer jstack artifacts from an existing project. Reads the audit
  report and codebase to produce constitution.md, spec.md, and plan.md so that
  downstream skills (implement, review, qa) can operate on the project as if
  it were planned from scratch. All generated artifacts are marked as
  reverse-engineered and need human review.
  Use when adopting jstack on a project that already has code.
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

# Onboard

You are running the `/onboard` workflow. Your job is to reverse-engineer jstack
artifacts from an existing codebase so that downstream skills can operate as if the
project went through the full jstack pipeline. Every artifact you produce is marked
as reverse-engineered and requires human review before being treated as authoritative.

**HARD GATE:** Do NOT modify any source code. You produce only artifact documents.

---

## Artifact Contract

```
PRODUCES:
  - constitution.md (reverse-engineered, needs review)
  - spec.md (reverse-engineered, needs review)
  - plan.md (reverse-engineered, needs review)
REQUIRES: audit.md (must have run /audit first)
OPTIONAL: nothing
CONSUMED BY: /implement, /review, /qa, /tasks, /specify (as baseline)
```

**Pre-flight check:** If `audit.md` does not exist, STOP and tell the user:
"Onboarding requires an audit first. Run `/audit` to analyze the codebase,
then re-run `/onboard`."

---

## Steps

### Step 1: Load Audit

1. Read `audit.md` thoroughly. Extract:
   - Tech stack and architecture map.
   - Module responsibilities and entry points.
   - Test health and quality signals.
   - Existing patterns and conventions.
   - Tech debt and risk inventory.
2. Read `CLAUDE.md`, `README.md` if they exist for additional context.
3. Read `constitution.md` if it already exists (skip constitution generation in Step 3).

### Step 2: Codebase Deep Read

Go beyond the audit to understand the project's implicit rules:

1. **Naming conventions:** Sample 10-15 files across modules. Extract patterns
   for file names, function names, variable names, type names.
2. **Error handling patterns:** How does the codebase handle errors? Exceptions,
   Result types, error codes, silent swallowing?
3. **Import/dependency patterns:** How are modules organized? Barrel exports,
   direct imports, dependency injection?
4. **API contracts:** If there are APIs, read route definitions and extract
   the implicit contract (REST, GraphQL, RPC, etc.).
5. **State management:** How is application state managed? Database, in-memory,
   external service, config files?

### Step 3: Generate Constitution

Skip this step if `constitution.md` already exists.

Based on audit.md and the deep read, infer the project's implicit engineering
principles. These are rules the codebase already follows, not aspirational goals.

1. Extract observed patterns as principles (e.g., "All API handlers return typed
   error responses" if that pattern exists consistently).
2. Note where the codebase is inconsistent -- these become "Disputed" principles.
3. Cross-reference with built-in constitution (lib/constitution-builtin.md).
   Mark which built-in rules the project already follows vs. violates.
4. Draft `constitution.md` with the `REVERSE-ENGINEERED` status.

Use AskUserQuestion: "Here are the engineering principles I inferred from the
codebase. Which are intentional rules vs. accidental patterns? Any to add or remove?"

### Step 4: Generate Spec

Reverse-engineer a feature specification from the existing code:

1. **User-facing behaviors:** Map all user-visible features from routes, UI components,
   CLI commands, or API endpoints.
2. **Functional requirements:** For each feature, state what it does as a requirement.
3. **Edge cases handled:** Note edge cases the code explicitly handles (validation,
   error states, empty states, permissions).
4. **Edge cases missing:** Note obvious edge cases the code does NOT handle.
5. **Acceptance criteria:** Derive testable acceptance criteria from existing test
   assertions where available.

Use AskUserQuestion: "This is the spec I reverse-engineered. What's missing?
What features exist that I didn't capture?"

### Step 5: Generate Plan

Reverse-engineer an implementation plan from the existing architecture:

1. **Architecture decisions:** Document the choices made (framework, database, hosting,
   patterns) and infer the reasoning.
2. **Data model:** Map the core data structures, schemas, or database tables.
3. **Component relationships:** Document how modules depend on each other.
   Build a dependency graph.
4. **Test strategy:** Document the existing test approach (what's tested, what isn't,
   which frameworks are used).
5. **Known gaps:** From audit.md, list the areas that need attention (tech debt,
   missing tests, security issues).

Use AskUserQuestion: "This is the plan I reverse-engineered. Does this match the
original intent? Any architectural decisions I misread?"

### Step 6: Write Artifacts

Write all three artifacts with the reverse-engineered status marker.

---

## Output Format

### constitution.md

```markdown
# Project Constitution

Generated by /onboard on {date}
Status: REVERSE-ENGINEERED -- NEEDS REVIEW

> This constitution was inferred from existing code patterns, not authored
> by the team. Review each principle and confirm it reflects intentional
> decisions, not accidental patterns.

> Built-in principles from lib/constitution-builtin.md are always active.
> This document extends those defaults.

## Project Context
{Language, framework, architecture -- from audit.md}

## Inferred Principles

### Engineering
- {observed pattern stated as principle} [CONFIDENT / UNCERTAIN]

### Quality
- {observed pattern stated as principle} [CONFIDENT / UNCERTAIN]

### Process
- {observed pattern stated as principle} [CONFIDENT / UNCERTAIN]

## Built-in Alignment
| Built-in Rule | Project Status |
|---------------|----------------|
| TDD           | Followed / Partially / Not followed |
| Atomic commits | ... |
| ...           | ... |

## Disputed Patterns
{Patterns where the codebase is inconsistent -- needs team decision}
```

### spec.md

```markdown
# Specification

Generated by /onboard on {date}
Status: REVERSE-ENGINEERED -- NEEDS REVIEW

> This spec was reverse-engineered from existing code. It describes what
> the system currently does, not necessarily what it should do. Review
> for accuracy and completeness.

## Features

### {Feature 1}
**What it does:** {description}
**Entry point:** {file/route/command}
**Functional requirements:**
- FR-1: {requirement}
- FR-2: {requirement}
**Edge cases handled:** {list}
**Edge cases missing:** {list}
**Acceptance criteria:**
- {testable criterion}

### {Feature 2}
...

## Cross-Cutting Concerns
- Authentication: {how it works or "not present"}
- Authorization: {how it works or "not present"}
- Error handling: {pattern}
- Logging: {pattern}
- Validation: {pattern}
```

### plan.md

```markdown
# Implementation Plan

Generated by /onboard on {date}
Status: REVERSE-ENGINEERED -- NEEDS REVIEW

> This plan was reverse-engineered from existing architecture. It documents
> what was built and how, not what should be built next.

## Architecture Decisions
| Decision | Choice | Inferred Reasoning |
|----------|--------|-------------------|
| Framework | ... | ... |
| Database  | ... | ... |
| Hosting   | ... | ... |

## Data Model
{Core entities, relationships, schemas}

## Component Map
{Module dependency graph -- text-based diagram}

## Test Strategy
- Framework: {name}
- Coverage approach: {unit / integration / e2e / mix}
- Gaps: {untested areas from audit.md}

## Known Gaps (from audit)
| # | Gap | Severity | Source |
|---|-----|----------|--------|
| 1 | ... | ...      | audit.md |

## Recommended Next Steps
{Prioritized list of what to work on -- tech debt, missing tests, new features}
```

---

## Important Rules

- **Read-only on source code.** Only produce artifact documents. Do not modify source files.
- **Mark everything as reverse-engineered.** Every artifact must have the status marker and disclaimer.
- **Distinguish confident from uncertain.** If a pattern might be accidental, label it UNCERTAIN.
- **Human review is mandatory.** Onboard artifacts are drafts. The user must review and approve before downstream skills treat them as authoritative.
- **One question at a time.** Never batch multiple questions into one AskUserQuestion.
- **Do not invent features.** Only document what the code actually does, not what it could do.
- **Err on the side of omission.** If you cannot determine a pattern confidently, leave it out rather than guess. Incomplete and honest beats comprehensive and wrong.
