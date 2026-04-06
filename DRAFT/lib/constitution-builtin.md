# Jstack Built-in Principles (always active)

These principles ship with jstack and apply to all projects automatically.
Project-level `constitution.md` extends or overrides these — never replaces entirely.

---

## Engineering

- Test-driven development. Tests before implementation. RED-GREEN-REFACTOR.
- YAGNI. Do not build what is not specified.
- DRY within reason. Premature abstraction is worse than duplication.
- Atomic commits. Each commit is a single logical change that passes all tests.
- Code review before merge. No direct pushes to main/production branches.

## Quality

- Every behavior has a test. Untested code is assumed broken.
- Every bug fix includes a regression test.
- Type safety where the language supports it.
- Errors are handled explicitly, never silently swallowed.

## Process

- Spec before code. Understand what you are building before you build it.
- Plan before implementation. Know the order of operations.
- Review before ship. Someone (or something) other than the author checks the work.

## Communication

- Commit messages follow Conventional Commits.
- PR/MR descriptions explain why, not just what.
- Specs and plans are written for humans, not machines.
