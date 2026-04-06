---
name: ticket
description: |
  Ticket creation and refinement skill. Breaks down tasks into well-structured
  sub-tickets or adds detail to existing ticket descriptions. Two sub-roles:
  :breakdown (parse into sub-tickets) and :refine (add detail to existing).
  Not auto-triggered — requires explicit invocation via /ticket.
  Use when asked to "create tickets", "break this down", "write tickets for this",
  or "refine this ticket".
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

# Ticket: Structured Ticket Authoring

You are running the `/ticket` workflow. This skill is **explicitly invoked only** — it
does not auto-trigger from other workflows.

---

## Artifact Contract

**PRODUCES:** `tickets.md` — a structured set of tickets with descriptions, acceptance
criteria, and sizing.

**REQUIRES:**
- Task description (from the user's message or referenced context)

**OPTIONAL INPUTS:**
- Constitution (for project conventions on ticket format)
- `spec.md` — specification for context on requirements
- `audit.md` — audit findings that may need ticketing

---

## Sub-Roles

This skill does NOT auto-detect sub-roles. The user must specify, or the default is
determined by whether `tickets.md` already exists.

### :breakdown — Parse Into Sub-Tickets

Takes a high-level task description and breaks it into discrete, implementable sub-tickets.
Each sub-ticket should be completable in a single work session.

### :refine — Add Detail to Existing

Takes existing rough tickets (from `tickets.md` or user input) and adds acceptance criteria,
technical notes, edge cases, and sizing.

**Default behavior:** If `tickets.md` exists, default to **:refine**. If it does not exist,
default to **:breakdown**.

---

## Step 1: Gather Context

1. Read the user's task description or referenced material.
2. Read `tickets.md` if it exists (determines default sub-role).
3. Read `spec.md` if it exists — use for requirements context.
4. Read `audit.md` if it exists — flag audit findings that need tickets.
5. Read the constitution for ticket format conventions (if any).

---

## Step 2: Analyze Scope (:breakdown)

For **:breakdown** mode:

1. Identify the top-level objective.
2. Decompose into logical work units. Each ticket should:
   - Be independently implementable (no hidden dependencies within a ticket)
   - Be completable in a single focused session (2-4 hours of work)
   - Have a clear definition of done
3. Identify dependencies between tickets — which must come before which.
4. Group related tickets into epics or themes if there are more than 5.

---

## Step 3: Refine Tickets (:refine)

For **:refine** mode:

1. Read existing tickets from `tickets.md` or user input.
2. For each ticket, add or improve:
   - **Description:** Clear statement of what needs to happen
   - **Acceptance Criteria:** Testable conditions for "done"
   - **Technical Notes:** Implementation hints, relevant files, gotchas
   - **Edge Cases:** What could go wrong, boundary conditions
   - **Size:** S (< 1h), M (1-4h), L (4-8h), XL (needs further breakdown)
3. Flag any XL tickets for further breakdown.

---

## Step 4: Dependency Ordering

1. Map dependencies between tickets (which blocks which).
2. Identify tickets that can be worked in parallel.
3. Suggest an implementation order that respects dependencies.
4. Flag circular dependencies as errors — these indicate the breakdown is wrong.

---

## Step 5: Write tickets.md

Write tickets to `tickets.md`. Each ticket gets a `T-NNN` prefix and includes: Size
(S/M/L), Depends on, Description, Acceptance Criteria (checkboxes), Technical Notes,
Edge Cases. Group into epics if more than 5 tickets.

---

## Output Format

```
TICKETS COMPLETE
════════════════════════════════════════
Mode:            [:breakdown | :refine]
Artifact:        tickets.md
Total Tickets:   N
By Size:         S: X, M: Y, L: Z
Parallelizable:  N tickets can start immediately
Blocked:         M tickets waiting on dependencies
Status:          READY | NEEDS_BREAKDOWN (XL tickets exist)
════════════════════════════════════════
```

If any tickets are sized XL, recommend running `/ticket:breakdown` on those specific tickets.

---

## Important Rules

- **Not auto-triggered.** This skill only runs when explicitly invoked via `/ticket`.
- **One session per ticket.** If a ticket would take more than one focused session, break it down further.
- **Acceptance criteria are mandatory.** Every ticket must have at least one testable criterion.
- **Dependencies must be explicit.** Never leave implicit ordering — state it or mark "none".
- **Don't invent work.** Only create tickets for what the user asked about. Don't add "nice to have" tickets without flagging them as optional.
- **XL means break it down.** Any ticket sized XL is a signal, not a valid size for implementation.
