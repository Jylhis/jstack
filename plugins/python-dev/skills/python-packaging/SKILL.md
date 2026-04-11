---
name: python-packaging
description: >
  Modern Python packaging with uv: pyproject.toml, lockfile, dev
  dependencies, scripts, workspaces, publishing. Apply when setting up
  a new project, migrating from pip/poetry, or publishing to PyPI.
---

# Python packaging with uv

**uv** is the recommended package manager: a single Rust-based binary
that replaces pip, pip-tools, poetry, pyenv, virtualenv, and pipx. It
is ~10-100x faster and correct by default. Do not use pip or poetry in
new projects.

## Install

uv is declared in `plugin.nix` → available via devenv. For other
environments: https://docs.astral.sh/uv/getting-started/installation/

## Create a new project

```bash
uv init --package my-thing         # library
uv init my-app                     # application (no src layout)
cd my-thing
uv add ruff --dev
uv add httpx
uv sync                            # create .venv, install everything
```

`uv init --package` scaffolds the `src/` layout with a package name and
an installable distribution. Use it for anything you will publish.

## `pyproject.toml` structure

```toml
[project]
name = "my-thing"
version = "0.1.0"
description = "Does the thing"
readme = "README.md"
requires-python = ">=3.12"
authors = [{ name = "Markus", email = "m@example.com" }]
license = "MIT"
dependencies = [
    "httpx>=0.27",
    "pydantic>=2.7",
]

[project.optional-dependencies]
cli = ["typer>=0.12"]

[project.scripts]
my-thing = "my_thing.__main__:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[dependency-groups]
dev = [
    "pytest>=8",
    "ruff>=0.6",
    "pyright>=1.1",
]
```

Use **`[dependency-groups]`** (PEP 735, uv-native) for dev tools — not
`optional-dependencies`. Dev groups are not installed when users `pip
install` your package.

`build-backend`:
- **hatchling** — lightweight, modern, good default.
- **setuptools** — only for legacy projects with complex build needs.
- **maturin** — for projects with Rust extensions.

## Commands

```bash
uv add requests                       # add runtime dep
uv add --dev pytest                   # add dev dep (into default dev group)
uv add --group docs mkdocs            # add to a specific dependency group
uv remove requests
uv sync                               # install from lockfile (frozen)
uv sync --upgrade                     # update lockfile then install
uv sync --upgrade-package httpx       # update only httpx
uv lock                               # re-lock without installing
uv run pytest                         # run a command in the env
uv run python -m my_package           # run a module
uv tree                               # dependency tree
uv pip list                           # list installed packages
```

## Lockfile

uv generates `uv.lock` — commit it for apps and binaries. For libraries
the convention is still debated; committing it gives reproducible CI
but doesn't affect downstream installs.

In CI, use `uv sync --frozen` to fail on any lockfile drift.

## Running code

Do not activate the virtualenv. Use `uv run`:

```bash
uv run pytest
uv run ruff check
uv run python scripts/migrate.py
```

`uv run` ensures the command runs in the project's env every time with
no activation step.

## Publishing to PyPI

```bash
uv build                              # build sdist + wheel into dist/
uv publish --token pypi-...           # upload
```

For libraries with Rust extensions, use `maturin develop` / `maturin
publish` instead.

## Workspaces (monorepo)

```toml
# root pyproject.toml
[tool.uv.workspace]
members = ["packages/*"]

[tool.uv.sources]
shared-lib = { workspace = true }
```

Each `packages/*/pyproject.toml` is a full project. Internal deps
reference each other via `tool.uv.sources`. One `uv.lock` at the root.

## Python version management

```bash
uv python install 3.12            # install a specific Python
uv python pin 3.12                # pin project to that version
uv venv --python 3.12 .venv       # explicit venv
```

Use `requires-python = ">=3.12"` in `pyproject.toml` as the source of
truth for the version floor.

## Migration from pip + requirements.txt

```bash
# In an existing project with requirements.txt
uv init --package .
uv add -r requirements.txt
rm requirements.txt requirements-dev.txt
```

Review `pyproject.toml` and move dev dependencies to the `dev`
dependency group.

## Migration from poetry

uv can read `poetry.lock` for reference but you'll need to convert the
`tool.poetry` tables to standard `project` tables. Use the
`migrate-to-uv` tool:

```bash
uvx migrate-to-uv
```

## Anti-patterns

- Using `pip install` inside a uv project — uv manages `.venv`,
  bypassing it creates drift.
- Committing the `.venv` directory.
- Using requirements.txt alongside `pyproject.toml` — pick one source
  of truth.
- `setup.py` in new projects — `pyproject.toml` is the standard.
- Installing dev tools globally with pipx when `uv tool install`
  exists.
- Forgetting to specify `requires-python` — it affects wheel
  resolution.

## Tool detection

```bash
for tool in python3 uv; do
  command -v "$tool" >/dev/null && echo "ok: $tool" || echo "MISSING: $tool"
done
```

## References

- uv docs: https://docs.astral.sh/uv/
- `pyproject.toml` guide: https://packaging.python.org/en/latest/guides/writing-pyproject-toml/
- PEP 735 (dependency groups): https://peps.python.org/pep-0735/
- hatchling: https://hatch.pypa.io/latest/
