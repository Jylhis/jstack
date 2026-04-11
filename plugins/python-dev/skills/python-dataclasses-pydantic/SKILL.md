---
name: python-dataclasses-pydantic
description: >
  When to use dataclass vs Pydantic v2 vs TypedDict vs attrs, and the
  migration paths between them. Covers validation, serialization,
  config, and model design. Apply when designing any value object or
  data model in Python.
---

# dataclass vs Pydantic vs TypedDict

Python has four common ways to model structured data. Pick one per
module and stick with it; mixing them creates conversion boilerplate.

| Tool | Use when |
|---|---|
| **`@dataclass`** | Internal value objects; no runtime validation needed; you own all the data |
| **Pydantic v2** | External data (HTTP, config, DB rows); need validation + serialization; want JSON schema |
| **TypedDict** | Legacy APIs that return `dict`; third-party library interop; types only, no runtime check |
| **`attrs`** | Legacy projects that already use it; slightly more features than dataclass (converters, validators) |

## `@dataclass`

Use for plain internal records:

```python
from dataclasses import dataclass, field
from datetime import datetime

@dataclass(frozen=True, slots=True)
class CacheEntry:
    key: str
    value: bytes
    created_at: datetime
    ttl_seconds: int = 3600
    tags: list[str] = field(default_factory=list)
```

- **`frozen=True`** makes instances immutable (hashable, usable as dict
  keys). Default for value objects.
- **`slots=True`** (3.10+) uses `__slots__` — less memory, faster
  attribute access, blocks accidental attribute typos.
- **`field(default_factory=list)`** for mutable defaults — never use a
  bare `tags: list[str] = []`.
- **No validation** — `CacheEntry(key=123, value=None, ...)` runs and
  will blow up later. Use Pydantic for untrusted data.

## Pydantic v2

Use for anything crossing a trust boundary:

```python
from pydantic import BaseModel, Field, EmailStr, field_validator

class User(BaseModel):
    id: str
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=200)
    age: int = Field(..., ge=0, lt=150)
    tags: list[str] = Field(default_factory=list)

    @field_validator("name")
    @classmethod
    def strip_name(cls, v: str) -> str:
        return v.strip()
```

- **Validate at the boundary**: HTTP handlers, config load, DB row
  parse. Don't scatter Pydantic throughout internal code.
- **`model_validate(data)`** parses a dict and raises
  `ValidationError` on bad input.
- **`model_dump(mode='json')`** serializes to a JSON-safe dict.
- **`Field(..., constraints)`** — use type-level constraints
  (`min_length`, `ge`, `lt`, `pattern`) instead of custom validators
  when possible.
- **Pydantic v2 is not Pydantic v1.** Field validators use
  `@field_validator` decorator; model validators use
  `@model_validator(mode='after')`; config is `model_config = ConfigDict(...)`.

### Pydantic settings

For config loading, use `pydantic-settings`:

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_prefix="APP_")

    database_url: str
    log_level: str = "INFO"
    debug: bool = False

settings = Settings()  # reads env vars automatically
```

## TypedDict

Use only when you must interop with `dict`-returning APIs:

```python
from typing import TypedDict, NotRequired

class StripeEvent(TypedDict):
    id: str
    type: str
    data: NotRequired[dict[str, object]]
```

- **Runtime-erased** — just hints, no validation.
- **`NotRequired`** for optional keys.
- Convert to a dataclass/Pydantic model at the module boundary for
  better downstream code.

## dataclass vs Pydantic: migration

Converting `@dataclass` to Pydantic is usually a search-and-replace:

```python
# Before
from dataclasses import dataclass

@dataclass
class User:
    id: str
    name: str

# After
from pydantic import BaseModel

class User(BaseModel):
    id: str
    name: str
```

The fields are identical. Pydantic v2 is fast enough that there's no
runtime cost concern for typical CRUD workloads. Migrate when you
start adding validators; don't migrate speculatively.

## Serialization

- **dataclass → dict:** `dataclasses.asdict(instance)`.
- **dataclass → JSON:** `json.dumps(asdict(instance), default=str)`.
  Beware of datetimes, Decimals, UUIDs — `default=str` is a lazy
  catch-all.
- **Pydantic → dict:** `instance.model_dump()`.
- **Pydantic → JSON string:** `instance.model_dump_json()`.
- **Pydantic → JSON-safe dict (for serialization):**
  `instance.model_dump(mode='json')` — converts datetimes, UUIDs etc
  to strings.

## Inheritance

- Dataclass inheritance works but fields with defaults must come
  after fields without — this gets annoying fast. Prefer composition.
- Pydantic inheritance works cleanly and is a reasonable way to share
  fields across request/response models.

## Anti-patterns

- Using Pydantic for every internal dataclass "because validation is
  nice" — the overhead adds up and most internal data is already
  valid.
- Using `@dataclass` for HTTP request payloads — no validation, so
  bad input crashes deep in your code.
- Mixing Pydantic v1 and v2 in the same project — migrate in one go.
- `BaseModel.model_config = {'arbitrary_types_allowed': True}` — this
  disables validation for those types; usually means you should use
  a dataclass instead.
- Writing custom `__init__` on a dataclass — lose all the auto-generated
  features. Use `__post_init__` instead.
- Serializing with `json.dumps(asdict(x))` when the dataclass has
  datetimes — will fail silently or raise at runtime.

## Tool detection

```bash
for tool in python3 uv pyright; do
  command -v "$tool" >/dev/null && echo "ok: $tool" || echo "MISSING: $tool"
done
```

## References

- dataclasses: https://docs.python.org/3/library/dataclasses.html
- Pydantic v2: https://docs.pydantic.dev/latest/
- Pydantic migration guide: https://docs.pydantic.dev/latest/migration/
- pydantic-settings: https://docs.pydantic.dev/latest/concepts/pydantic_settings/
- attrs (alternative): https://www.attrs.org/
