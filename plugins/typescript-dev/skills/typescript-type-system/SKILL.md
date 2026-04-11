---
name: typescript-type-system
description: >
  TypeScript type system depth: generics, conditional types, template
  literal types, narrowing, `satisfies`, branded types, discriminated
  unions, readonly types. Apply when modelling domain types or writing
  reusable libraries.
---

# TypeScript type system

Use the type system as a design tool, not a puzzle. Prefer readable
types that express intent; reach for advanced features only when simpler
code cannot express the constraint.

## Generics

- **Constrain generic parameters** with `extends`. Unconstrained generics
  often accept anything and provide no safety.
- **Name generics descriptively** for non-trivial types: `TUser`,
  `TResponse`, not `T`, `U`, `V`.
- **Default type parameters** make APIs easier to use:
  ```ts
  function fetchJson<TResponse = unknown>(url: string): Promise<TResponse>;
  ```

## Union and intersection types

- **Discriminated unions** are the canonical way to model "one of several
  shapes":
  ```ts
  type Result<T, E = Error> =
    | { ok: true; value: T }
    | { ok: false; error: E };
  ```
- Use a literal `kind` or `type` field as the discriminator. Narrowing
  via `switch` on the discriminator is the safest pattern.

## Narrowing

- Type guards: `typeof`, `instanceof`, `in`, equality checks. The
  compiler tracks narrowing through `if` and `switch`.
- **Custom type predicates**:
  ```ts
  function isUser(value: unknown): value is User {
    return (
      typeof value === 'object' &&
      value !== null &&
      'id' in value &&
      typeof (value as { id: unknown }).id === 'string'
    );
  }
  ```
- For runtime validation of external data, use **Zod** — don't hand-write
  predicates for network payloads.

## `satisfies` operator

`satisfies` verifies a value matches a type without widening its inferred
type. Use for config objects:

```ts
const config = {
  host: 'localhost',
  port: 8080,
} satisfies ServerConfig;

// config.port is still `number`, not widened
```

## Template literal types

For typing string patterns:

```ts
type Route = `/users/${number}` | `/posts/${string}`;
type CSSVar = `--${string}`;
```

Avoid deeply recursive template types — they are a common source of
compile slowdowns.

## Conditional types

Use sparingly. Most problems do not need them. When you do need them,
keep the signature readable:

```ts
type Awaited<T> = T extends Promise<infer U> ? U : T;
```

Built-ins cover 90% of real use cases: `Partial`, `Required`, `Readonly`,
`Pick`, `Omit`, `Record`, `Exclude`, `Extract`, `ReturnType`, `Parameters`,
`Awaited`, `NoInfer`.

## Branded / nominal types

TypeScript is structural. To get nominal behavior, use brands:

```ts
type UserId = string & { readonly __brand: 'UserId' };

function asUserId(s: string): UserId {
  return s as UserId;
}
```

Use for domain identifiers that must not be confused (`UserId` vs
`OrderId`), money amounts, normalized strings.

## Readonly & immutability

- `readonly` modifier on fields and array/tuple types.
- `Readonly<T>` utility for shallow read-only objects.
- `const` assertions (`as const`) freeze literal types.
- For deep immutability use `DeepReadonly` from `type-fest` rather than
  rolling your own.

## Anti-patterns

- `any` — use `unknown` and narrow, or use Zod.
- `Function` type — use explicit signatures `(...args: unknown[]) => unknown`.
- `object` type — use `Record<string, unknown>` or a specific type.
- Casting with `as` to silence errors — narrow properly or `unknown as T`
  only when you have just validated the value.
- Types used only to pass tests — if the type is hard to express, maybe
  the runtime is wrong.

## Tool detection

```bash
for tool in tsc node pnpm; do
  command -v "$tool" >/dev/null && echo "ok: $tool" || echo "MISSING: $tool"
done
```

## References

- Handbook - Generics: https://www.typescriptlang.org/docs/handbook/2/generics.html
- Handbook - Narrowing: https://www.typescriptlang.org/docs/handbook/2/narrowing.html
- Zod: https://zod.dev
- type-fest: https://github.com/sindresorhus/type-fest
