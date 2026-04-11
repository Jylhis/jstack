---
name: python-linting
description: >
  Ruff linting for Python: rule selection, per-file ignores, noqa
  comments, CI integration. Apply when setting up lint for a new project
  or tightening rules.
---

# Python linting with ruff

Ruff is the recommended Python linter: 10-100x faster than flake8,
replaces flake8 + isort + pydocstyle + pylint + most plugins, and
integrates linting and formatting in one binary. Do not use pylint,
flake8, or pyflakes in new projects.

## Install

```bash
uv add --dev ruff
```

## Minimal config (`pyproject.toml`)

```toml
[tool.ruff]
target-version = "py312"
line-length = 88
src = ["src", "tests"]

[tool.ruff.lint]
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # pyflakes
    "I",    # isort
    "N",    # pep8-naming
    "UP",   # pyupgrade
    "B",    # flake8-bugbear
    "A",    # flake8-builtins
    "C4",   # flake8-comprehensions
    "PT",   # flake8-pytest-style
    "SIM",  # flake8-simplify
    "RUF",  # ruff-specific
]
ignore = [
    "E501",   # line too long — handled by formatter
]

[tool.ruff.lint.per-file-ignores]
"tests/**/*.py" = [
    "S101",   # assert is fine in tests
    "PLR2004", # magic values fine in tests
]
```

## Rule groups

**Always enable:**
- `F` — pyflakes: undefined names, unused imports, duplicate keys.
- `E`/`W` — pycodestyle.
- `I` — import sorting (replaces isort).
- `UP` — pyupgrade: modernize syntax to target Python version.
- `B` — bugbear: common bugs (mutable defaults, f-string issues).

**Consider:**
- `PT` — pytest-style: enforce pytest idioms.
- `SIM` — simplify: catch unnecessary comprehensions, conditions.
- `C4` — comprehensions: `list(iter(...))` → `[*iter(...)]`.
- `N` — naming: PEP 8 names.
- `RUF` — ruff-specific modernization rules.
- `ANN` — annotation coverage (strict projects only).

**Usually disable:**
- `D` — pydocstyle: docstring policing is high-noise.
- `COM` — trailing commas: conflicts with ruff format.
- `T20` — print statements: scripts and CLIs use print legitimately.
- `TRY` — long-form try/except advice: opinionated and often wrong.

## `noqa` comments

Suppress a rule on a single line:

```python
value = eval(user_input)  # noqa: S307  reason: REPL tool, trusted input
```

- Always specify the rule: `# noqa: E501`, not bare `# noqa`.
- Always include a reason after the rule code.
- Bare `# noqa` is caught by `RUF100` and flagged as lazy.

## Running

```bash
uv run ruff check .                    # lint
uv run ruff check . --fix              # auto-fix safe violations
uv run ruff check . --fix --unsafe-fixes  # include risky fixes
uv run ruff check . --watch            # watch mode
uv run ruff check --statistics         # show counts per rule
```

## Per-file and per-directory ignores

Use `per-file-ignores` in `pyproject.toml` for patterns like "tests can
use asserts" or "migrations can be long".

```toml
[tool.ruff.lint.per-file-ignores]
"__init__.py" = ["F401"]   # allow re-exports
"migrations/*.py" = ["E501", "N806"]
```

## CI integration

```yaml
# .github/workflows/lint.yml (or .gitlab-ci.yml equivalent)
- name: Lint
  run: uv run ruff check .
```

Do not add `--fix` in CI. Fixing is a human action.

## Integration with pyright

Run both: `ruff check . && pyright` (or in parallel). They catch
different things — ruff is style and micro-bugs, pyright is types.

## Editor integration

- **VS Code:** Ruff extension (Astral) auto-detects config.
- **Neovim:** `nvim-lspconfig` + `ruff-lsp` (deprecated) or direct
  `ruff` LSP (`ruff server`).
- **PyCharm:** Ruff plugin from JetBrains.

## Anti-patterns

- Using ruff **and** black **and** isort — ruff replaces them both.
- Mixing pylint with ruff — pylint duplicates 80% of ruff's rules.
- Disabling whole rule groups because of one violation — use per-file
  ignores.
- `# noqa` on every other line — the rule is probably wrong for this
  project; disable it in config.
- Fixing violations in a separate commit then linting in CI of the
  merge commit — lint should run on every commit.

## Tool detection

```bash
for tool in python3 uv ruff; do
  command -v "$tool" >/dev/null && echo "ok: $tool" || echo "MISSING: $tool"
done
```

## References

- Ruff docs: https://docs.astral.sh/ruff/
- Rules: https://docs.astral.sh/ruff/rules/
- Configuration: https://docs.astral.sh/ruff/configuration/
