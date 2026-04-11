---
name: typescript-formatting
description: >
  Prettier configuration for TypeScript / JavaScript projects:
  `.prettierrc`, `.prettierignore`, integration with ESLint, pre-commit
  hooks. Apply when adding or updating formatter config.
---

# TypeScript formatting with Prettier

Prettier is an opinionated formatter — **do not mix it with ESLint
stylistic rules**. Prettier handles whitespace, line breaks, and
wrapping; ESLint handles logic and code quality. The two should not
overlap.

Biome is an emerging alternative (faster, Rust-based) but Prettier
remains the dominant choice in 2026 and ships with every major editor's
built-in integration. Use Biome only when you already understand its
trade-offs.

## Install

```bash
pnpm add -D prettier
```

## Minimal config

Create `.prettierrc.json`:

```json
{
  "printWidth": 100,
  "singleQuote": true,
  "trailingComma": "all",
  "arrowParens": "always",
  "semi": true
}
```

Opinions in jstack projects:

- `printWidth: 100` — 80 feels cramped on modern screens, 120 is too
  wide for side-by-side diff viewers.
- `singleQuote: true` — match JavaScript community convention.
- `trailingComma: 'all'` — cleaner diffs on multi-line lists.

## `.prettierignore`

```
dist/
coverage/
node_modules/
pnpm-lock.yaml
*.generated.ts
```

`pnpm-lock.yaml` is frequently edited by pnpm itself — don't run
Prettier over it.

## Scripts

```json
{
  "scripts": {
    "format": "prettier --write .",
    "format:check": "prettier --check ."
  }
}
```

Run `format:check` in CI — `--check` is non-zero if anything is
unformatted.

## Integration with ESLint

**Do not** install `eslint-plugin-prettier` or `eslint-config-prettier`
in new projects unless you have a specific reason. Prettier runs as a
separate step. The old setup where Prettier ran through ESLint is
slower and muddies the lint output.

If you must disable stylistic ESLint rules that conflict with Prettier,
add `eslint-config-prettier` as the **last** entry in your flat config:

```js
import prettier from 'eslint-config-prettier';

export default tseslint.config(
  // ... other configs
  prettier,
);
```

## Editor integration

- **VS Code:** Prettier extension, set as default formatter, enable
  format on save.
- **Neovim:** `conform.nvim` with `prettier` formatter, or null-ls
  (deprecated, prefer conform).
- **Pre-commit:** `lefthook` or `husky` + `lint-staged` running
  `prettier --write` on staged files.

## lint-staged config

```json
{
  "lint-staged": {
    "*.{ts,tsx,js,jsx,json,md}": "prettier --write"
  }
}
```

## Anti-patterns

- Checking in `.editorconfig` values that conflict with `.prettierrc`.
- Enabling Prettier rules inside ESLint (`plugin:prettier/recommended`).
- Running Prettier on generated files or lockfiles.
- Running Prettier via a pre-commit hook **and** format-on-save **and**
  CI, each with different config — pick one source of truth.

## Tool detection

```bash
for tool in node pnpm prettier; do
  command -v "$tool" >/dev/null && echo "ok: $tool" || echo "MISSING: $tool"
done
```

## References

- Prettier docs: https://prettier.io/docs/en/
- Options: https://prettier.io/docs/en/options
- Ignoring code: https://prettier.io/docs/en/ignore
- Biome (alternative): https://biomejs.dev
