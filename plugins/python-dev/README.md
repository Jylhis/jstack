# python-dev

Python development intelligence for jstack: 10 skills covering modern
Python 3.12+ with an opinionated toolchain (uv, ruff, pytest, pyright,
Pydantic v2).

## Contents

- `.claude-plugin/plugin.json` — plugin manifest
- `.lsp.json` — `pyright-langserver` LSP (generated from `plugin.nix`)
- `plugin.nix` — metadata, packages, LSP wiring (source of truth)
- `skills/` — 10 skill directories

This plugin is part of [jstack](../../) and is installed into
`~/.claude/plugins/python-dev/` automatically by `scripts/install.bash`.

## Skills

| Skill | Description |
|---|---|
| `python-code-style` | PEP 8 + modern idioms: naming, comprehensions, f-strings, pathlib, walrus operator |
| `python-type-hints` | PEP 695 generics, TypedDict, Protocol, Literal, overloads, pyright strict mode |
| `python-testing` | pytest structure, fixtures, parametrize, mocks, coverage, async tests |
| `python-linting` | ruff rule selection, per-file ignores, CI integration |
| `python-formatting` | ruff format as single-source-of-truth formatter |
| `python-packaging` | uv + pyproject.toml, lockfile, scripts, publishing |
| `python-error-handling` | Exception hierarchies, try/except audit, contextlib, error chaining |
| `python-async` | asyncio, TaskGroup, structured concurrency, cancellation, async iteration |
| `python-dataclasses-pydantic` | dataclass vs pydantic v2, validation, serialization, config |
| `python-security` | subprocess, pickle, yaml.load, SSRF, SQL injection, secret handling |

## LSP integration

`pyright` is declared in `plugin.nix` and added to the runtime PATH via
the plugin's `packages` list, along with `ruff` and `uv`. The LSP is
registered via `lspServers.python` and covers `.py` and `.pyi` files.

## MCP integration

None in v0.1. See the deferral comment in `plugin.nix`.

## Opinionated picks

- **Package manager:** uv (replaces pip, poetry, virtualenv)
- **Formatter + linter:** ruff (single tool for both)
- **Type checker:** pyright
- **Test runner:** pytest
- **Web framework:** FastAPI
- **Data validation:** Pydantic v2
- **HTTP client:** httpx
- **Logger:** structlog
- **Profiler:** py-spy

## Sources

- `honnibal/claude-skills` (Matthew Honnibal, spaCy creator) — inspiration for contract-docstrings and try-except audit
- `wdm0006/python-skills` — packaging quality gates
- `ludo-technologies/python-best-practices` — 25 rules with bad/good examples

## See also

- jstack docs: (TODO: `docs/plugins/python-dev.mdx`)
