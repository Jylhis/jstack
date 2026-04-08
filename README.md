# jstack

Multi-agent AI configuration: skills, agents, slash commands, hooks,
settings, and plugin bundles. Supports **Claude Code**, **Codex CLI**, and
**Gemini CLI**. Installed via a symlink-based `install.bash` script or
Home Manager module.

The full documentation site lives in [`docs/`](docs/) and is rendered
with [Mintlify](https://mintlify.com). Run `mintlify dev` from inside
`docs/` to preview locally.

## Supported Agents

| Agent | Config dir | Instructions | Skills path |
|---|---|---|---|
| Claude Code | `~/.claude/` | `CLAUDE.md` | `~/.claude/skills/` + `~/.claude/plugins/*/skills/` |
| Codex CLI | `~/.codex/` | `AGENTS.md` | `~/.codex/skills/` |
| Gemini CLI | `~/.gemini/` | `GEMINI.md` | `~/.gemini/skills/` |

## Layout

```
.
├── settings.nix               # canonical settings source (generates settings.json)
├── settings.json              # generated — do not edit directly
├── CLAUDE.md                  # source of truth for ~/.claude/CLAUDE.md
├── sources.nix                # third-party skill source configuration (npins)
├── skills/                    # personal skills (dir-per-skill, SKILL.md inside)
├── agents/                    # personal subagent .md files
├── commands/                  # personal slash command .md files
├── hooks/                     # hook scripts referenced from settings.json
├── plugins/                   # one directory per plugin (e.g. plugins/rust-dev/)
│   └── <plugin>/
│       ├── plugin.nix         # plugin metadata (source of truth)
│       ├── skills/            # plugin skills
│       ├── .claude-plugin/    # generated: plugin.json
│       ├── .mcp.json          # generated: MCP server config
│       └── .lsp.json          # generated: LSP server config
├── lib/                       # Nix library (discovery, manifests, bundles)
│   ├── default.nix            # library entry point
│   ├── targets.nix            # agent target definitions
│   ├── discover.nix           # recursive SKILL.md scanner
│   ├── manifest.nix           # manifest generators (plugin.json, .mcp.json, .lsp.json)
│   ├── bundle.nix             # bundle builder for third-party skills
│   └── list-catalog.nix       # convenience: list all discovered skills
├── runtime/default.nix        # pkgs.buildEnv with LSPs (auto-aggregates from plugin.nix)
├── module.nix                 # Home Manager module (multi-target)
├── evals/                     # promptfoo eval suite
│   ├── promptfooconfig.yaml   # eval harness config
│   └── cases/                 # per-plugin test cases
├── docs/                      # Mintlify documentation site
├── npins/                     # pinned dependencies (nixpkgs + third-party sources)
└── scripts/
    ├── install.bash           # link the repo into agent config dirs, build runtime
    └── eval.bash              # run promptfoo (--fast, --plugin)
```

## Plugin bundles

| Plugin | Skills | Packages | LSP | MCP | What it ships |
|---|---|---|---|---|---|
| [rust-dev](plugins/rust-dev) | 29 | — | rust-analyzer | — | Rust language mechanics, design, domain packs, LSP analyzers |
| [golang-dev](plugins/golang-dev) | 36 | — | gopls | — | Go idioms, perf, testing, security, observability, samber libraries |
| [nix-dev](plugins/nix-dev) | 7 | nil | nil | mcp-nixos | Nix language, NixOS modules, flakes, devenv, home-manager |
| [productivity](plugins/productivity) | 1 | — | — | — | Weekly session log appender |
| [skill-creator](plugins/skill-creator) | 1 | — | — | — | Anthropic's official skill authoring + eval framework |
| [obsidian](plugins/obsidian) | 5 | — | — | — | Obsidian markdown, canvas, bases, CLI, web extraction |

## Plugin definition

Each plugin is defined by a `plugin.nix` file (source of truth). Manifests
(`plugin.json`, `.mcp.json`, `.lsp.json`) are generated from it.

```nix
{ pkgs }:
{
  name = "my-plugin";
  version = "1.0.0";
  description = "What this plugin provides";
  author.name = "Your Name";
  packages = [ pkgs.some-tool ];   # optional: added to runtime PATH
  mcpServers = { ... };            # optional: generates .mcp.json
  lspServers = { ... };            # optional: generates .lsp.json
}
```

## Third-party sources

Pin external skill repos via npins and configure them in `sources.nix`:

```bash
npins add github anthropics skills     # pin the repo
```

```nix
# sources.nix
{
  anthropic-skills = {
    namespace = "anthropic";
    skillsRoot = "skills";
    maxDepth = 4;
  };
}
```

List all discovered skills: `just list-skills`

## Install

Run inside a devenv shell (or anywhere `nix` and standard tools are on
`PATH`):

```bash
bash scripts/install.bash --dry-run          # preview (Claude Code, default)
bash scripts/install.bash                    # apply
bash scripts/install.bash --target codex     # deploy to Codex CLI
bash scripts/install.bash --target gemini    # deploy to Gemini CLI
bash scripts/install.bash --target all       # deploy to all agents
exec zsh                                     # pick up the PATH change
```

The install is idempotent — re-running reports zero actions if nothing
changed. A timestamped backup of any displaced files lands in
`~/.claude/.jstack-backups/<timestamp>/`.

### First-run prerequisites

If `~/.claude/settings.json` or `~/.claude/CLAUDE.md` is currently a
symlink into the nix store (managed by an existing home-manager module),
`install.bash` will replace it but the home-manager module will recreate
the link on the next `home-manager switch`. Disable the module
out-of-band first:

1. Remove `programs.jstack.enable = true;` (or equivalent) from
   your home-manager configuration
2. Run `home-manager switch`
3. Then run `bash scripts/install.bash`

## Develop

```bash
direnv allow                   # enter the devenv shell
lint                           # markdownlint + jq settings.json
install                        # alias for scripts/install.bash
eval                           # full promptfoo run
eval-fast                      # routing tests only
eval-plugin nix-dev            # evals for a specific plugin
just generate-settings         # regenerate settings.json from settings.nix
just generate-manifests        # regenerate all plugin.json/.mcp.json/.lsp.json
just list-skills               # list all discovered skills
just add-source owner repo     # pin a third-party skill source
just install-target codex      # install for a specific agent
```

## Documentation

The full documentation is in [`docs/`](docs/), rendered with Mintlify:

| Page | Path |
|---|---|
| Project overview | [`docs/index.mdx`](docs/index.mdx) |
| Install | [`docs/install.mdx`](docs/install.mdx) |
| Develop | [`docs/develop.mdx`](docs/develop.mdx) |
| Architecture | [`docs/architecture.mdx`](docs/architecture.mdx) |
| Plugins | [`docs/plugins/`](docs/plugins/) |

To preview locally:

```bash
cd docs
mintlify dev
```

## Marketplace UI conflict

After install, `~/.claude/plugins/` is a symlink into this repo. If you
install a plugin via Claude Code's marketplace UI (`/plugin install foo`),
it will write a new directory under `plugins/` and show up in
`git status`. Either commit the new plugin to the repo or revert it.
