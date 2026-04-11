---
name: typescript-error-handling
description: >
  Error handling patterns for TypeScript: Error subclassing, Result
  types, never-throw patterns, async error flow, typed rejection, Zod
  validation errors. Apply when designing error boundaries or reviewing
  try/catch usage.
---

# TypeScript error handling

TypeScript does not type exceptions. A function marked as returning
`User` can still throw anything. To get error-aware code paths, either
(a) use `try`/`catch` consistently at boundaries and trust the rest, or
(b) encode errors in the return type with a `Result` discriminated union.

Pick one approach per module and stick to it. Mixing is worse than
either alone.

## Error subclassing

All thrown errors should extend `Error` and set the `name` field:

```ts
export class NotFoundError extends Error {
  constructor(readonly resource: string, readonly id: string) {
    super(`${resource} with id ${id} not found`);
    this.name = 'NotFoundError';
  }
}
```

- Always call `super(message)`.
- Always set `this.name` — the default is `"Error"` and breaks stack
  output.
- Accept structured context (IDs, resource names) as constructor args,
  not a stringified message.
- Extend `Error`, not a custom base class per layer — that adds noise
  without value.

## Error hierarchies

A small, flat hierarchy is enough for most apps:

```ts
export class AppError extends Error {
  constructor(message: string, readonly cause?: unknown) {
    super(message);
    this.name = 'AppError';
  }
}

export class ValidationError extends AppError { /* ... */ }
export class NotFoundError extends AppError { /* ... */ }
export class PermissionError extends AppError { /* ... */ }
```

At API boundaries convert `AppError` subclasses to HTTP responses with a
single mapper function. Unknown errors become 500s with redacted
messages.

## Result types (the alternative)

For libraries and critical paths where you want the compiler to force
callers to handle errors:

```ts
export type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

export async function fetchUser(
  id: string,
): Promise<Result<User, NotFoundError | NetworkError>> {
  try {
    const res = await fetch(`/users/${id}`);
    if (res.status === 404) return { ok: false, error: new NotFoundError('user', id) };
    if (!res.ok) return { ok: false, error: new NetworkError(res.status) };
    return { ok: true, value: await res.json() };
  } catch (err) {
    return { ok: false, error: new NetworkError(0, { cause: err }) };
  }
}
```

Libraries like `neverthrow` and `ts-results` provide more ergonomic
Result types with chaining. Use them when the Result pattern is
pervasive; for an occasional use don't pull in a dependency.

## Catch clauses are untyped

```ts
try {
  // ...
} catch (err) {
  // err is `unknown`, not `Error`
  if (err instanceof NotFoundError) {
    // narrowed
  }
}
```

- Enable `useUnknownInCatchVariables` (it's on by default in `strict`).
- Always narrow before accessing properties.
- Re-throw unknown errors rather than swallowing them.

## Error.cause (native chaining)

Node 22 and modern browsers support the `Error.cause` option:

```ts
try {
  await fetchUser(id);
} catch (cause) {
  throw new AppError('Failed to load user profile', { cause });
}
```

Do not hand-roll `err.originalError` or `err.inner` — use `cause`.

## Async error flow

- `async` functions return a Promise that rejects with the thrown value.
- `await` propagates the rejection as a thrown error — `try`/`catch`
  works normally.
- **Unhandled promise rejections** terminate Node 20+. Use ESLint's
  `no-floating-promises` rule; every promise must be awaited, returned,
  or explicitly `.catch()`ed.
- Top-level: install `process.on('unhandledRejection', handler)` and
  `uncaughtException` handlers in long-running services.

## Zod validation errors

Zod throws `ZodError` with a structured `issues` array:

```ts
try {
  const user = UserSchema.parse(input);
} catch (err) {
  if (err instanceof z.ZodError) {
    return { ok: false, issues: err.issues };
  }
  throw err;
}
```

Prefer `SafeParse` to avoid the throw entirely:

```ts
const result = UserSchema.safeParse(input);
if (!result.success) return handle(result.error);
const user = result.data;
```

## Anti-patterns

- Throwing strings or plain objects — always throw `Error` subclasses.
- Catching and rethrowing without adding context.
- `catch (err) { /* swallow */ }` — even with logging, prefer propagation.
- Converting errors to `null` return values — callers lose information.
- `Promise.catch(() => null)` on the happy path.

## Tool detection

```bash
for tool in node pnpm tsc; do
  command -v "$tool" >/dev/null && echo "ok: $tool" || echo "MISSING: $tool"
done
```

## References

- Error subclassing: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error
- Error.cause: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error/cause
- neverthrow: https://github.com/supermacro/neverthrow
- Zod errors: https://zod.dev/?id=error-handling
