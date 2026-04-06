---
name: implement
description: |
  Implementation execution skill. Works through a task list producing code and tests.
  Four sub-roles: :fullstack (default), :frontend, :backend, :infra. Auto-detects
  from the files being touched. Enforces TDD behavioral pattern unless the project
  constitution overrides it. Use when asked to "implement this", "build it",
  "start coding", "work on the tasks", or "execute the plan".
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

# Implement: Task Execution

You are running the `/implement` workflow. Execute the task list, producing code and tests
for each task in dependency order.

---

## Artifact Contract

**PRODUCES:** Code files + test files (no single artifact file — output is the codebase itself).

**REQUIRES:**
- `tasks.md` — the ordered task list to execute

**READS (for context, does not modify):**
- `spec.md` — requirements and acceptance criteria
- `plan.md` — architecture decisions and component design
- Constitution — project conventions, coding standards, test requirements

---

## Sub-Roles

### Auto-Detection Logic

For each task being implemented, detect the sub-role from the files involved:

1. If the task touches UI files (`.tsx`, `.jsx`, `.vue`, `.svelte`, `.html`, `.css`,
   components/, pages/, layouts/, templates/): use **:frontend**.
2. If the task touches API/server files (routes/, controllers/, models/, migrations/,
   `server.`, `api.`, database schemas): use **:backend**.
3. If the task touches infrastructure files (`Dockerfile`, `docker-compose`, `*.tf`,
   `*.nix`, `k8s/`, `.github/workflows/`, `Makefile`, CI/CD config): use **:infra**.
4. If the task touches multiple layers or none of the above clearly match: use **:fullstack**.
5. The user can override by saying `/implement:frontend`, `/implement:backend`,
   `/implement:infra`, or `/implement:fullstack`.

Sub-role can change between tasks — re-detect for each task.

### :fullstack — Works across all layers. Default when tasks span multiple layers.
### :frontend — UI components, styling, accessibility, state management, rendering.
### :backend — API endpoints, business logic, data access, validation, transactions.
### :infra — Config, deployment, CI/CD, containerization, secrets, environment parity.

---

## TDD Behavioral Pattern

**All sub-roles enforce TDD unless the project constitution explicitly overrides it.**

For each implementation task:

1. **Red:** Write the test first. The test should fail because the implementation
   does not exist yet. Run the test and confirm it fails.
2. **Green:** Write the minimal implementation to make the test pass. Run the test
   and confirm it passes.
3. **Refactor:** Clean up the implementation without changing behavior. Run the test
   and confirm it still passes.

If the constitution specifies a different testing approach (e.g., "test after", "no unit
tests, only integration"), follow the constitution.

---

## Step 1: Read Task List

1. Read `tasks.md`. If missing, stop: "No tasks.md found. Run `/tasks` first."
2. Read `spec.md` and `plan.md` for context.
3. Read the constitution for coding conventions, test framework, and project structure.
4. Identify the first unchecked task (or the task the user specified).

---

## Step 2: Pre-Task Checkpoint

Before starting each task:

1. Verify all dependency tasks are complete (checked off in `tasks.md`).
2. If a dependency is incomplete, stop: "Task N depends on Task M which is not done."
3. Read the task's DoD to understand what "done" means.
4. Identify the sub-role for this task via auto-detection.

---

## Step 3: Implement Task (TDD Cycle)

For each task, follow the TDD cycle:

1. **Red:** Write a test asserting the expected behavior from the DoD. Run it. Confirm it fails.
2. **Green:** Write the minimal code to pass the test. Run it. Confirm it passes. Run the full
   suite to check for regressions.
3. **Refactor:** Clean up without changing behavior. Confirm all tests still pass.

---

## Step 4: Mark Complete & Continue

1. Update `tasks.md`: check off the completed task `- [x]`.
2. If more tasks remain, return to Step 2 for the next task.
3. If the user asked to implement a specific task (not "all"), stop after that task.
4. If all tasks are complete, proceed to the completion report.

---

## Step 6: Completion Report

After all requested tasks are done:

1. Run the full test suite. Paste the output.
2. Cross-reference completed tasks against `spec.md` acceptance criteria.
3. Identify any acceptance criteria not yet covered.

```
IMPLEMENT COMPLETE
════════════════════════════════════════
Mode:            [:fullstack | :frontend | :backend | :infra]
Tasks Completed: N / M
Tests Written:   T (P passing, F failing)
Files Changed:   C files across D directories
Acceptance Criteria Coverage: X / Y covered
Status:          DONE | IN_PROGRESS | BLOCKED
════════════════════════════════════════
```

---

## Important Rules

- **Never implement without tasks.** If `tasks.md` is missing, stop and say so.
- **TDD is default.** Write tests first unless the constitution says otherwise.
- **One task at a time.** Complete and verify each task before starting the next.
- **Respect dependency order.** Never skip ahead past incomplete dependencies.
- **Run tests after every change.** No silent failures. Paste test output.
- **Minimal implementation.** Write the least code that satisfies the DoD. Don't gold-plate.
- **Update tasks.md as you go.** The task list is the source of truth for progress.
- **If stuck, ask.** If a task's DoD is ambiguous or you hit an unexpected blocker,
  use AskUserQuestion rather than guessing.
