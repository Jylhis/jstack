# Artifact System

Every phase declares what it produces and what it requires.
Phases cannot run if required artifacts are missing.

---

## Artifact Catalog

| Artifact | File | Produced by | Consumed by | Format |
|----------|------|-------------|-------------|--------|
| Built-in Constitution | (embedded in jstack) | jstack itself | All phases | Markdown principles |
| Project Constitution | `constitution.md` | `/constitution` | All phases (merged with built-in) | Markdown: principles + governance + overrides |
| Brainstorm Notes | `brainstorm.md` | `/brainstorm` | `/specify`, `/validate`, `/research` | Markdown: problem reframe, alternatives, decisions |
| Research Document | `research.md` | `/research` | `/validate`, `/specify`, `/plan` | Markdown: structured analysis with sources |
| Validation Report | `validation.md` | `/validate` | `/specify`, `/plan`, user decision | Markdown: unit economics, risk matrix, go/no-go |
| Feature Spec | `spec.md` | `/specify` | `/plan`, `/tasks`, `/review`, `/qa` | Markdown: user stories, FRs, acceptance scenarios, edge cases |
| Implementation Plan | `plan.md` | `/plan` | `/tasks`, `/implement`, `/review` | Markdown: architecture, data flow, test strategy, risks |
| Task Breakdown | `tasks.md` | `/tasks` | `/implement`, `/status`, `/dashboard` | Markdown: ordered tasks with dependencies, DoD per task |
| Tickets | `tickets.md` | `/ticket` | `/plan`, `/tasks`, `/implement` | Markdown: scoped tickets with DoD, acceptance criteria |
| Audit Report | `audit.md` | `/audit` | `/onboard`, `/constitution` | Markdown: architecture map, tech debt, test health, risks |
| Review Report | `review.md` | `/review` | `/respond`, `/second-opinion` | Markdown: categorized findings (must-fix, should, nit, question) |
| Second Opinion | `second-opinion.md` | `/second-opinion` | user decision | Markdown: agreement, conflicts, blind spots |
| QA Report | `qa.md` | `/qa` | `/implement` (fixes), `/ship` | Markdown: test results, bugs found, regression tests created |
| Retro Report | `retro.md` | `/retro` | `/dashboard`, user reflection | Markdown: metrics, velocity, test health, observations |
| Git Flow Config | `git-flow.md` | `/git-flow` | `git-discipline` behavioral skill | Markdown: branch strategy, commit conventions, merge policy |
| Deploy Record | `deploy.md` | `/ship` | `/retro`, `/dashboard`, telemetry | Markdown: what was deployed, where, verification status |

---

## Artifact Storage Modes

| Mode | Location | When |
|------|----------|------|
| Personal KB (default) | `$XDG_DATA_HOME/jstack/projects/<project-name>/` | Most work. Keeps project repo clean. |
| Project-local (opt-in) | `<project-root>/.jstack/` | When artifacts should be committed and shared with team. |

---

## Dependency Graph

Arrows mean "requires." Dashed arrows mean "benefits from but does not require."

```
                    ┌──────────────────┐
                    │ Built-in         │
                    │ Constitution     │
                    └────────┬─────────┘
                             │ (always available)
                             ▼
    ┌────────────┐    ┌──────────────┐    ┌───────────┐
    │/brainstorm │    │/constitution │    │/audit     │
    │            │    │ (optional)   │    │           │
    └─────┬──────┘    └──────┬───────┘    └─────┬─────┘
          │                  │                   │
          │ brainstorm.md    │ constitution.md   │ audit.md
          ▼                  ▼                   ▼
    ┌───────────┐    ┌──────────────┐    ┌───────────┐
    │/research  │    │   Merged     │    │/onboard   │
    └─────┬─────┘    │ Constitution │    └─────┬─────┘
          │          │ (built-in +  │          │
          │          │  project)    │     populates ──► spec.md,
          │          └──────┬───────┘                   plan.md,
          │                 │                           constitution.md
    ┌─────▼─────┐           │
    │/validate  │           │
    └─────┬─────┘           │
          │                 │
          ▼                 ▼
    ┌─────────────────────────────┐
    │/specify                     │
    │  REQUIRES: constitution     │
    │  OPTIONAL: brainstorm.md,   │
    │    research.md, validate.md │
    └─────────────┬───────────────┘
                  │ spec.md
                  ▼
    ┌─────────────────────────────┐
    │/plan                        │
    │  REQUIRES: spec.md,         │
    │           constitution      │
    │  OPTIONAL: research.md      │
    └─────────────┬───────────────┘
                  │ plan.md
                  ▼
    ┌─────────────────────────────┐
    │/tasks                       │
    │  REQUIRES: plan.md          │
    │  OPTIONAL: tickets.md       │
    └─────────────┬───────────────┘
                  │ tasks.md
                  ▼
    ┌─────────────────────────────┐
    │/implement                   │
    │  REQUIRES: tasks.md         │
    │  READS: spec.md, plan.md,   │
    │         constitution        │
    └─────────────┬───────────────┘
                  │ code + tests
                  ▼
    ┌──────────┐     ┌───────────────┐
    │/review   │────►│/second-opinion│
    └────┬─────┘     └───────┬───────┘
         │                   │
         ▼                   ▼
    ┌─────────┐    ┌──────────┐
    │/qa      │    │/respond  │
    └────┬────┘    └──────────┘
         │
         ▼
    ┌─────────┐
    │/ship    │
    └────┬────┘
         │
         ▼
    ┌─────────┐
    │/retro   │
    └─────────┘
```
