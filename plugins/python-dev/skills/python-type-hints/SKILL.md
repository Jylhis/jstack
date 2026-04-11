---
name: python-type-hints
description: >
  Modern Python type hints: PEP 695 generics, TypedDict, Protocol,
  Literal, Final, overloads, pyright strict mode, runtime validation
  boundary. Apply when adding or reviewing type annotations.
---

# Python type hints (3.12+)

Python's type system is gradual: annotations are optional and erased at
runtime. Pyright treats them as contracts. Enable strict mode on new
code; keep legacy code untyped rather than lying about its types.

## Baseline

```python
def greet(name: str, times: int = 1) -> str:
    return ", ".join([f"Hello, {name}"] * times)
```

- All public functions should have parameter and return types.
- Internal helpers can omit return types when obvious, but types help
  the LSP even then.
- `None` is the return type for functions with no `return` or a bare
  `return`.

## PEP 695 syntax (Python 3.12+)

Type parameters use the compact syntax:

```python
# Generic function
def first[T](items: list[T]) -> T:
    return items[0]

# Generic class
class Stack[T]:
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

# Type alias
type UserId = str
type Response[T] = dict[str, T | None]
```

Do not use the legacy `TypeVar` / `Generic` syntax in new code.

## Container types

- `list[int]`, `dict[str, int]`, `tuple[int, str]`, `set[str]` — native
  generics since 3.9, no more `from typing import List`.
- `Sequence`, `Mapping`, `Iterable`, `Iterator` — import from
  `collections.abc`, not `typing`.
- Prefer abstract types in parameters, concrete types in return values:
  ```python
  def process(items: Iterable[int]) -> list[int]:
      return sorted(items)
  ```

## Union, Optional, Literal

- **Use `|`** (not `Union`): `int | str`, `str | None`.
- **`Optional[X]` is just `X | None`** — pick one and stick with it.
  `X | None` reads better.
- **`Literal`** constrains to specific values:
  ```python
  def fetch(method: Literal["GET", "POST"]) -> bytes: ...
  ```

## TypedDict

For structured dict shapes (API payloads, config):

```python
from typing import TypedDict, NotRequired

class User(TypedDict):
    id: str
    name: str
    email: NotRequired[str]  # PEP 655
```

- Use `NotRequired[X]` for optional keys.
- Use `total=False` on the class for "all keys optional".
- For anything that needs **runtime validation**, use Pydantic instead.
  TypedDict is erased at runtime — it only helps the type checker.

## Protocol (structural typing)

```python
from typing import Protocol

class SupportsClose(Protocol):
    def close(self) -> None: ...

def cleanup(resource: SupportsClose) -> None:
    resource.close()
```

- Protocols match by shape, not by inheritance. Use them for duck-typed
  interfaces.
- `@runtime_checkable` decorator enables `isinstance()` checks but slows
  things down; skip it unless you need it.

## Overloads

When a function's return type depends on its input type:

```python
from typing import overload

@overload
def get(key: str, default: None = None) -> str | None: ...
@overload
def get(key: str, default: str) -> str: ...
def get(key: str, default: str | None = None) -> str | None:
    return store.get(key, default)
```

Overloads are for the checker only — the actual implementation is the
non-overloaded signature.

## `Final` and `ClassVar`

```python
from typing import Final, ClassVar

MAX_RETRIES: Final = 3   # immutable module-level constant

class Config:
    version: ClassVar[str] = "1.0"  # class attribute, not per-instance
```

Pyright enforces `Final` (reassignment is an error).

## Type narrowing

```python
def process(value: str | int) -> str:
    if isinstance(value, str):
        return value.upper()   # narrowed to str
    return str(value)          # narrowed to int
```

Use custom type guards with `TypeGuard` / `TypeIs` (PEP 742) for
complex narrowing:

```python
from typing import TypeIs

def is_user(obj: object) -> TypeIs[User]:
    return isinstance(obj, dict) and "id" in obj and "name" in obj
```

## pyright strict mode

```toml
# pyproject.toml
[tool.pyright]
typeCheckingMode = "strict"
pythonVersion = "3.12"
exclude = ["build", "dist", ".venv"]
```

Strict mode flags missing annotations, implicit `Any`, unknown types
from untyped dependencies. Adopt strict mode on new code; leave legacy
modules in `basic` mode via per-file overrides.

## Runtime validation boundary

Types are erased at runtime. If you receive data from **outside** your
process (HTTP, DB, config file, user input), validate it:

- **Pydantic v2** for structured validation.
- **`dataclass` + manual checks** for simple cases.
- **Zod-like TypedDict** with pyright checks is not enough — it only
  guards against *your* code violating the shape.

## Anti-patterns

- `Any` without a comment — either type properly or use `object`.
- `# type: ignore` without a reason — always include
  `# pyright: ignore[rule-name]  reason here`.
- Using `typing.List`, `typing.Dict`, `typing.Tuple` in new code (3.9+
  natively supports `list`, `dict`, `tuple`).
- `TypeVar` bounds without `bound=` — useless.
- Relying on runtime types to enforce contracts — that's Pydantic's job.

## Tool detection

```bash
for tool in python3 pyright; do
  command -v "$tool" >/dev/null && echo "ok: $tool" || echo "MISSING: $tool"
done
```

## References

- Python typing docs: https://docs.python.org/3/library/typing.html
- PEP 695 (type parameter syntax): https://peps.python.org/pep-0695/
- PEP 742 (TypeIs): https://peps.python.org/pep-0742/
- pyright config: https://microsoft.github.io/pyright/#/configuration
