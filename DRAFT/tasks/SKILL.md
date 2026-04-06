---
name: tasks
description: |
  Deterministic task breakdown from an implementation plan. Produces an ordered,
  dependency-aware list of implementation tasks with definition of done per task.
  No sub-roles — single-mode skill. Marks parallelizable tasks.
  Use when asked to "create tasks", "break this into tasks", "what do I do first",
  or "task list from the plan".
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

# Tasks: Deterministic Task Breakdown

You are running the `/tasks` workflow. Transform an implementation plan into an ordered
list of concrete implementation tasks.

---

## Artifact Contract

**PRODUCES:** `tasks.md` — an ordered, dependency-aware task list with definition of done
per task and parallelism annotations.

**REQUIRES:**
- `plan.md` — the implementation plan to decompose

**OPTIONAL INPUTS:**
- `tickets.md` — if tickets exist, cross-reference tasks to tickets

---

## Sub-Roles

None. This is a single-mode deterministic skill.

---

## Step 1: Read Plan

1. Read `plan.md`. If missing, stop: "No plan.md found. Run `/plan` first."
2. Read `tickets.md` if it exists — use for cross-referencing.
3. Extract the component breakdown, dependency graph, and sequencing from the plan.

---

## Step 2: Decompose Into Tasks

For each component or milestone in the plan:

1. Break it into atomic implementation tasks. Each task is a single, verifiable action:
   - Create a file
   - Implement a function or module
   - Write a test
   - Configure a service
   - Run a migration
2. Each task must have:
   - **A clear action verb** (Create, Implement, Write, Configure, Add, Update, Remove)
   - **A specific target** (file, function, endpoint, config)
   - **A definition of done (DoD)** — what proves this task is complete
3. Tasks should be small enough to complete in 15-60 minutes.

---

## Step 3: Dependency Analysis

1. For each task, identify what it depends on (other tasks that must complete first).
2. Build a dependency DAG (directed acyclic graph).
3. Detect and flag circular dependencies — these indicate a decomposition error.
4. Identify the critical path — the longest chain of sequential dependencies.

---

## Step 4: Parallelism Annotation

1. Identify tasks with no mutual dependencies that can run in parallel.
2. Group parallelizable tasks into "parallel lanes" for visualization.
3. Mark each task with one of:
   - `[SEQ]` — must wait for its dependency to complete
   - `[PAR]` — can run in parallel with other `[PAR]` tasks in the same group
   - `[START]` — no dependencies, can begin immediately

---

## Step 5: Order Tasks

1. Topological sort by dependencies.
2. Within the same dependency level, order by:
   - Foundation tasks first (data models, schemas, types)
   - Infrastructure tasks second (config, setup)
   - Implementation tasks third (business logic)
   - Test tasks fourth (but TDD tasks are paired with their implementation task)
   - Integration tasks last (wiring, E2E)
3. Number tasks sequentially.

---

## Step 6: Cross-Reference

1. If `tickets.md` exists, map each task to its parent ticket (`T-NNN`).
2. If `spec.md` requirements are referenced in the plan, trace tasks back to requirements.
3. Annotate tasks with their traceability: `[Ticket: T-001]` or `[Req: FR-3]`.

---

## Step 7: Write tasks.md

Write the task list to `tasks.md`. Structure: header with Source, Total, Critical Path,
and Parallel Lanes counts. Then phases by milestone, each task as a checkbox with:
task number, parallelism tag (`[START]`/`[PAR]`/`[SEQ]`), description, DoD, dependencies,
and ticket cross-reference if applicable.

---

## Output Format

```
TASKS COMPLETE
════════════════════════════════════════
Artifact:        tasks.md
Total Tasks:     N
Phases:          M milestones
Critical Path:   K tasks (estimated Xh)
Parallelizable:  P tasks across L lanes
Status:          READY
════════════════════════════════════════
```

---

## Important Rules

- **Never create tasks without a plan.** If `plan.md` is missing, stop and say so.
- **Every task has a DoD.** No task is complete without a verifiable definition of done.
- **Atomic tasks only.** If a task has "and" in it, it's probably two tasks.
- **Respect the dependency graph.** Never order a task before its dependencies.
- **Mark parallelism explicitly.** Implementers need to know what can run concurrently.
- **TDD pairing:** When the plan or constitution calls for TDD, pair each implementation
  task with its test task (write test first, then implement). Show them as a unit.
- **Deterministic output.** Given the same plan, this skill should produce the same tasks.
  No creativity — just faithful decomposition.
