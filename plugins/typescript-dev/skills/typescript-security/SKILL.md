---
name: typescript-security
description: >
  Security patterns for TypeScript / Node.js: injection, XSS, SSRF,
  secrets, dep audit, SSR hydration risks, prototype pollution. Apply
  when reviewing or writing any code that handles untrusted input or
  external services.
---

# TypeScript / Node.js security

Most TypeScript/Node security bugs fall into a handful of categories.
Know them and apply the safe alternative by default.

## Injection

**SQL injection.** Never build SQL with string concatenation or
template literals. Use the driver's parameter binding:

```ts
// WRONG
await db.query(`SELECT * FROM users WHERE id = '${id}'`);

// RIGHT
await db.query('SELECT * FROM users WHERE id = $1', [id]);
```

For ORMs (Drizzle, Prisma, Kysely), the query builder produces
parameterized queries by default. Audit any code that calls `raw()` or
`$queryRaw`.

**Shell injection.** `child_process.exec` takes a shell string and is
dangerous. Use `child_process.spawn` or `execFile` with an argv array:

```ts
// WRONG
exec(`git log --author=${author}`);

// RIGHT
spawn('git', ['log', `--author=${author}`]);
```

Node 22 adds `child_process.execFileSync` which is similarly safe.

## XSS

- **Never render user input as HTML without escaping.** Template engines
  (Nunjucks, EJS, Handlebars) escape by default — do not use `{{{ }}}` /
  `raw` filters on user data.
- **React** escapes children automatically. `dangerouslySetInnerHTML` is
  the only footgun — if you must use it, sanitize with `DOMPurify`.
- **URL attributes** (`href`, `src`) need explicit scheme checks.
  Reject `javascript:` URIs:
  ```ts
  if (/^\s*javascript:/i.test(url)) throw new Error('bad scheme');
  ```

## SSRF

Server-side code that fetches URLs based on user input must:

1. Parse the URL with `new URL(input)` and inspect `hostname`.
2. Reject private IP ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16,
   127.0.0.0/8, 169.254.0.0/16, ::1, fc00::/7).
3. Resolve the hostname to an IP **once**, check it, then pass the IP
   to fetch to prevent DNS rebinding.

Use `is-ip`, `ipaddr.js`, or a purpose-built library like `ssrf-req-filter`
rather than writing this by hand.

## Secrets

- **Never commit secrets.** Use `.env` files in development and a
  secrets manager (Doppler, SOPS, Vault, AWS Secrets Manager) in
  production.
- **Never log secrets.** Redact tokens in error messages, use logger
  serializers that strip `authorization`, `cookie`, `set-cookie`.
- **Rotate on suspicion.** If a secret may have leaked, rotate it
  immediately.

`git-secrets`, `gitleaks`, or `trufflehog` in pre-commit hooks catches
accidental commits.

## Dependency audit

```bash
pnpm audit --prod              # known CVEs
pnpm outdated                  # stale deps
pnpm dedupe                    # collapse duplicates
```

For automated scanning, configure Dependabot or Renovate on GitHub /
GitLab. For a stricter supply-chain check: `socket.dev` or `snyk`.

## Prototype pollution

`Object.assign({}, userInput)` and `lodash.merge` can walk prototype
chains if `__proto__` is set. Use:

```ts
const safe = structuredClone(userInput);
// or
const safe = JSON.parse(JSON.stringify(userInput));
// or for merges
Object.assign(Object.create(null), userInput);
```

Validate with Zod before merging — it strips unknown keys by default.

## Cookies and sessions

- Always set `httpOnly: true`, `secure: true`, `sameSite: 'lax'` (or
  `strict` for highly sensitive).
- Set a short `maxAge` and refresh on activity.
- Store session IDs (not user data) in cookies; keep state in Redis or
  the DB.

## SSR hydration risks (React / Next.js)

- Do not render server-only secrets in the HTML payload — they ship to
  the client.
- Watch for `useId`, `Date.now()`, `Math.random()` mismatches between
  server and client.
- Sanitize any HTML you render with `dangerouslySetInnerHTML` on the
  server — it is not sanitized automatically.

## CORS and CSRF

- CORS is not a security feature — it's a browser same-origin escape
  hatch. Do not rely on it for authz.
- For cookie-auth APIs, use CSRF tokens or `sameSite=strict`.
- For token-auth APIs, use `Authorization` headers and never cookies.

## JWT pitfalls

- Verify the `alg` header — reject `alg: none` and algorithm confusion.
- Use a library with safe defaults (`jose`, `@auth/core`), not raw
  `jsonwebtoken` with `algorithm: 'HS256'` hardcoded.
- Short expiry + refresh tokens beats long-lived access tokens.

## Tool detection

```bash
for tool in node pnpm; do
  command -v "$tool" >/dev/null && echo "ok: $tool" || echo "MISSING: $tool"
done
```

## References

- OWASP Top 10: https://owasp.org/www-project-top-ten/
- Node.js security best practices: https://nodejs.org/en/learn/getting-started/security-best-practices
- `jose` JWT library: https://github.com/panva/jose
- `DOMPurify`: https://github.com/cure53/DOMPurify
