---
name: python-security
description: >
  Python security footguns and safe alternatives: subprocess injection,
  pickle deserialization, yaml.load, SSRF, SQL injection, secrets
  management, path traversal. Apply when handling untrusted input or
  external services.
---

# Python security

Python's standard library has several sharp edges. Memorise the unsafe
API and its safe alternative so you can spot bugs during review.

## Command injection: `subprocess`

**Never** use `shell=True` with untrusted input:

```python
# WRONG
import subprocess
subprocess.run(f"grep {user_input} file.log", shell=True)
```

```python
# RIGHT
subprocess.run(["grep", user_input, "file.log"], check=True)
```

- `shell=False` is the default; do not override.
- `check=True` raises `CalledProcessError` on non-zero exit — always
  include it unless you explicitly handle the exit code.
- `capture_output=True` captures stdout and stderr; use `text=True`
  for string output.
- For shell pipelines, build them explicitly with two `subprocess.run`
  calls, not a shell string.

If you must use `shell=True` (e.g. embedded shell fragment from
config), use `shlex.quote`:

```python
safe = shlex.quote(user_input)
subprocess.run(f"grep {safe} file.log", shell=True)
```

## Deserialization: `pickle`

**Never unpickle untrusted data.** `pickle.loads` can execute
arbitrary code.

```python
# DANGEROUS
data = pickle.loads(request.body)   # RCE if attacker controls body
```

Alternatives:
- **JSON** (`json.loads`) — safe but only basic types.
- **Pydantic `model_validate_json`** — safe + validation.
- **`msgpack`** — binary, safe, faster than JSON.
- **`marshmallow`** — safe schema-based deserialization.

Pickle is for trusted data only (your own local cache files, RPC
between trusted processes). If you need one-way persistence of
untrusted data, use JSON.

## `yaml.load` pitfall

`yaml.load(data)` uses the full loader by default and can execute
arbitrary Python. **Always use `yaml.safe_load`:**

```python
import yaml

# WRONG
config = yaml.load(text)          # RCE risk

# RIGHT
config = yaml.safe_load(text)
```

PyYAML 6.0 deprecated `yaml.load` without an explicit `Loader=`, but
`yaml.load(text, Loader=yaml.FullLoader)` is still unsafe. Always
`safe_load` for config and untrusted input.

## SQL injection

Never build SQL with string concatenation:

```python
# WRONG
cursor.execute(f"SELECT * FROM users WHERE id = '{user_id}'")
```

```python
# RIGHT — parameterized
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

- Use your driver's parameter binding (`%s`, `?`, `:name` depending on
  driver).
- Use an ORM (SQLAlchemy, Drizzle, Django ORM) that parameterizes by
  default — audit any `.raw()` / `.execute()` calls.
- Never trust column or table names from user input — if you must
  allow dynamic schema references, validate against an allowlist.

## SSRF (Server-Side Request Forgery)

If your server fetches URLs based on user input:

```python
import httpx
from urllib.parse import urlparse
import ipaddress
import socket

def is_safe_url(url: str) -> bool:
    parsed = urlparse(url)
    if parsed.scheme not in {"http", "https"}:
        return False
    host = parsed.hostname
    if host is None:
        return False
    # Resolve once, then check
    try:
        ip = ipaddress.ip_address(socket.gethostbyname(host))
    except (OSError, ValueError):
        return False
    return not (ip.is_private or ip.is_loopback or ip.is_link_local or ip.is_multicast)
```

- Always parse and validate **before** fetching.
- Resolve the hostname **once**, then fetch by IP if possible to prevent
  DNS rebinding.
- Block cloud metadata endpoints explicitly (`169.254.169.254`).
- Consider a purpose-built library like `ssrf-req-filter` rather than
  rolling your own.

## Path traversal

```python
# WRONG — accepts ../../etc/passwd
def read_file(name: str) -> str:
    return (Path("/var/data") / name).read_text()
```

```python
# RIGHT — resolve and verify
def read_file(name: str) -> str:
    base = Path("/var/data").resolve()
    target = (base / name).resolve()
    if not target.is_relative_to(base):
        raise ValueError("path outside base directory")
    return target.read_text()
```

- `Path.is_relative_to(base)` (3.9+) checks containment after
  `.resolve()`.
- Never trust a user-supplied filename to stay inside a directory
  without verification.

## Secrets

- **Never commit secrets.** `.env` files in dev, secrets manager in
  production.
- **Never log secrets.** Configure logger filters to redact `password`,
  `token`, `authorization`, `cookie`.
- **Use `secrets` module** for cryptographic random, not `random`:
  ```python
  import secrets
  token = secrets.token_urlsafe(32)
  api_key = secrets.token_hex(16)
  ```
- **`hmac.compare_digest`** for constant-time comparison of tokens and
  hashes — never `==`.

## Password hashing

- **`argon2-cffi`** (preferred) or **`passlib[bcrypt]`** for password
  storage.
- Never SHA-256 a password — it is not slow enough.
- **Never roll your own.** Use the library's defaults.

## Dependency audit

```bash
uv run pip-audit                  # audit installed deps
uv run safety check               # alternative
```

For supply-chain scanning: `socket.dev`, `snyk`, or Dependabot.

## JWT pitfalls

- Use **`PyJWT`** with explicit `algorithms=["HS256"]` — never
  `algorithms=["none"]` and never omit the `algorithms` parameter.
- Short expiry + refresh tokens, not long-lived access tokens.
- Verify `exp` and `nbf` — `PyJWT` does this by default but
  third-party libraries vary.

## `eval` and `exec`

Never call `eval()` or `exec()` on user input. There is effectively no
safe way. If you need to evaluate expressions (calculator, filter
language), use `ast.literal_eval` for literals only, or a purpose-built
DSL parser.

## Anti-patterns

- Using `requests` without a timeout — blocks the process indefinitely.
  Always pass `timeout=30`.
- Catching `Exception` and returning `None` — hides security errors.
- Logging the full request body on error — leaks PII and secrets.
- Returning stack traces to users in HTTP responses.
- Loading YAML/pickle from user uploads.
- Hardcoding `DEBUG=True` in production.
- Using `tempfile.mktemp()` (race condition) — use `tempfile.NamedTemporaryFile`.

## Tool detection

```bash
for tool in python3 uv pip-audit; do
  command -v "$tool" >/dev/null && echo "ok: $tool" || echo "MISSING: $tool"
done
```

## References

- OWASP Python cheat sheet: https://cheatsheetseries.owasp.org/cheatsheets/Python_Security_Cheat_Sheet.html
- `subprocess` security notes: https://docs.python.org/3/library/subprocess.html#security-considerations
- `secrets` module: https://docs.python.org/3/library/secrets.html
- PyCQA `bandit`: https://bandit.readthedocs.io (security linter — can integrate with ruff)
