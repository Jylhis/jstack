# AI Work Setups & Spec-Driven Development — Landscape Research (2026-04-05)

Claude Opus 4.6 Research

## The Closest Comparables to jstack

### 1. obra/superpowers — Most similar in spirit

An agentic skills framework for Claude Code with composable SKILL.md-based skills. Structured
workflow: Socratic brainstorming → spec → implementation plan → TDD → parallel sub-agents → code
review. Like jstack, it's opinionated about *how* the agent works, not just *what* it builds. Key
difference: superpowers focuses on a single dev methodology; jstack has a broader toolkit (QA,
deploy, security, retrospectives, design review).

- [GitHub: obra/superpowers](https://github.com/obra/superpowers)

### 2. GitHub Spec Kit — The "official" SDD framework

Open-source toolkit (84k+ stars) with a 4-phase workflow: **Specify → Plan → Tasks → Implement**.
Works with 24+ agents (Copilot, Claude Code, Gemini CLI). More generic/unopinionated than jstack —
it provides scaffolding for specs but doesn't ship ready-made workflows like `/ship`, `/qa`, `/cso`.

- [GitHub: github/spec-kit](https://github.com/github/spec-kit)
- [GitHub Blog: Spec-driven development with
  AI](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)

### 3. AWS Kiro — Spec-driven IDE with agent hooks

Full IDE (not just a skill pack) with built-in SDD, Agent Hooks (event-driven automations on file
save/create/delete), and an autonomous agent that works asynchronously across repos. Powered by
Claude Sonnet via Bedrock. The Agent Hooks concept is similar to jstack's hook system but at the IDE
level.

- [kiro.dev](https://kiro.dev/)
- [AWS: Kiro Agentic AI
  IDE](https://repost.aws/articles/AROjWKtr5RTjy6T2HbFJD_Mw/%F0%9F%91%BB-kiro-agentic-ai-ide-beyond-a-coding-assistant-full-stack-software-development-with-spec-driven-ai)

### 4. BMAD Method — Heavyweight multi-agent SDD

"Breakthrough Method for Agile AI-Driven Development" — 21 specialized AI agents, 50+ guided
workflows. Dedicated Analyst, PM, Architect, Scrum Master, and Dev agents. The most process-heavy
framework. Like jstack's `/plan-ceo-review` → `/plan-eng-review` → `/plan-design-review` pipeline
but taken to an extreme with formal agile ceremonies.

- [GitHub: bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)
- [BMAD Docs](https://docs.bmad-method.org/)

### 5. Cursor Automations — Event-driven agent workflows

Not a skill system — it's an always-on platform where AI agents trigger from GitHub PRs, Slack
messages, Linear issues, PagerDuty alerts, cron schedules. Agents run in cloud sandboxes with MCP
tools. Similar to jstack's `/schedule` and `/canary` concepts but fully cloud-hosted and
event-driven.

- [TechCrunch: Cursor's new agentic coding
  system](https://techcrunch.com/2026/03/05/cursor-is-rolling-out-a-new-system-for-agentic-coding/)
- [Cursor Automations deep dive](https://www.adwaitx.com/cursor-automations-ai-coding-agents/)

---

## The Broader Ecosystem

| Category | Tools | jstack equivalent |
|---|---|---|
| **Skill marketplaces** | [awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills), [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) (1340+ skills), [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) (220+) | jstack ships ~25 curated, tested skills |
| **SDD frameworks** | Spec Kit, Kiro, BMAD, GSD, OpenSpec | jstack's plan review pipeline (`/autoplan`) |
| **CI-like agent automation** | Cursor Automations, Kiro Agent Hooks | jstack's `/ship` → `/land-and-deploy` → `/canary` |
| **Security audit** | Various one-off skills | jstack's `/cso` (OWASP + STRIDE) |
| **QA/browser testing** | Playwright-based skills, browser MCP tools | jstack's `/browse` + `/qa` + `/design-review` |

---

## Spec-Driven Development (SDD) — Core Concept

In spec-driven development, you start with a specification — a contract for how your code should
behave that becomes the source of truth your tools and AI agents use to generate, test, and validate
code. The key insight is that specifications become executable artifacts, not just planning
documents that get ignored — they drive implementation and validate results.

### Why It Works

Language models are exceptional at pattern completion, but not at mind reading. By providing a clear
specification up front, along with a technical plan and focused tasks, the coding agent has more
clarity, improving its overall efficacy — it knows what to build, how to build it, and in what
sequence.

### The Standard Workflow

1. **Specify** — describe goals and user journeys; the agent drafts a detailed spec
2. **Plan** — declare architecture, stack, and constraints; the agent proposes a technical plan
3. **Tasks** — the agent breaks work into small, reviewable units
4. **Implement** — the agent tackles tasks while you verify at each checkpoint

### Key Distinction

- **Prompt engineering**: ad-hoc conversational interactions, suited for exploration/prototyping
- **Spec-driven development**: formal, structured specifications as source of truth, suited for
  production systems
- **CLAUDE.md / AGENTS.md files**: the low-tech version of SDD that many developers already use
  without calling it spec-driven development

### Adoption

Spec-driven development emerged as one of 2025's most important new engineering practices (per
Thoughtworks Technology Radar). More than 30 frameworks now power agentic coding workflows based on
SDD principles.

---

## What Makes jstack Distinct

1. **Full lifecycle in one package** — most tools cover one phase (spec OR code OR deploy OR QA).
   jstack covers ideation → plan review → implementation → QA → security → ship → deploy → canary →
   retro.

2. **Compiled browser binary** — the `/browse` daemon gives skills direct headless browser access.
   Most competitors rely on MCP browser tools or external services.

3. **Eval-driven quality** — the E2E test suite with LLM-judge evals and diff-based test selection
   is unusual. Most skill packs have zero automated quality assurance.

4. **CLI-native** — works entirely within Claude Code's terminal. No IDE lock-in (vs Kiro, Cursor).

---

## Key Articles & References

- [Addy Osmani: My LLM coding workflow going into
  2026](https://addyosmani.com/blog/ai-coding-workflow/)
- [Vishal Mysore: Map of 30+ Agentic Coding
  Frameworks](https://medium.com/@visrow/spec-driven-development-is-eating-software-engineering-a-map-of-30-agentic-coding-frameworks-6ac0b5e2b484)
- [Thoughtworks: Spec-driven
  development](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)
- [Red Hat: How SDD improves AI coding
  quality](https://developers.redhat.com/articles/2025/10/22/how-spec-driven-development-improves-ai-coding-quality)
- [arXiv paper: Spec-Driven Development — From Code to Contract](https://arxiv.org/abs/2602.00180)
- [Best AI Coding Agents 2026 — real-world
  reviews](https://www.faros.ai/blog/best-ai-coding-agents-2026)
- [Heeki Park: Using spec-driven development with Claude
  Code](https://heeki.medium.com/using-spec-driven-development-with-claude-code-4a1ebe5d9f29)
- [SDD Complete Guide 2026](https://prommer.net/en/tech/guides/spec-driven-development/)
- [Microsoft: Diving Into Spec-Driven Development With GitHub Spec
  Kit](https://developer.microsoft.com/blog/spec-driven-development-spec-kit)
- [Agentic Coding Tools 2026: 7
  frameworks](https://www.obviousworks.ch/en/agentic-coding-tools-2026-the-7-frameworks-that-take-your-development-to-a-new-level/)
- [Anthropic: 2026 Agentic Coding Trends
  Report](https://resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf)

### Skill Ecosystem & Curated Lists

- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) — skills, hooks,
  slash-commands, agent orchestrators, plugins
- [awesome-claude-skills (travisvn)](https://github.com/travisvn/awesome-claude-skills) — curated
  skills and resources
- [awesome-agent-skills (VoltAgent)](https://github.com/VoltAgent/awesome-agent-skills) — 1000+
  agent skills, cross-agent compatible
- [antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) — 1,340+
  installable skills with CLI
- [claude-skill-generator](https://github.com/01clauding/claude-skill-generator) — toolkit for
  building production-ready skills

### Claude Code Skills Deep Dives

- [10 Must-Have Skills for Claude (and Any Coding Agent) in
  2026](https://medium.com/@unicodeveloper/10-must-have-skills-for-claude-and-any-coding-agent-in-2026-b5451b013051)
- [Claude Code Agent Skills 2.0: From Custom Instructions to Programmable
  Agents](https://medium.com/@richardhightower/claude-code-agent-skills-2-0-from-custom-instructions-to-programmable-agents-ab6e4563c176)
- [Essential Claude Code Skills and
  Commands](https://batsov.com/articles/2026/03/11/essential-claude-code-skills-and-commands/)
- [How to Build Custom Claude Code Skills That Actually
  Work](https://dev.to/alanwest/how-to-build-custom-claude-code-skills-that-actually-work-2e1f)
- [Claude Code Customization
  Guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)
