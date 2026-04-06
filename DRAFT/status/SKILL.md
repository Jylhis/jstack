---
name: status
description: |
  Project status utility skill. Reads all available artifacts and git state to produce
  a concise status summary. No sub-roles. No file artifact produced — output is
  displayed directly. Referenced by flows 4 (tasks), 5 (implement), 9, and 10.
  Use when asked "where are we", "what's the status", "what's done", "what's next",
  "what's blocked", or "give me a summary".
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

# Status: Project Status Summary

You are running the `/status` workflow. Produce a concise summary of where the project
stands right now. This is a read-only utility — it produces output, not files.

---

## Artifact Contract

**PRODUCES:** Status summary (displayed directly, no file artifact written).

**REQUIRES:** Nothing — works with whatever artifacts exist.

**READS (opportunistically):**
- `tasks.md` — task completion progress
- `plan.md` — milestone definitions and sequencing
- `spec.md` — requirements and acceptance criteria
- `tickets.md` — ticket status if present
- Git status and log — branch state, recent commits, uncommitted changes
- Any other project artifacts that indicate progress

---

## Sub-Roles

None. Single-mode utility skill.

---

## Step 1: Scan Artifacts

Detect which project artifacts exist. Check for each of these:

1. `spec.md` — specification exists?
2. `plan.md` — implementation plan exists?
3. `tickets.md` — tickets exist?
4. `tasks.md` — task list exists?
5. Constitution directory — project conventions defined?
6. `brainstorm.md`, `research.md`, `validation.md` — early-phase artifacts?

Note which exist and which are missing. Missing artifacts indicate workflow phases
that have not been run yet.

---

## Step 2: Task Progress

If `tasks.md` exists:

1. Count total tasks, completed tasks (`- [x]`), and remaining tasks (`- [ ]`).
2. Identify the current task — the first unchecked task whose dependencies are all met.
3. Identify blocked tasks — unchecked tasks whose dependencies are not met.
4. Calculate completion percentage.
5. Identify the current phase/milestone.

If `tasks.md` does not exist, report: "No task list yet. Run `/tasks` to create one."

---

## Step 3: Git State

1. Run `git branch --show-current` to identify the branch.
2. Run `git status` (never use `-uall`) to check for uncommitted changes.
3. Run `git log --oneline -5` to show recent commits.
4. If on a feature branch, run `git log main..HEAD --oneline` (or equivalent base branch)
   to show branch-specific commits.

---

## Step 4: Blockers Detection

Scan for indicators of blocked progress:

1. Tasks marked as blocked or with unmet dependencies in `tasks.md`.
2. Open questions in `spec.md` or `plan.md` (sections titled "Open Questions").
3. Failing tests: run the project's test command if defined in the constitution or
   CLAUDE.md. If no test command is known, skip this check.
4. Uncommitted changes that may indicate work in progress.

---

## Step 5: Output Summary

Display the status in this format:

```
PROJECT STATUS
════════════════════════════════════════
Branch:          [current branch]
Phase:           [Specify | Plan | Tasks | Implement | Review | Ship]
Artifacts:       [list of existing artifacts]

PROGRESS
────────────────────────────────────────
Tasks:           X / Y complete (Z%)
Current Task:    Task N — [description]
Current Phase:   [Milestone name]
Blocked:         [N tasks blocked | "none"]

RECENT ACTIVITY
────────────────────────────────────────
[Last 5 commits, one per line]
[Uncommitted changes summary if any]

WHAT'S NEXT
────────────────────────────────────────
[1-3 bullet points: the immediate next actions]

BLOCKERS
────────────────────────────────────────
[List of blockers, or "None identified"]
════════════════════════════════════════
```

Adapt the output based on what artifacts exist. If only `spec.md` exists, the phase is
"Specify complete, ready for /plan". If nothing exists, suggest "Start with /specify or
/brainstorm".

---

## Important Rules

- **Read-only.** Never modify any files. This skill only reads and reports.
- **Fast.** This should complete in seconds. Don't run expensive operations.
- **Honest.** Report what is, not what should be. If things are behind, say so.
- **Actionable.** The "What's Next" section must contain concrete next steps, not vague advice.
- **Graceful degradation.** Works with zero artifacts (reports "nothing started") through
  full artifact set (reports detailed progress). Never error on missing files.
- **No file output.** Do not write a status file. Output is displayed directly to the user.
