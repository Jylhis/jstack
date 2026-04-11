# typescript-dev

TypeScript and JavaScript development intelligence for jstack: 11 skills
covering modern TypeScript (5.9+) on Node 22 LTS, covering type system
depth, testing with Vitest, ESLint 9 flat config, Prettier, pnpm
workspaces, structured error handling, and Node-specific patterns.

## Contents

- `.claude-plugin/plugin.json` — plugin manifest
- `.lsp.json` — `typescript-language-server` (generated from `plugin.nix`)
- `plugin.nix` — metadata, packages, LSP wiring (source of truth)
- `skills/` — 11 skill directories

This plugin is part of [jstack](../../) and is installed into
`~/.claude/plugins/typescript-dev/` automatically by `scripts/install.bash`.

## Skills

| Skill | Description |
|---|---|
| `typescript-code-style` | Idiomatic TypeScript style: naming, file layout, import order, no barrel-exports |
| `typescript-type-system` | Generics, conditional types, template literal types, narrowing, `satisfies`, branded types |
| `typescript-testing` | Vitest test structure, fixtures, mocks, snapshot strategy, coverage |
| `typescript-linting` | ESLint 9 flat config, typescript-eslint, lint scripts, ignoring generated code |
| `typescript-formatting` | Prettier config, integration with ESLint, pre-commit formatting |
| `typescript-packaging` | pnpm + workspaces, tsup for libraries, Vite for apps, publishing to npm |
| `typescript-error-handling` | Error hierarchies, Result types, never-throw patterns, async error flow |
| `typescript-async` | Promises, `async`/`await`, `AbortController`, structured concurrency, cancellation |
| `typescript-security` | XSS, CSRF, SSRF, dep audits, secrets, SSR hydration risks |
| `typescript-nodejs-patterns` | Streams, `fs/promises`, `child_process`, `pino` logging, graceful shutdown |
| `search-params` | URL search param and hash state management in React (imported) |

## LSP integration

`typescript-language-server` is declared in `plugin.nix` and added to the
runtime PATH via the plugin's `packages` list. The LSP is registered via
`lspServers.typescript` and covers `.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`,
`.cjs`.

## MCP integration

None in v0.1. See the deferral comment in `plugin.nix` — `@eslint/mcp` and
`next-devtools-mcp` are candidates once they are Nix-packaged or we add
node2nix derivations.

## Opinionated picks

- **Package manager:** pnpm (workspaces for monorepos)
- **Test runner:** Vitest
- **Linter:** ESLint 9 flat config + typescript-eslint
- **Formatter:** Prettier
- **Bundler (apps):** Vite
- **Bundler (libraries):** tsup
- **Validation:** Zod
- **HTTP client:** native `fetch`
- **Logger:** pino

## Sources

- `mcollina/skills` (Matteo Collina, Node.js TSC chair) — Node patterns inspiration
- `SpillwaveSolutions/mastering-typescript-skill` — TS 5.9 + ESLint 9 flat config reference
- `search-params` — imported from the promptfoo repo under its original terms

## See also

- jstack docs: (TODO: `docs/plugins/typescript-dev.mdx`)
