# golang-dev

Go development intelligence for jstack: 36 skills covering idiomatic Go,
concurrency, testing, performance, security, observability, and the
`samber/*` library family. Ships gopls as the LSP and wires gopls' built-in
MCP server for Claude Code.

## Contents

- `.claude-plugin/plugin.json` — plugin manifest
- `.mcp.json` — `gopls` built-in MCP server (generated from `plugin.nix`)
- `.lsp.json` — `gopls` LSP
- `skills/` — 36 skill directories, many with `references/`, `evals/`, and `assets/` subdirs

This plugin is part of [jstack](../../) and is installed into
`~/.claude/plugins/golang-dev/` automatically by `scripts/install.bash`.
There is no separate install step.

## Skills

`golang-benchmark`, `golang-cli`, `golang-code-style`,
`golang-concurrency`, `golang-context`, `golang-continuous-integration`,
`golang-data-structures`, `golang-database`,
`golang-dependency-injection`, `golang-dependency-management`,
`golang-design-patterns`, `golang-documentation`, `golang-error-handling`,
`golang-grpc`, `golang-linter`, `golang-modern-syntax`,
`golang-modernize`, `golang-naming`, `golang-observability`,
`golang-performance`, `golang-popular-libraries`, `golang-project-layout`,
`golang-safety`, `golang-samber-do`, `golang-samber-hot`,
`golang-samber-lo`, `golang-samber-mo`, `golang-samber-oops`,
`golang-samber-ro`, `golang-samber-slog`, `golang-security`,
`golang-stay-updated`, `golang-stretchr-testify`,
`golang-structs-interfaces`, `golang-testing`, `golang-troubleshooting`

See [`docs/plugins/golang-dev.mdx`](../../docs/plugins/golang-dev.mdx)
for the per-skill description table.

## LSP and MCP integration

`gopls` is declared in `plugin.nix` and added to the runtime PATH via the
plugin's `packages` list, so install picks it up automatically. The
LSP is registered via `lspServers.go`, and the built-in MCP server
(`gopls mcp`, available since gopls v0.20) is registered via `mcpServers.gopls`.

The MCP server exposes `go_diagnostics`, `go_references`, `go_rename_symbol`,
`go_search`, `go_vulncheck`, `go_workspace`, and `go_file_context`. No extra
bridge is needed — gopls is the bridge. Minimum gopls version: **0.20**.

## Sources

- [`samber/cc-skills-golang`](https://github.com/samber/cc-skills-golang) — 35 skills by Samuel Berthe (MIT)
- [`JetBrains/go-modern-guidelines`](https://github.com/JetBrains/go-modern-guidelines) — `golang-modern-syntax` (Apache-2.0)

Skills retain the licenses of their original sources.

## See also

- jstack docs: [`docs/plugins/golang-dev.mdx`](../../docs/plugins/golang-dev.mdx)
