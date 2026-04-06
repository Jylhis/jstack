---
name: specify
description: |
  Specification authoring skill. Transforms vague ideas, brainstorm notes, and research
  into structured, testable specifications. Three sub-roles: :full for greenfield,
  :delta for changes to existing specs, :clarify for resolving ambiguity in a spec.
  Use when asked to "write a spec", "specify this", "what should we build", or
  "turn this into requirements".
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

# Specify: Structured Specification Authoring

You are running the `/specify` workflow. Transform intent into a testable specification.

---

## Artifact Contract

**PRODUCES:** `spec.md` — a structured specification document with acceptance criteria.

**REQUIRES:**
- Constitution (built-in project defaults or explicit `constitution/` directory)

**OPTIONAL INPUTS:**
- `brainstorm.md` — raw ideation output to distill
- `research.md` — prior research and competitive analysis
- `validation.md` — user testing or feedback data

---

## Sub-Roles

### Auto-Detection Logic

1. Check if `spec.md` already exists in the working directory or project root.
2. If `spec.md` exists and the user's request describes a change or addition: use **:delta**.
3. If `spec.md` does not exist (greenfield project): use **:full**.
4. If the user explicitly asks to "clarify", "resolve ambiguity", or "what does X mean in the spec": use **:clarify**.
5. The user can override by saying `/specify:full`, `/specify:delta`, or `/specify:clarify`.

### :full — Greenfield Specification

Write a complete spec from scratch. Covers problem statement, user stories, acceptance
criteria, non-functional requirements, and scope boundaries.

### :delta — Change Specification

Read the existing `spec.md`. Identify what changes. Produce a diff-aware update that
preserves unchanged sections and clearly marks additions, modifications, and removals.

### :clarify — Ambiguity Resolution

Read the existing `spec.md`. Identify ambiguous language, missing edge cases, and
implicit assumptions. Present each ambiguity with options and recommended resolution.

---

## Step 1: Gather Context

1. Read the constitution (project `constitution/` directory or built-in defaults).
2. Read optional inputs if they exist: `brainstorm.md`, `research.md`, `validation.md`.
3. Read existing `spec.md` if present (determines sub-role).
4. If the user's intent is unclear, ask ONE clarifying question via AskUserQuestion.

---

## Step 2: Problem Framing

1. State the problem in one sentence.
2. Identify the target user(s).
3. Define what success looks like (measurable outcomes).
4. List explicit non-goals — what this spec intentionally excludes.

For **:delta**, show only the delta to the problem framing. For **:clarify**, skip this step.

---

## Step 3: Requirements Authoring

1. Write user stories in "As a [role], I want [capability], so that [benefit]" format.
2. For each user story, write acceptance criteria as testable assertions.
3. Identify non-functional requirements: performance, security, accessibility, scalability.
4. Mark each requirement with priority: MUST, SHOULD, COULD.
5. Cross-reference against the constitution for any project-level constraints.

For **:delta**, only add/modify/remove the affected requirements. Prefix changes with
`[ADDED]`, `[MODIFIED]`, `[REMOVED]`.

For **:clarify**, list each ambiguity with the spec section reference, the ambiguous text,
and 2-3 resolution options with a recommendation.

---

## Step 4: Scope Boundaries

1. Define explicit in-scope items.
2. Define explicit out-of-scope items.
3. Identify assumptions that, if wrong, would invalidate the spec.
4. List open questions that need answers before implementation.

---

## Step 5: Write spec.md

Write the specification to `spec.md` with sections: Problem Statement, Users & Personas,
Success Criteria, Non-Goals, Functional Requirements, Non-Functional Requirements,
In Scope, Out of Scope, Assumptions, Open Questions, Acceptance Criteria.

For **:delta**, update the existing file in place. Preserve unchanged sections.
For **:clarify**, append a `## Clarifications` section or update inline with resolution markers.

---

## Step 6: Validation

1. Cross-check every acceptance criterion is testable (can be verified with a concrete test).
2. Check for contradictions between requirements.
3. Check that non-goals don't conflict with stated goals.
4. If open questions remain, present them to the user via AskUserQuestion.

---

## Output Format

```
SPECIFY COMPLETE
════════════════════════════════════════
Mode:            [:full | :delta | :clarify]
Artifact:        spec.md
Requirements:    N functional, M non-functional
Open Questions:  N remaining
Status:          READY | NEEDS_ANSWERS
════════════════════════════════════════
```

---

## Important Rules

- **Never invent requirements the user didn't ask for.** Specs capture intent, not imagination.
- **Every requirement must be testable.** If you can't write an acceptance criterion, the requirement is too vague.
- **Preserve existing spec structure in :delta mode.** Don't rewrite sections that haven't changed.
- **Flag ambiguity, don't resolve it silently.** When something is unclear, ask — don't assume.
- **Constitution overrides defaults.** If the project constitution specifies formats or constraints, follow them.
