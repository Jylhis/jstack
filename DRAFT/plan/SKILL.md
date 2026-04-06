---
name: plan
description: |
  Implementation planning skill. Transforms a specification into an actionable
  engineering plan with architecture decisions, component breakdown, and sequencing.
  Three sub-roles: :engineer (default), :architect (complex/cross-cutting),
  :devops (infrastructure focus). Use when asked to "plan this", "how should we
  build this", "create an implementation plan", or "architect this".
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

# Plan: Implementation Planning

You are running the `/plan` workflow. Transform a specification into an actionable
engineering plan.

---

## Artifact Contract

**PRODUCES:** `plan.md` — a structured implementation plan with architecture decisions,
component breakdown, dependency graph, and sequencing.

**REQUIRES:**
- `spec.md` — the specification to plan against
- Constitution (built-in project defaults or explicit `constitution/` directory)

**OPTIONAL INPUTS:**
- `research.md` — technical research, library evaluations, prior art

---

## Sub-Roles

### Auto-Detection Logic

1. Read `spec.md` and analyze the scope and nature of work.
2. If the spec involves multiple services, distributed systems, data migrations, or
   cross-cutting architectural changes: use **:architect**.
3. If the spec is primarily about infrastructure, deployment pipelines, CI/CD,
   containerization, or cloud configuration: use **:devops**.
4. Otherwise: use **:engineer** (single-service feature work, typical development).
5. The user can override by saying `/plan:engineer`, `/plan:architect`, or `/plan:devops`.

### :engineer — Standard Implementation Plan

Single-service or single-module feature work. Focus on component design, data model
changes, API contracts, and test strategy.

### :architect — Cross-Cutting Architecture Plan

Multi-service, distributed, or migration work. Adds system-level diagrams, service
interaction contracts, rollback strategy, and phased rollout plan.

### :devops — Infrastructure Plan

Infrastructure, deployment, and CI/CD work. Focus on resource provisioning, pipeline
design, monitoring, rollback procedures, and environment parity.

---

## Step 1: Read Inputs

1. Read `spec.md`. If missing, stop: "No spec.md found. Run `/specify` first."
2. Read the constitution for project-level constraints and conventions.
3. Read `research.md` if it exists — incorporate technical findings.
4. Read the existing codebase structure: `ls` the project root, read key config files
   (`package.json`, `Cargo.toml`, `pyproject.toml`, etc.) to understand the stack.

---

## Step 2: Architecture Decisions

1. List each significant decision as an ADR entry: Decision, Context, Options (2+ alternatives), Chosen (which and why).
2. For **:architect** mode, add: service boundaries, communication patterns, data ownership, consistency model.
3. For **:devops** mode, add: hosting, scaling strategy, secrets management, observability stack.

---

## Step 3: Component Breakdown

1. Identify each component/module to create or modify.
2. For each: Purpose, Interface (API/events/imports), Dependencies, Complexity (S/M/L).
3. Draw the dependency graph (text-based, using arrows).
4. For **:architect** mode, include service-level interaction patterns (sync/async, REST/gRPC/events).

---

## Step 4: Sequencing

1. Order the components by dependency — what must be built first.
2. Identify parallelizable work streams.
3. Define milestones: groups of components that together deliver a testable increment.
4. For **:architect** mode, define migration phases if applicable (dual-write, shadow,
   cutover, cleanup).
5. For **:devops** mode, define environment rollout order (dev, staging, prod).

---

## Step 5: Risk & Mitigation

1. Identify technical risks (unfamiliar libraries, complex integrations, performance
   unknowns).
2. For each risk, define a mitigation strategy or spike.
3. Identify rollback points — where can we safely revert if something goes wrong?

---

## Step 6: Test Strategy

1. Define what will be tested at each level: unit, integration, E2E.
2. Identify which acceptance criteria from `spec.md` map to which test type.
3. For **:architect** mode, define contract tests between services.
4. For **:devops** mode, define infrastructure validation tests (health checks, smoke tests).

---

## Step 7: Write plan.md

Write the plan to `plan.md` with sections: Architecture Decisions, Component Breakdown,
Dependency Graph, Sequencing & Milestones, Risk & Mitigation, Test Strategy, Open Questions.

---

## Output Format

```
PLAN COMPLETE
════════════════════════════════════════
Mode:            [:engineer | :architect | :devops]
Artifact:        plan.md
Components:      N identified
Milestones:      M defined
Risks:           R identified
Status:          READY | NEEDS_SPIKE | NEEDS_REVIEW
════════════════════════════════════════
```

---

## Important Rules

- **Never plan without a spec.** If `spec.md` is missing, stop and say so.
- **Decisions need options.** Every ADR must show at least 2 alternatives considered.
- **Sequencing respects dependencies.** Never schedule a component before its dependencies.
- **Flag unknowns as spikes.** If you don't know if something will work, say so and recommend a spike.
- **Constitution overrides defaults.** Project conventions for architecture, testing, and tooling take precedence.
- **Keep it actionable.** Every section should answer "what do I do next?" — not just "what exists."
