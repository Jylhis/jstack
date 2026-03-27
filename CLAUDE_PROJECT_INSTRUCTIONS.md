# Claude Project Instructions: jstack Research & Enhancement Guide

## What is jstack?

jstack ("Garry's Stack") is a **Claude Code skill framework + fast headless browser** that
provides an AI-native engineering workflow. It ships 29 skills covering the entire development
lifecycle: brainstorming, planning, design, coding, testing, reviewing, shipping, deploying,
monitoring, and retrospectives. The headless browser (Playwright-based, persistent Chromium
daemon) enables real-time QA, dogfooding, and visual verification.

**Current version:** 0.12.11.0 | **Runtime:** Bun >= 1.0.0 | **License:** MIT

### Core Value Proposition
A single developer with jstack + Claude Code can compress weeks of team effort into minutes.
The philosophy ("Boil the Lake") says: when AI makes marginal cost near-zero, do the complete
thing every time. Lake = achievable completeness. Ocean = multi-quarter migration (don't).

---

## Architecture Overview

### System Components

```
jstack/
├── SKILL SYSTEM (29 skills)
│   ├── Templates (.tmpl) → gen-skill-docs.ts → Generated SKILL.md
│   ├── Preamble tiers 1-4 (lightweight → comprehensive methodology)
│   ├── PreToolUse hooks (safety guardrails for /careful, /freeze, /guard)
│   └── Multi-host support: Claude Code, Codex, Kiro CLI
│
├── BROWSE ENGINE (persistent headless Chromium)
│   ├── server.ts — HTTP daemon (Bun.serve), command dispatch, 3 ring buffers
│   ├── cli.ts — Thin HTTP client, server lifecycle management
│   ├── browser-manager.ts — Chromium state machine, ref map, tab management
│   ├── snapshot.ts — Accessibility tree → ref-based element selection
│   ├── commands.ts — Single source of truth: 41 commands (read/write/meta)
│   └── activity.ts — SSE stream for Chrome extension sidebar
│
├── TEST & EVAL INFRASTRUCTURE
│   ├── session-runner.ts — Spawns `claude -p` as subprocess, NDJSON parsing
│   ├── llm-judge.ts — Claude-as-judge for doc quality + planted-bug detection
│   ├── eval-store.ts — Result persistence, auto-comparison, trend analysis
│   ├── touchfiles.ts — Diff-based test selection (only run what changed)
│   └── skill-parser.ts — Static validation of SKILL.md against command registry
│
├── CI/CD (GitHub Actions on Ubicloud runners)
│   ├── 12 parallel E2E eval suites per PR
│   ├── Docker image with pre-baked Playwright + Chromium
│   ├── Gate (blocks merge) vs Periodic (weekly) test tiers
│   └── SKILL.md freshness checks
│
└── CONFIG & TELEMETRY
    ├── ~/.jstack/config.yaml — User preferences (proactive, telemetry, prefix)
    ├── Repo mode detection (solo vs collaborative from git history)
    ├── Session tracking, analytics, update checks
    └── Skill prefix system (short names vs namespaced)
```

### Skill Workflow Chain

```
/office-hours (brainstorm) → /plan-ceo-review → /plan-eng-review → /plan-design-review
    ↓                                    ↓
/autoplan (auto-runs all reviews)   Development
    ↓                                    ↓
/investigate (debug)              /qa or /qa-only (test)
    ↓                                    ↓
/design-review (visual audit)     /review (PR review)
    ↓                                    ↓
/codex (second opinion)           /ship (auto: test + PR + version bump)
    ↓                                    ↓
/cso (security audit)            /land-and-deploy (merge + deploy + verify)
    ↓                                    ↓
/benchmark (perf regression)      /canary (post-deploy monitoring)
    ↓                                    ↓
/retro (retrospective)           /document-release (update docs)
```

Safety overlay (orthogonal): `/careful` + `/freeze` + `/guard`

### Key Design Patterns

1. **Template-driven docs**: SKILL.md.tmpl → gen-skill-docs.ts → SKILL.md. Templates use
   `{{PLACEHOLDERS}}` resolved from source code (commands.ts, snapshot.ts).

2. **Preamble tiers**: Skills inject methodology context at 4 levels. Tier 1 = minimal
   (browse, benchmark). Tier 4 = full execution framework (ship, review, qa).

3. **Ref-based interaction**: Snapshot assigns `@e1, @e2...` refs to DOM elements.
   Later commands (`click @e3`, `fill @e4 "text"`) resolve via stored Playwright locators.

4. **Persistent daemon**: Browse server starts once (~3s), then ~100-200ms per command.
   State persists: cookies, tabs, sessions. Auto-shutdown after 30min idle.

5. **Atomic commits**: Multi-stage workflows commit each fix separately for bisectability.

6. **Platform-agnostic**: Skills never hardcode framework commands. Read CLAUDE.md for
   project config, ask user if missing, persist answer.

---

## Research Directions

When researching how to extend jstack, investigate these areas:

### 1. Claude Code Skill System
- **Official docs**: Search for "Claude Code custom skills" and "Claude Code SKILL.md format"
- **Frontmatter schema**: name, preamble-tier, version, description, allowed-tools, hooks
- **Hook system**: PreToolUse hooks intercept tool calls (Edit, Write, Bash) before execution
- **Key constraint**: Each bash code block runs in a separate shell. Variables don't persist
  between blocks. Use natural language for state management between steps.
- **allowed-tools whitelist**: Skills can restrict which tools Claude uses (Bash, Read, Write,
  Edit, Glob, Grep, WebSearch, Agent, AskUserQuestion, etc.)

### 2. Browse Engine Internals
- **Command registry** (`browse/src/commands.ts`): 41 commands across 3 categories.
  Adding a new command means: add to registry, implement handler, rebuild docs.
- **Snapshot system** (`browse/src/snapshot.ts`): Uses `page.locator().ariaSnapshot()` for
  accessibility tree. 8 flags: -i (interactive), -c (compact), -d (depth), -s (selector),
  -D (diff), -a (annotate), -o (output), -C (cursor-interactive).
- **Buffer architecture**: 3 CircularBuffers (console, network, dialog) with 5000 capacity,
  async disk flush. Privacy filtering on network bodies.
- **Activity stream**: SSE for Chrome extension sidebar. Events: command_start, command_end,
  navigation, error. Gap detection for client reconnects.

### 3. Playwright & Browser Automation (2025-2026 state of the art)
- Research: "Playwright accessibility snapshot" — the core of jstack's ref system
- Research: "Playwright aria snapshot testing" for structured accessibility assertions
- Research: "Headless browser AI agent" patterns (how other tools solve this)
- Research: "Browser Use", "Stagehand", "Skyvern" for competitive approaches
- Research: "Playwright MCP server" — official Playwright integration with AI agents

### 4. Multi-AI Architecture
- jstack already integrates Codex (OpenAI) and Gemini alongside Claude
- Research: "Multi-agent AI code review" and "AI agent orchestration patterns"
- Research: "Codex CLI integration" and "Gemini CLI tool use"
- The `/codex` skill runs Codex as a second-opinion reviewer with challenge/consult modes

### 5. Eval & Testing Patterns
- **LLM-as-judge**: Claude scores doc quality (clarity, completeness, actionability 1-5)
  and detects planted bugs (detection_rate, false_positives, evidence_quality)
- **Diff-based selection**: touchfiles.ts maps tests to file dependencies. Only changed
  files trigger their associated tests. Global touchfiles trigger everything.
- **Session runner**: Spawns `claude -p` as subprocess with NDJSON streaming. Tracks cost,
  latency (firstResponseMs, maxInterTurnMs), and tool call transcripts.
- Research: "LLM evaluation frameworks 2025" and "AI agent testing patterns"

---

## Extension Opportunities

### Adding a New Skill

1. Create directory: `skill-name/SKILL.md.tmpl`
2. Add frontmatter (name, preamble-tier, version, description, allowed-tools)
3. Write template using `{{PREAMBLE}}` and natural language logic
4. Register in `scripts/gen-skill-docs.ts` if it needs special placeholders
5. Run `bun run gen:skill-docs` to generate SKILL.md
6. Add symlink in `setup` script
7. Add E2E test in `test/skill-e2e-*.test.ts` with touchfiles entry
8. Classify as `gate` or `periodic` in E2E_TIERS

### Adding a Browse Command

1. Add to `browse/src/commands.ts` (category, description, usage)
2. Implement handler in appropriate file (read-commands.ts, write-commands.ts, meta-commands.ts)
3. Run `bun run build` (regenerates docs automatically)
4. Add integration test in `browse/test/commands.test.ts`

### Adding a Snapshot Flag

1. Add to `SNAPSHOT_FLAGS` array in `browse/src/snapshot.ts`
2. Implement in snapshot parsing logic
3. Run `bun run build`
4. Add test in `browse/test/snapshot.test.ts`

### Improving Eval Coverage

1. Add test to `test/skill-e2e-*.test.ts` (or create new category file)
2. Register file dependencies in `test/helpers/touchfiles.ts`
3. Classify tier: `gate` (deterministic, safety) or `periodic` (quality, non-deterministic)
4. Add ground truth fixtures in `test/fixtures/` if needed
5. Keep fixture extracts small (60 lines, not full SKILL.md copies)

---

## Technical Constraints & Gotchas

### Must-Know Rules
- **NEVER commit browse/dist/** — tracked by git mistake, ~58MB Mach-O arm64 binaries
- **NEVER `git add .` or `git add -A`** — always add specific files by name
- **NEVER edit SKILL.md directly** — edit .tmpl, run gen:skill-docs
- **NEVER resolve SKILL.md merge conflicts manually** — regenerate from templates
- **NEVER copy full SKILL.md into test fixtures** — extract only needed sections
- **Bisect commits** — every commit = one logical change, independently revertable
- **E2E failures need proof** — never claim "pre-existing" without running on main branch

### Build & Runtime
- Bun is required (not Node.js) for build, test, and CLI
- Windows uses Node.js for Chromium launch (Bun issue #4253 workaround)
- Playwright Chromium must be installed (`npx playwright install chromium`)
- Browse binary is platform-specific (compiled per-platform by setup script)

### Config Locations
- `~/.jstack/config.yaml` — user preferences
- `~/.jstack/sessions/` — active session tracking
- `~/.jstack/analytics/` — usage telemetry (jsonl)
- `~/.jstack/projects/$SLUG/` — per-project eval results, repo mode cache
- `~/.jstack-dev/plans/` — local vision docs (not checked in)
- `.jstack/browse.json` — per-project browse server state (port, token, PID)

### Template Authoring Rules
- Use natural language for logic and state between bash blocks
- Don't hardcode branch names — detect dynamically
- Keep bash blocks self-contained
- Express conditionals as English, not nested if/elif/else
- Use `{{BASE_BRANCH_DETECT}}` for PR-targeting skills

---

## Enhancement Ideas to Research

### Near-term (lake-sized)
1. **New browse commands**: `$B ai-fill` (auto-fill forms using page context), `$B record`
   (record interaction sequences for replay), `$B audit-a11y` (full WCAG audit)
2. **Skill composition**: Allow skills to invoke other skills programmatically (not just suggest)
3. **Smarter test selection**: Use AST-level dependency analysis instead of file-level touchfiles
4. **Cost dashboard**: Real-time cost tracking across skill invocations with budget alerts
5. **Parallel skill execution**: Run /plan-ceo-review + /plan-eng-review + /plan-design-review
   concurrently instead of sequentially through /autoplan

### Medium-term (research required)
6. **Visual regression testing**: Integrate screenshot diffing into /qa and /design-review
   (research: Percy, Chromatic, Playwright visual comparisons)
7. **Browser session sharing**: Export/import full browser state for team collaboration
8. **Custom eval rubrics**: Let users define project-specific LLM-judge criteria
9. **Skill marketplace**: Community-contributed skills with versioning and discovery
10. **Streaming cost optimization**: Token-aware prompt truncation for E2E tests

### Long-term (first-principles research)
11. **Self-improving skills**: Use eval results to auto-tune skill prompts over time
12. **Cross-project learning**: Aggregate patterns from retro/analytics across projects
13. **Predictive QA**: Use commit history + code analysis to predict where bugs will appear
14. **Native browser AI**: Move from snapshot→ref→command pattern to direct vision-model
    interaction with screenshots (research: Claude computer use, GPT-4V browsing)

---

## Key Files Reference

| File | Purpose | When to Read |
|------|---------|-------------|
| `ETHOS.md` | Builder philosophy | Understanding design decisions |
| `CHANGELOG.md` | Release history | Understanding feature evolution |
| `scripts/gen-skill-docs.ts` | Template engine | Adding placeholders or skills |
| `browse/src/commands.ts` | Command registry | Adding browse commands |
| `browse/src/snapshot.ts` | Snapshot flags | Adding annotation features |
| `browse/src/server.ts` | HTTP daemon | Understanding command dispatch |
| `browse/src/browser-manager.ts` | Chromium lifecycle | Understanding state management |
| `test/helpers/touchfiles.ts` | Test dependencies | Adding/modifying tests |
| `test/helpers/session-runner.ts` | E2E harness | Understanding eval infrastructure |
| `test/helpers/eval-store.ts` | Result persistence | Understanding eval comparison |
| `test/helpers/llm-judge.ts` | Quality scoring | Understanding eval criteria |
| `setup` | Installation script | Understanding multi-platform setup |
| `bin/jstack-config` | Config manager | Understanding user preferences |
| `bin/jstack-repo-mode` | Solo vs collaborative | Understanding behavior adaptation |

---

## Development Workflow

```bash
# Setup
bun install
./setup                         # Build binary + symlink skills

# Develop
bun run dev <command>           # Test browse commands in dev mode
bun run dev:skill               # Watch mode: auto-regen + validate on change
bun run skill:check             # Health dashboard for all skills

# Test
bun test                        # Free tests (<2s) — run before every commit
bun run eval:select             # Preview which E2E tests would run
bun run test:evals              # Paid evals (~$4/run) — run before shipping

# Build
bun run gen:skill-docs          # Regenerate SKILL.md from templates
bun run build                   # Full build: docs + binaries

# Analyze
bun run eval:list               # List all eval runs
bun run eval:compare            # Compare two runs (auto-picks recent)
bun run eval:summary            # Aggregate stats across runs
bun run analytics               # Usage analytics
```

---

## Competitive Landscape (Research These)

| Tool | Relation to jstack | Research Query |
|------|-------------------|----------------|
| Playwright MCP Server | Browse alternative | "playwright mcp server AI agent" |
| Browser Use | Browse competitor | "browser-use python AI agent" |
| Stagehand | Browse competitor | "stagehand AI web automation" |
| Skyvern | Browse competitor | "skyvern AI browser automation" |
| Cursor | Overall competitor | "cursor AI IDE workflow" |
| Windsurf | Overall competitor | "windsurf AI coding" |
| Aider | CLI competitor | "aider AI coding assistant" |
| Claude Code | Platform | "claude code skills custom" |
| OpenAI Codex CLI | Multi-AI | "openai codex CLI tool" |
| Gemini CLI | Multi-AI | "google gemini CLI coding" |
| Devin | Agent competitor | "devin AI software engineer" |

---

## Philosophy Reminders

- **Completeness is cheap** when AI does the work. Do the whole thing.
- **Search before building.** Three layers: tried-and-true, new-and-popular, first-principles.
  Prize first-principles (Layer 3) above all.
- **Build for yourself.** Best tools solve your own problem. Specificity > hypothetical generality.
- **Lake vs ocean.** Lake = achievable (boil it). Ocean = multi-quarter (don't).
- **Prove it or don't say it.** No "pre-existing" claims without running on main branch.
- **Bisect everything.** One logical change per commit. Independently revertable.
