# Research Findings: Claude Code Research Tools

Claude Opus 4.6 research

**Date:** 2026-04-05
**Purpose:** Evaluate plugins, skills, agents, and MCP servers that help Claude perform research tasks, for potential import into the Jylhis/claude-marketplace.

---

## Table of Contents

1. [Ecosystem Overview](#ecosystem-overview)
2. [Tier 1: Strong Candidates (MIT Licensed)](#tier-1-strong-candidates-mit-licensed)
3. [Tier 2: High Quality but License Issues](#tier-2-high-quality-but-license-issues)
4. [Tier 3: Useful Components](#tier-3-useful-components)
5. [MCP Servers for Research](#mcp-servers-for-research)
6. [Knowledge Base / RAG MCP Servers](#knowledge-base--rag-mcp-servers)
7. [Marketplaces and Directories](#marketplaces-and-directories)
8. [Comparison Matrix](#comparison-matrix)
9. [Import Recommendations](#import-recommendations)
10. [Sources](#sources)

---

## Ecosystem Overview

The Claude Code research tooling ecosystem as of April 2026 includes:

- **Deep research skills** — Multi-phase pipelines that conduct structured web research with citation tracking, fact-checking, and report generation
- **Academic/scientific skills** — Paper writing, literature review, peer review simulation, and domain-specific scientific workflows
- **Autonomous research loops** — Goal-directed iteration systems inspired by Karpathy's autoresearch
- **MCP search servers** — Unified interfaces to web search providers (Exa, Perplexity, Brave, Tavily, Firecrawl)
- **Knowledge base integrations** — RAG over Obsidian vaults, Notion, and local document collections
- **Fact-checking agents** — Source verification, claim validation, misinformation detection

Key ecosystem numbers:
- 10,400+ repos indexed by awesome-claude-plugins
- 50,588+ skills indexed across platforms
- 150+ plugins in claudemarketplace.com
- 495+ extensions in buildwithclaude.com

---

## Tier 1: Strong Candidates (MIT Licensed)

### 1. ARIS — Auto-Research-In-Sleep

- **Repo:** https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep
- **Stars:** 5,600 | **Forks:** 478
- **License:** MIT (Copyright 2026 wanshuiyin)
- **Version:** v0.3.3
- **Plugin-ready:** No (flat skills/ directory, needs repackaging)

**What it does:**
Autonomous ML research workflow system with cross-model collaboration. Claude Code executes (coding, writing, file management) while GPT-5.4 acts as adversarial reviewer — avoiding self-play bias.

**Claimed results:** Two accepted conference papers (CS conference 8/10 "clear accept", AAAI 2026 7/10 "good paper, accept").

**31 skills organized into 6 composable workflows:**

| Workflow | Description |
|---|---|
| Idea Discovery | Literature survey via Semantic Scholar/DBLP → brainstorm 8-12 ideas → novelty checks → GPU pilot experiments → ranked IDEA_REPORT.md |
| Experiment Bridge | Takes experiment plan → implements code → optional GPT-5.4 code review → sanity checks → full experiments. Supports local, SSH, and Vast.ai GPU targets |
| Auto Review Loop | Up to 4 rounds: submit to GPT-5.4 reviewer → extract score/weaknesses → Claude fixes → re-review. Three difficulty modes (Medium/Hard/Nightmare) |
| Paper Writing | paper-plan → paper-figure → paper-write → paper-compile → auto-improvement-loop. Supports ICLR, NeurIPS, ICML, CVPR, ACL venues. 45-90 min end-to-end |
| Rebuttal | Parse reviewer comments → atomize into issue board → build strategy → draft responses with 3 safety gates → stress-test with GPT-5.4 |
| Meta-Optimize | Analyzes ARIS's own usage logs to propose improvements to skill prompts and parameters |

**Additional specialized skills:** dse-loop (design-space exploration), formula-derivation, proof-writer, vast-gpu (Vast.ai lifecycle management), paper-slides, paper-poster, research-refine, experiment-plan, serverless-modal.

**Quality assessment:**

Strengths:
- Exceptionally well-structured SKILL.md files with configurable constants, state recovery, safety rules
- Anti-hallucination discipline (must verify citations via DBLP/CrossRef, no fabricated results)
- State recovery via JSON for long autonomous runs
- Cross-model adversarial review (three difficulty tiers)
- GPU budget tracking and enforcement
- Configurable autonomy (`AUTO_PROCEED`, `HUMAN_CHECKPOINT`, `REVIEWER_DIFFICULTY`)
- Bilingual EN/ZH

Weaknesses:
- Requires `mcp__codex__codex` (Codex MCP) for cross-model review — core differentiator lost without it
- No tests or evals
- 31 skills is a lot — some may be under-tested
- Requires API keys for Semantic Scholar, MiniMax, OpenAI, Gemini, Feishu
- Not plugin-formatted — needs wrapping

**Best skills for import:** idea-discovery, auto-review-loop, paper-writing, rebuttal, experiment-plan, dse-loop

---

### 2. autoresearch

- **Repo:** https://github.com/uditgoenka/autoresearch
- **Stars:** 3,222 | **Forks:** 248
- **License:** MIT (Copyright 2026)
- **Version:** 1.9.0
- **Plugin-ready:** Yes (ships both `.claude/` and `claude-plugin/` formats)

**What it does:**
Generalized autonomous iteration loop inspired by Karpathy's autoresearch (630-line Python ML training optimizer that ran 700 experiments in 2 days). Works on ANY domain with a measurable metric, not just ML.

**Core loop (8 phases):**

| Phase | Name | What Happens |
|---|---|---|
| 0 | Precondition | Verify git repo, clean tree, no stale locks, check for hooks |
| 1 | Review | Read in-scope files + last 20 git commits + results log. Git IS the memory |
| 2 | Ideate | Pick next change. Priority: fix crashes > exploit successes > explore new > combine near-misses > simplify > radical experiments |
| 3 | Modify | Make ONE atomic change (must pass "one-sentence test") |
| 4 | Commit | `git add <specific files>` then commit. Always before verification |
| 5 | Verify | Run mechanical metric command. Noise handling: multi-run median, min-delta thresholds, confirmation runs |
| 5.5 | Guard | Optional regression check (e.g., `npm test`). Up to 2 rework attempts |
| 6 | Decide | keep (improved), discard (git revert), crash (fix up to 3x then revert) |
| 7 | Log | Append to autoresearch-results.tsv |
| 8 | Repeat | Unbounded: never stop. Bounded: stop at N iterations |

**10 commands:**

| Command | Purpose |
|---|---|
| `/autoresearch` | Main autonomous loop |
| `:plan` | Interactive wizard: Goal → Scope/Metric/Direction/Verify config |
| `:security` | STRIDE + OWASP + 4 red-team personas |
| `:ship` | 8-phase shipping workflow for code, content, marketing, sales, research, design |
| `:debug` | Scientific bug-hunting through iterative investigation |
| `:fix` | Autonomous error elimination loop until zero failures |
| `:scenario` | Edge case exploration across 12 dimensions |
| `:predict` | Multi-persona swarm analysis (3-8 experts + Devil's Advocate + blind judging) |
| `:learn` | Autonomous documentation generation with validation loop |
| `:reason` | Adversarial refinement: Generate-A → Critic → Generate-B → Synthesize → Blind Judge → Converge |

**Quality assessment:**

Strengths:
- 688-line SKILL.md with 11 reference documents — excellent progressive disclosure
- Git-native design (commit = experiment, revert = lesson learned)
- Domain-agnostic — metric/scope/verify abstraction covers 15 domains
- Good interactive setup with batched AskUserQuestion
- Comprehensive documentation (15+ docs including scenario walkthroughs)
- Already ships in plugin format
- Version 1.9.0 — clearly iterated

Weaknesses:
- Post-completion star prompt (asks users to star the GitHub repo) — should be removed on import
- Duplicated content between `.claude/` and `claude-plugin/` directories
- SKILL.md is very long (688 lines)
- No evals
- `:predict` and `:reason` simulate multi-agent workflows within single context — debatable quality
- `:ship` tries to handle everything (code PRs, marketing emails, sales decks) — scope creep

**Import readiness:** Highest of all candidates. Already plugin-formatted. Remove star prompt, use only `claude-plugin/` path.

---

### 3. claude-scientific-skills

- **Repo:** https://github.com/K-Dense-AI/claude-scientific-skills
- **Stars:** 17,409 | **Forks:** (not recorded)
- **License:** MIT (Copyright 2025 K-Dense Inc.) — individual skills may have own licenses (Apache-2.0, BSD-3-Clause)
- **Version:** 2.34.1
- **Plugin-ready:** No (uses Agent Skills `marketplace.json` format, not Claude Code plugin format)

**What it does:**
134 scientific domain skills covering bioinformatics, cheminformatics, physics, ML, visualization, lab automation, scientific writing, and more.

**Domain coverage breakdown:**

| Category | ~Count | Notable Skills |
|---|---|---|
| Bioinformatics & Genomics | ~20 | scanpy, anndata, biopython, scvelo, scvi-tools, pysam, pydeseq2 |
| Cheminformatics & Drug Discovery | ~10 | rdkit, datamol, deepchem, diffdock, medchem, torchdrug |
| Clinical & Medical | ~5 | clinical-decision-support, clinical-reports, treatment-plans, pyhealth |
| Lab Automation & Integration | ~9 | benchling, dnanexus, ginkgo-cloud-lab, opentrons, omero |
| Data Science & ML | ~15 | scikit-learn, pytorch-lightning, transformers, shap, dask, polars |
| Visualization | ~5 | matplotlib, seaborn, scientific-visualization, infographics |
| Physics & Materials | ~8 | astropy, pymatgen, cirq, qiskit, pennylane, molecular-dynamics |
| Scientific Communication | ~10 | scientific-writing, peer-review, citation-management, latex-posters |
| Document Processing | ~5 | docx, pdf, pptx, xlsx, markitdown |
| Databases & Search | ~5 | database-lookup (78 databases!), paper-lookup, research-lookup |
| Simulation & Engineering | ~5 | simpy, sympy, cobrapy, pymoo |
| Specialized/Misc | ~10+ | consciousness-council, what-if-oracle, hypothesis-generation |

**Quality assessment:**

Strengths:
- Best skills (scanpy, rdkit, biopython) are genuinely excellent — 300-500+ lines with production code
- database-lookup covers 78 scientific databases with per-database reference files
- Comprehensive reference material (5-10+ reference files per skill)
- Helper Python scripts for many skills
- Consistent structure across most skills
- Most complete scientific Python ecosystem coverage available

Weaknesses:
- **Quality is very uneven** — best skills are 500+ lines, worst are 20-line summaries
- Some skills are NOT scientific (consciousness-council, what-if-oracle, market-research-reports)
- Not in Claude Code plugin format — needs structural adaptation
- No evals for any skills
- YAML frontmatter inconsistency across skills
- Some skills subtly upsell K-Dense's commercial platform (Nano Banana Pro)
- Individual skill licenses vary — need per-skill verification on import

**Best skills for import:** scanpy, rdkit, biopython, pytorch-lightning, database-lookup (78 databases), scientific-writing, literature-review, hypothesis-generation, statistical-analysis, paper-lookup

---

### 4. mcp-omnisearch

- **Repo:** https://github.com/spences10/mcp-omnisearch
- **Stars:** 290 | **Forks:** 39
- **License:** MIT
- **Version:** 0.0.22
- **Type:** MCP server (TypeScript)

**What it does:**
Unified MCP server providing access to 7 search providers through 4 consolidated tools. Auto-detects which API keys are present and only enables those providers.

**Providers:**

| Provider | Capabilities | API Key Env Var |
|---|---|---|
| Tavily | Web search (factual/citations), content extraction | `TAVILY_API_KEY` |
| Brave | Web search (privacy-focused, full operator syntax) | `BRAVE_API_KEY` |
| Kagi | Web search, FastGPT AI answers (~900ms), summarization | `KAGI_API_KEY` |
| Exa AI | Semantic search, AI answers, content retrieval, similar pages | `EXA_API_KEY` |
| GitHub | Code search, repo search, user search | `GITHUB_API_KEY` |
| Linkup | Deep agentic AI search with sourced answers | `LINKUP_API_KEY` |
| Firecrawl | Scraping, crawling, site mapping, structured extraction | `FIRECRAWL_API_KEY` |

**4 MCP tools exposed:**

| Tool | Purpose |
|---|---|
| `web_search` | Search web via Tavily/Brave/Kagi/Exa |
| `ai_search` | AI-powered answers with citations via Kagi FastGPT/Exa/Linkup |
| `github_search` | Code/repo/user search on GitHub |
| `web_extract` | Content extraction and processing via Tavily/Kagi/Firecrawl/Exa |

**Quality assessment:**

Strengths:
- Well-architected — clean provider separation, adding new providers is straightforward
- Actively maintained (last commit 2026-04-03)
- Graceful degradation — missing API keys just disable those providers
- Robust infrastructure: retry logic, per-provider timeouts, structured errors, Valibot validation
- Deployment flexibility: stdio, Docker, cloud platforms
- Good documentation with per-tool/per-provider examples

Weaknesses:
- Pre-1.0 version (0.0.22)
- No automated tests
- Some Kagi features require Business (Team) plan

**Integration:** Would serve as the search infrastructure layer for any research plugin. Configure in `.mcp.json`.

---

### 5. claude-code-templates (fact-checker + deep research team)

- **Repo:** https://github.com/davila7/claude-code-templates
- **Author:** Daniel (San) Avila
- **License:** MIT (Copyright 2025)
- **Plugin-ready:** No (agent definitions only)

**What it does:**
A 16-agent deep research team organized as a hierarchical pipeline:

```
Query Processing → Planning → Parallel Research → Synthesis → Output
```

**16 agents:**

| Agent | Tools | Role |
|---|---|---|
| research-orchestrator | Task, Read, Write, Edit | Central coordinator; 6-phase workflow, quality gates |
| research-coordinator | Read, Write, Edit, Task | Strategic task allocation across specialists |
| query-clarifier | Read, Write, Edit | Pre-research query analysis; confidence scoring |
| research-brief-generator | Read, Write, Edit | Structured research plan creation |
| academic-researcher | Read, Write, Edit, WebSearch, WebFetch | Scholarly sources, peer-reviewed papers, citation tracking |
| technical-researcher | Read, Write, Edit, WebSearch, WebFetch, Bash | Code repos, API docs, architecture analysis |
| data-analyst | Read, Write, Edit, WebSearch, WebFetch | Statistical analysis, trend identification |
| data-researcher | — | Data-focused research |
| search-specialist | Read, Grep, Glob, WebFetch, WebSearch | Advanced search strategies, 90%+ precision target |
| fact-checker | Read, Write, Edit, WebSearch, WebFetch | Claim verification, misinformation detection |
| research-synthesizer | Read, Write, Edit | Consolidate findings, identify contradictions |
| report-generator | Read, Write, Edit | Final report with citations |
| research-analyst | — | Research analysis |
| competitive-intelligence-analyst | — | Market intelligence |
| nia-oracle | — | Unknown specialty |
| agent-overview | N/A | Architecture documentation |

**Fact-checker detail:**
- Claim extraction via regex patterns
- 5-step verification pipeline
- Source credibility scoring (0.0-1.0)
- Verification levels: TRUE, MOSTLY TRUE, PARTIALLY TRUE, MOSTLY FALSE, FALSE, UNVERIFIABLE
- Misinformation detection: emotional manipulation, logical fallacies, factual inconsistencies
- Citation validation: APA/MLA/Chicago/IEEE format compliance, accessibility checks
- Cross-reference analysis against PubMed, Google Scholar, JSTOR, AP, Reuters, CDC, WHO

**Quality assessment:**

Strengths:
- Well-architected team with clear separation of concerns
- Fact-checker is the most detailed agent — thorough verification methodology
- MIT licensed — no barriers
- Proper tool assignments per agent

Weaknesses:
- Python code in fact-checker is illustrative pseudocode, not executable
- No evals or tests
- 16 agents is heavy — token-expensive to orchestrate
- Some agents are thin compared to fact-checker
- No hooks or MCP configs

**Best components for import:** fact-checker, academic-researcher, search-specialist, research-synthesizer, report-generator (curated subset of 5-6 agents rather than full 16).

---

## Tier 2: High Quality but License Issues

### 6. claude-deep-research-skill (199-biotechnologies)

- **Repo:** https://github.com/199-biotechnologies/claude-deep-research-skill
- **Stars:** 413 | **Forks:** 42
- **License:** Claims MIT in README, **but no LICENSE file exists** — legally ambiguous
- **Plugin-ready:** No

**What it does:**
8-phase enterprise-grade research pipeline with real Python validation scripts.

**8-phase pipeline:**

| Phase | Name | Description |
|---|---|---|
| 1 | SCOPE | Decompose question, identify stakeholders, define boundaries |
| 2 | PLAN | Map knowledge dependencies, create search query strategy |
| 3 | RETRIEVE | Parallel search (5-10 concurrent WebSearch + 2-3 Task sub-agents returning structured JSON evidence) |
| 4 | TRIANGULATE | Cross-reference across 3+ sources, flag contradictions, assess credibility |
| 4.5 | OUTLINE REFINEMENT | Adapt research direction based on evidence (prevents "locked-in" scope) |
| 5 | SYNTHESIZE | Pattern identification, conceptual frameworks, second-order implications |
| 6 | CRITIQUE | Red-team with 3 personas: Skeptical Practitioner, Adversarial Reviewer, Implementation Engineer |
| 7 | REFINE | Address gaps, strengthen weak arguments, resolve contradictions |
| 8 | PACKAGE | Progressive file assembly, validation loop, HTML/PDF generation |

**4 execution modes:** Quick (2-5 min, phases 1,3,8), Standard (5-10 min), Deep (10-20 min, all 8), UltraDeep (20-45 min, all 8+ multi-persona critique).

**Unique value — real validation scripts:**
- `validate_report.py` — 9 checks (exec summary length, required sections, citation format, bibliography completeness, placeholder detection, content truncation, word count, source count)
- `verify_citations.py` — Actually resolves DOIs via doi.org API, checks URL accessibility, "CiteGuard" detects hallucinated citations (generic academic titles, future years, placeholder text)
- `source_evaluator.py` — Tiered credibility scoring: arxiv/nature/gov = 90/100, techcrunch/stackoverflow = 70, unknown = 55, blogspot = 40

**Quality assessment:**

Strengths:
- Excellent progressive disclosure architecture (lean SKILL.md dispatches to reference files)
- Validation pipeline is real and functional — not stubs
- Anti-hallucination CiteGuard is uniquely valuable
- Source credibility scoring is reasonable and practical
- Auto-continuation for reports >18K words via recursive Task spawning

Weaknesses:
- **No LICENSE file** — blocker for import
- Known issue #1: progressive assembly/auto-continuation doesn't work reliably in practice
- No automated tests beyond fixtures
- `research_engine.py` is skeleton — Claude drives the pipeline, not the Python code
- WeasyPrint dependency is heavy (requires system libs)
- Hardcoded paths assume macOS/Linux

**Action:** File issue requesting LICENSE file addition. The citation verification scripts are uniquely valuable and worth importing.

---

### 7. academic-research-skills (Imbad0202)

- **Repo:** https://github.com/Imbad0202/academic-research-skills
- **Stars:** Not recorded
- **License:** **CC-BY-NC 4.0 (NonCommercial only)**
- **Version:** v3.0

**What it does:**
4 skills with 35 agents total, organized as a full academic pipeline.

**Skills and agents:**

| Skill | Agents | Purpose |
|---|---|---|
| deep-research | 13 agents | Literature survey, systematic review, PRISMA |
| academic-paper | 12 agents | 8-phase paper writing pipeline |
| academic-paper-reviewer | 7 agents | Simulated peer review (5 reviewers) |
| academic-pipeline | 3 agents | End-to-end orchestrator (9 stages) |

**12-agent paper writing pipeline (academic-paper):**

| Phase | Agent | Role |
|---|---|---|
| 0 - Config | intake_agent | Collects 13 parameters (topic, journal, citation format, etc.) |
| 1 - Literature | literature_strategist_agent | Search strategy, annotated bibliography |
| 2 - Architecture | structure_architect_agent | Outline with word-count allocation |
| 3 - Argumentation | argument_builder_agent | CER (Claim-Evidence-Reasoning) chains |
| 4 - Drafting | draft_writer_agent | Section-by-section using TEEL paragraph structure |
| 5 - Citations | citation_compliance_agent | Zero orphan citations, format compliance |
| 6 - Peer Review | peer_reviewer_agent | 5-dimension simulated review |
| 7 - Revision | revision_coach_agent | Socratic revision guidance |
| — | socratic_mentor_agent | Plan mode: guided chapter-by-chapter |
| — | visualization_agent | Tables, figures, statistical visualizations |
| — | abstract_bilingual_agent | EN + Traditional Chinese abstracts |
| — | formatter_agent | LaTeX, DOCX, PDF, Markdown output |

**Unique innovations:**
- 10 formal handoff schemas between pipeline stages with validation rules
- Anti-sycophancy "Concession Threshold Protocol" (devil's advocate scores rebuttals 1-5, concedes only at 4+)
- Dialogue Health Monitoring every 5 turns
- Cross-model verification (GPT-5.4 Pro or Gemini 3.1 Pro) catches 31% of AI-generated citation problems
- Material Passports with staleness detection
- Mandatory integrity gates that CANNOT be bypassed

**Quality:** Exceptional engineering depth. The most rigorous academic writing system found. **But CC-BY-NC license prohibits commercial use.**

---

### 8. glebis/claude-skills

- **Repo:** https://github.com/glebis/claude-skills
- **Stars:** 89 | **Forks:** 16
- **License:** **No license** (all rights reserved by default)

**40+ skills. Research-relevant ones:**

| Skill | What it does |
|---|---|
| deep-research | Comprehensive research via OpenAI Deep Research API (o4-mini-deep-research model). Synchronous 10-20 min runs. Requires OpenAI API key |
| doctorg | Evidence-based health research with GRADE-inspired ratings. 3 depth levels (Quick/Deep/Full). 4 source tiers. Topic-aware routing. Red flag detection (retracted studies, industry bias, predatory journals). Integrates Apple Health |
| firecrawl-research | Web scraping + BibTeX bibliography via FireCrawl API. Pandoc/MyST scholarly templates |
| thinking-patterns | Longitudinal cognitive pattern analysis from meeting transcripts. 12 evidence-based dimensions (Burns' cognitive distortions, Lakoff metaphors, etc.). 4-stage multi-agent pipeline. ~$3.50/run |
| vault-daydream | Surface non-obvious connections in Obsidian vaults. Gwern-inspired "LLM Daydreaming." Recency-weighted pair sampling → synthesize → critique → quality filter. ~$0.40-0.50/run |

**Quality:** Excellent — production tools the author actually uses. Doctor G in particular is impressive. **But no license means legally untouchable without author permission.**

---

### 9. Deep-Research-skills (Weizhena)

- **Repo:** https://github.com/Weizhena/Deep-Research-skills
- **Stars:** 311 | **Forks:** 30
- **License:** Claims MIT in README, **but no LICENSE file exists**

**What it does:**
3-phase human-in-the-loop research pipeline with 5 skills.

**Phase 1 — Outline Generation (`/research`):**
1. Generate initial framework from model knowledge
2. Web search supplement (user-specified timeframe)
3. Human checkpoint: review/modify items
4. Generate `outline.yaml` + `fields.yaml`
5. Human confirms

**Phase 1.5 — Optional Expansion:**
- `/research-add-items` — add research objects
- `/research-add-fields` — add field definitions

**Phase 2 — Deep Investigation (`/research-deep`):**
- Read outline, identify completed items (resume support)
- Human approves each batch before launch
- Parallel background agents with structured JSON output
- `[uncertain]` markers for unverified data
- Results validated via `validate_json.py`

**Phase 3 — Report Generation (`/research-report`):**
- User selects TOC summary metrics
- Python script generates `report.md`

**Unique features:**
- Resume capability (skips completed items on re-run)
- Uncertainty tracking propagates through pipeline
- Modular web search strategies (academic, general, GitHub, StackOverflow, Chinese tech)
- Bilingual EN/ZH
- Multi-platform (Claude Code, OpenCode GPT-5.4, Codex)

**Quality:** Well-designed workflow. Best human-in-the-loop design of all candidates. **Needs LICENSE file and plugin restructuring.**

---

## MCP Servers for Research

### Search Providers

| Server | Strengths | Free Tier |
|---|---|---|
| **[Exa MCP](https://github.com/exa-labs/exa-mcp-server)** | Semantic search — best for finding code, docs, research papers | Yes |
| **[Perplexity MCP](https://docs.perplexity.ai/docs/getting-started/integrations/mcp-server)** | AI-powered search with citations, expert research assistant | Limited |
| **[Brave Search MCP](https://fastmcp.me/mcp/explore?category=Web+Search)** | Generous free tier, news/image/video, AI summarization | 10-20x better than Google |
| **[Tavily MCP](https://intuitionlabs.ai/articles/mcp-servers-claude-code-internet-search)** | Technical docs, factual search with citations | 1,000 queries/month |
| **[Firecrawl MCP](https://github.com/firecrawl/firecrawl-mcp-server)** | Full scraping: scrape, batch scrape, crawl, search, extract structured data | 500 credits/month |
| **[mcp-omnisearch](https://github.com/spences10/mcp-omnisearch)** | All-in-one: Tavily + Brave + Kagi + Exa + Perplexity + Firecrawl + GitHub | Depends on providers |
| **[Bright Data MCP](https://intuitionlabs.ai/articles/mcp-servers-claude-code-internet-search)** | SERP API + headless browser, 76.8% success rate benchmark | Paid |

### Recommended Combo
- **mcp-omnisearch** for unified search (start with Brave free tier, add Exa/Tavily as needed)
- **Firecrawl MCP** when deep page scraping is required
- **Perplexity MCP** for AI-synthesized research answers with sources

---

## Knowledge Base / RAG MCP Servers

| Server | What it does |
|---|---|
| **[Obsidian Agentic RAG](https://lobehub.com/mcp/mthehang-obsidian-agentic-rag)** | Self-hosted RAG over Obsidian vault — semantic search, fully local, no API keys |
| **[Obsidian RAG MCP](https://glama.ai/mcp/servers/@claudiogarza/obsidian-rag-mcp)** | Semantic search + tag filtering + document retrieval for Obsidian |
| **[Local Knowledge RAG MCP](https://lobehub.com/mcp/patakuti-local-knowledge-rag-mcp)** | RAG over any local document collection |
| **[Notion MCP](https://composio.dev/toolkits/notion/framework/claude-code)** | Read/search/create notes in Notion workspace |

---

## Marketplaces and Directories

| Name | URL | Size |
|---|---|---|
| anthropics/claude-plugins-official | https://github.com/anthropics/claude-plugins-official | Curated, 2.8k stars |
| claudemarketplaces.com | https://claudemarketplaces.com/ | 150+ skills, community voting |
| Build with Claude | https://buildwithclaude.com/ | 495+ extensions |
| claude-plugins.dev | https://claude-plugins.dev/skills | Skill discovery |
| awesome-claude-code-toolkit | https://github.com/rohitg00/awesome-claude-code-toolkit | 135 agents, 35 skills, 150+ plugins |
| awesome-claude-plugins (quemsah) | https://github.com/quemsah/awesome-claude-plugins | 10,400+ repos indexed |
| awesome-claude-code (hesreallyhim) | https://github.com/hesreallyhim/awesome-claude-code | Curated awesome list |
| awesome-claude-plugins (ComposioHQ) | https://github.com/ComposioHQ/awesome-claude-plugins | Curated list |
| VoltAgent/awesome-agent-skills | https://github.com/VoltAgent/awesome-agent-skills | 1000+ agent skills |
| mcpmarket.com | https://mcpmarket.com/ | Skills + MCP servers |
| fastmcp.me | https://fastmcp.me/ | MCP server directory |

---

## Comparison Matrix

| Repo | Stars | License | Plugin-ready | Research Type | Autonomy | Cross-model | Import Priority |
|---|---|---|---|---|---|---|---|
| ARIS | 5,600 | MIT | No | ML research, papers | High | GPT-5.4 reviewer | High |
| autoresearch | 3,222 | MIT | **Yes** | Any measurable task | High | No | **Highest** |
| scientific-skills | 17,409 | MIT | No | 134 scientific domains | Low (tools) | No | High (selective) |
| mcp-omnisearch | 290 | MIT | N/A (MCP) | Search infrastructure | N/A | N/A | High |
| code-templates | — | MIT | No | Fact-checking, team research | Medium | No | Medium |
| 199-bio deep-research | 413 | **No file** | No | General research | Medium | No | Blocked |
| academic-research | — | **CC-BY-NC** | No | Academic papers | Medium | GPT/Gemini | Blocked (NC) |
| glebis/skills | 89 | **None** | No | Health, knowledge graphs | Medium | No | Blocked |
| Deep-Research-skills | 311 | **No file** | No | Structured research | Low (HITL) | No | Blocked |

---

## Import Recommendations

### Phase 1: Import Now (MIT, high value)

1. **autoresearch** — Already plugin-formatted. Import as `plugins/autoresearch/`. Remove star-prompt section from SKILL.md. Use only `claude-plugin/` path. Highest ROI.

2. **mcp-omnisearch** — Add as recommended `.mcp.json` configuration for research plugins. Document API key setup.

3. **claude-code-templates fact-checker** — Extract fact-checker, search-specialist, academic-researcher, synthesizer, report-generator agents. Repackage as `plugins/research-agents/`.

### Phase 2: Selective Import (MIT, needs repackaging)

4. **ARIS** — Cherry-pick: idea-discovery, auto-review-loop, paper-writing, rebuttal, experiment-plan. Repackage as `plugins/ml-research/`. Document Codex MCP dependency as optional.

5. **claude-scientific-skills** — Selective import of top ~70-80 skills. Verify per-skill licenses. Repackage into domain-specific plugins: `plugins/bioinformatics/`, `plugins/cheminformatics/`, `plugins/scientific-writing/`, etc.

### Phase 3: Request License Files

6. **199-bio deep-research-skill** — File GitHub issue requesting MIT LICENSE file. The citation verification Python scripts are uniquely valuable.

7. **Deep-Research-skills** — File GitHub issue requesting MIT LICENSE file. The human-in-the-loop workflow and resume support are well-designed.

### Watch List (study but can't import)

8. **academic-research-skills** — CC-BY-NC blocks commercial use. Study the handoff schemas, anti-sycophancy protocols, and integrity gates as architectural patterns.

9. **glebis/claude-skills** — No license. Doctor G's GRADE-inspired health research ratings and Vault Daydream's knowledge graph mining are impressive patterns to learn from.

---

## Sources

### Official Documentation
- [Extend Claude with skills](https://code.claude.com/docs/en/skills)
- [Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Create plugins](https://code.claude.com/docs/en/plugins)
- [Discover plugins through marketplaces](https://code.claude.com/docs/en/discover-plugins)
- [Plugin Developer Toolkit](https://claude.com/plugins/plugin-dev)
- [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official)
- [anthropics/skills](https://github.com/anthropics/skills)

### Repositories Analyzed
- [wanshuiyin/Auto-claude-code-research-in-sleep](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep) (ARIS)
- [uditgoenka/autoresearch](https://github.com/uditgoenka/autoresearch)
- [K-Dense-AI/claude-scientific-skills](https://github.com/K-Dense-AI/claude-scientific-skills)
- [spences10/mcp-omnisearch](https://github.com/spences10/mcp-omnisearch)
- [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates)
- [199-biotechnologies/claude-deep-research-skill](https://github.com/199-biotechnologies/claude-deep-research-skill)
- [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills)
- [glebis/claude-skills](https://github.com/glebis/claude-skills)
- [Weizhena/Deep-Research-skills](https://github.com/Weizhena/Deep-Research-skills)

### Guides and Articles
- [Best Claude Code Skills & Plugins 2026 Guide](https://dev.to/raxxostudios/best-claude-code-skills-plugins-2026-guide-4ak4)
- [10 Must-Have Skills for Claude (2026)](https://medium.com/@unicodeveloper/10-must-have-skills-for-claude-and-any-coding-agent-in-2026-b5451b013051)
- [Complete Guide to Building Skills (Anthropic PDF)](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf?hsLang=en)
- [Claude Agent Skills: A First Principles Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)
- [Anthropic Course: Introduction to Agent Skills](https://anthropic.skilljar.com/introduction-to-agent-skills)
- [Integrating MCP Servers for Web Search](https://intuitionlabs.ai/articles/mcp-servers-claude-code-internet-search)

### Directories and Marketplaces
- [claudemarketplaces.com](https://claudemarketplaces.com/)
- [buildwithclaude.com](https://buildwithclaude.com/)
- [claude-plugins.dev](https://claude-plugins.dev/skills)
- [mcpmarket.com](https://mcpmarket.com/)
- [fastmcp.me](https://fastmcp.me/)
- [awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit)
- [awesome-claude-plugins (quemsah)](https://github.com/quemsah/awesome-claude-plugins)
- [awesome-claude-code (hesreallyhim)](https://github.com/hesreallyhim/awesome-claude-code)
- [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills)
