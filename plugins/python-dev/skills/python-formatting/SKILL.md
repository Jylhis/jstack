---
name: python-formatting
description: >
  Ruff format as the Python formatter: config, per-file settings, line
  length, pre-commit hooks. Apply when setting up formatting for a new
  project or migrating from black.
---

# Python formatting with ruff format

Ruff ships its own formatter (`ruff format`) that is **drop-in
compatible with black**. It is ~30x faster and is part of the same
binary as ruff's linter. In new projects use `ruff format` as the
single source of truth for formatting. Do not use black, autopep8, or
yapf.

## Config (`pyproject.toml`)

```toml
[tool.ruff]
target-version = "py312"
line-length = 88
src = ["src", "tests"]

[tool.ruff.format]
quote-style = "double"          # match black's default
indent-style = "space"
skip-magic-trailing-comma = false
docstring-code-format = true    # format code blocks inside docstrings
```

Opinions:

- `line-length = 88` — black's default, community standard. Don't go
  higher unless your team agrees.
- `quote-style = "double"` — consistent with black's opinion. Use
  single if you're migrating a codebase that uses single quotes and
  don't want a massive diff.
- `docstring-code-format = true` — formats code examples inside
  docstrings, keeping documentation in sync.

## Running

```bash
uv run ruff format .               # format in place
uv run ruff format --check .       # CI: fail if anything is unformatted
uv run ruff format --diff .        # show what would change
uv run ruff format path/to/file.py
```

## Pre-commit / lefthook

`lefthook.yml`:

```yaml
pre-commit:
  commands:
    format:
      glob: "*.py"
      run: uv run ruff format --check {staged_files}
    lint:
      glob: "*.py"
      run: uv run ruff check {staged_files}
```

Keep `--check` in pre-commit — forcing a reformat on commit surprises
developers. Format-on-save in the editor is better UX.

## Format-on-save

All major editors support ruff format:

- **VS Code:** set `"editor.defaultFormatter": "charliermarsh.ruff"` and
  `"editor.formatOnSave": true` for Python files.
- **Neovim:** `conform.nvim` with `formatters_by_ft = { python = { "ruff_format" } }`.
- **PyCharm:** Ruff plugin, "Reformat on save" in settings.

## Integration with lint

Ruff's linter and formatter can collide on a few style rules. Disable
the conflicting lint rules (ruff does this automatically if you have
both configured in the same `pyproject.toml`). See `ruff check --help`
for the current compatibility list.

`COM` (trailing commas), `E501` (line length), and some quote rules
should be left to the formatter. Add them to `ignore` under
`[tool.ruff.lint]`.

## docstring code formatting

With `docstring-code-format = true`, ruff will reformat code blocks
inside docstrings:

```python
def transform(data: dict) -> dict:
    """Transform the input data.

    Example:
        >>> transform({"a": 1})
        {'a': 2}
    """
    return {k: v + 1 for k, v in data.items()}
```

The `>>> transform(...)` example will be line-wrapped if it exceeds
`line-length`. Turn off if your codebase has many long doctest lines
you don't want touched.

## Migration from black

```bash
uv remove black
uv add --dev ruff
```

Then in `pyproject.toml`:

```toml
[tool.ruff]
line-length = 88   # match your existing black line-length

[tool.ruff.format]
quote-style = "double"   # or whatever your project used
```

Run `uv run ruff format .` once to catch any edge cases (ruff is 99.9%
compatible, not 100%). Commit that as a single "switch to ruff format"
commit so `git blame` stays useful.

## Anti-patterns

- Running both black **and** ruff format — they will fight.
- Formatting generated files (e.g. `protoc`-generated `_pb2.py`).
- Disagreeing with the formatter in PR review — if the tool is
  producing bad output, fix the tool config, not the code.
- `# fmt: off` / `# fmt: on` blocks without a one-line explanation of
  why (usually a table of values where alignment matters).
- Running format in CI as a separate job from lint — run them together
  with one `ruff check && ruff format --check`.

## Tool detection

```bash
for tool in python3 uv ruff; do
  command -v "$tool" >/dev/null && echo "ok: $tool" || echo "MISSING: $tool"
done
```

## References

- Ruff formatter: https://docs.astral.sh/ruff/formatter/
- Black compatibility: https://docs.astral.sh/ruff/formatter/black/
- docstring-code-format: https://docs.astral.sh/ruff/settings/#format_docstring-code-format
