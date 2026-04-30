# Repository Guidelines

## Project Structure & Module Organization

This repository is a Nix-managed catalogue of agent skills and deployment modules. Core Nix library code lives in `lib/`, reusable NixOS/nix-darwin/Home Manager modules in `modules/`, and runtime package composition in `runtime/`. Local skill definitions are under `skills/<name>/SKILL.md`; agent prompts are in `agents/`, slash commands in `commands/`, and templates in `templates/`. Documentation is in `docs/`, scripts are in `scripts/`, and module evaluation tests are in `tests/`. Bundled upstream sources are configured through `flake.nix` and `bundled-sources.nix`.

## Build, Test, and Development Commands

Use `just` as the task entry point.

- `just check`: runs Nix evaluation, flake checks, devenv tests, `statix`, and `deadnix`.
- `just check-modules`: evaluates `tests/module-eval.nix` directly.
- `just fmt`: formats all Nix files with `nixfmt`.
- `just build`: builds the default runtime package with `nix-build`.
- `just list-skills`: lists discovered skills from local and bundled sources.
- `just update`: updates `flake.lock`, synchronizes `devenv.yaml`, and refreshes `devenv.lock`.

## Coding Style & Naming Conventions

Prefer small, composable Nix files and keep option/module logic close to existing patterns in `modules/` and `lib/`. Format Nix changes with `just fmt`; lint with `statix check . --ignore '.devenv/*' 'result/*'` and remove dead code with `deadnix --fail --exclude .devenv result .`. Skill directories use kebab-case and must contain `SKILL.md`. Markdown skill, agent, and command files are covered by `.markdownlint-cli2.jsonc`.

## Testing Guidelines

Add or update `tests/module-eval.nix` when changing module behavior, target wiring, assertions, or generated configuration. Run `just check-modules` for focused feedback and `just check` before opening a pull request.

## Commit & Pull Request Guidelines

Recent history uses short imperative commit subjects such as `Add TODO.md for pending upstream skill imports` and `Bundle GitHub platform skills from github/awesome-copilot`. Keep commits focused and mention lockfile or bundle updates explicitly. Pull requests should summarize the change, note affected tools or skill groups, link related issues, and include validation commands run. Include screenshots only for documentation or rendered output changes.

## Security & Configuration Tips

Do not commit secrets. Keep local credentials in the environment. Treat generated files and lockfiles carefully: update them through `just update`, `nix flake update <input>`, or documented generation commands rather than manual edits.
