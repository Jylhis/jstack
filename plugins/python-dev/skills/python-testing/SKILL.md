---
name: python-testing
description: >
  pytest testing patterns for Python: fixtures, parametrize, async tests,
  mocks, coverage, running a single test. Apply when writing or debugging
  Python tests.
---

# Python testing with pytest

pytest is the standard Python test runner. Do not use `unittest` in new
projects — it is noisier, less ergonomic, and lacks the fixture model.

## Install (via uv)

```bash
uv add --dev pytest pytest-asyncio pytest-cov
```

## Project layout

```
my_package/
├── src/
│   └── my_package/
│       └── __init__.py
└── tests/
    ├── conftest.py      # shared fixtures
    ├── test_users.py
    └── integration/
        └── test_api.py
```

Put tests in a `tests/` directory next to `src/`. Use the `src` layout
for the package itself — it prevents accidental imports from the repo
root without an install.

## `pyproject.toml` config

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["src"]
addopts = "-ra --strict-markers --strict-config"
markers = [
    "slow: deselect with -m 'not slow'",
    "integration: integration tests that hit external services",
]
asyncio_mode = "auto"
```

- `-ra` — short summary of failures.
- `--strict-markers` — fail on unknown `@pytest.mark.*` usage.
- `asyncio_mode = "auto"` — pytest-asyncio picks up `async def` tests
  without decorators.

## Minimal test

```python
# tests/test_users.py
import pytest
from my_package.users import User, normalize_email

def test_normalize_email_lowercases() -> None:
    assert normalize_email("Foo@Bar.com") == "foo@bar.com"

def test_normalize_email_strips_whitespace() -> None:
    assert normalize_email(" foo@bar.com ") == "foo@bar.com"
```

- One assertion per test when possible. Multiple assertions are fine if
  they test the same behaviour.
- Test names describe the behaviour: `test_<what>_<condition>`.

## Fixtures

```python
# tests/conftest.py
import pytest
from my_package.db import Database

@pytest.fixture
def db() -> Database:
    db = Database(":memory:")
    db.migrate()
    yield db
    db.close()

@pytest.fixture
def user(db: Database) -> User:
    return db.create_user(name="alice")
```

- `conftest.py` holds fixtures shared across a directory.
- Fixture scope: `function` (default), `class`, `module`, `session`.
  Use the smallest scope that works — session fixtures create hidden
  test coupling.
- Fixtures can depend on other fixtures by taking them as parameters.
- `yield` lets you run teardown after the test.

## Parametrize

```python
@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("Foo@Bar.com", "foo@bar.com"),
        (" foo@bar.com ", "foo@bar.com"),
        ("FOO+tag@BAR.com", "foo+tag@bar.com"),
    ],
    ids=["case", "whitespace", "plus-tag"],
)
def test_normalize_email(raw: str, expected: str) -> None:
    assert normalize_email(raw) == expected
```

- Always include `ids=` — it makes failure messages readable.
- Put the complex case table at the top of the file for visibility.

## Async tests

With `asyncio_mode = "auto"`:

```python
async def test_fetches_user(client: httpx.AsyncClient) -> None:
    user = await client.get_user("42")
    assert user.id == "42"
```

No `@pytest.mark.asyncio` needed with auto mode.

## Mocks

Prefer dependency injection over `unittest.mock`. Pass fakes as
fixtures:

```python
@pytest.fixture
def fake_http() -> FakeHttpClient:
    return FakeHttpClient(responses={"/users/42": {"id": "42"}})
```

When you must patch:

```python
from unittest.mock import patch

def test_fetch_retries_on_500(monkeypatch) -> None:
    calls = []
    def fake_get(url: str) -> Response:
        calls.append(url)
        return Response(status=500 if len(calls) == 1 else 200)
    monkeypatch.setattr("my_package.http.get", fake_get)
    fetch_with_retry("/users/42")
    assert len(calls) == 2
```

- Prefer `monkeypatch` fixture over `unittest.mock.patch` — it
  auto-cleans and has clearer errors.
- Patch the **import site**, not the source. If `module_a` does
  `from module_b import get`, patch `module_a.get`.

## Assertions

pytest rewrites `assert` statements to give detailed diffs. Use plain
`assert`:

```python
assert user.name == "alice"
assert sorted(ids) == [1, 2, 3]
assert "error" not in response
```

For exceptions:

```python
with pytest.raises(ValueError, match="invalid email"):
    normalize_email("not-an-email")
```

`match=` is a regex against `str(exception)`.

## Running

```bash
uv run pytest                              # all tests
uv run pytest tests/test_users.py          # one file
uv run pytest tests/test_users.py::test_normalize_email_lowercases
uv run pytest -k "normalize"               # filter by name substring
uv run pytest -m "not slow"                # marker filter
uv run pytest --cov=my_package --cov-report=term-missing
uv run pytest -x                           # stop on first failure
uv run pytest --lf                         # rerun last failures
```

## Anti-patterns

- Mocking the thing you're testing.
- `if` statements inside tests — parametrize instead.
- Tests that depend on execution order (use `--randomly` to catch this).
- Sleeping with `time.sleep()` — use fake clocks or events.
- `assert True` / `assert 1 == 1` as a placeholder.
- Shared mutable state across tests via module-level variables.

## Tool detection

```bash
for tool in python3 pytest uv; do
  command -v "$tool" >/dev/null && echo "ok: $tool" || echo "MISSING: $tool"
done
```

## References

- pytest docs: https://docs.pytest.org
- pytest fixtures: https://docs.pytest.org/en/stable/explanation/fixtures.html
- pytest-asyncio: https://pytest-asyncio.readthedocs.io
- Coverage.py: https://coverage.readthedocs.io
