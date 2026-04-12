---
description: Review code changes before they land. Works with PRs, MRs, branch diffs, or staged changes.
---

# Review

Review code changes before they land. Works with PRs, MRs, branch diffs, or staged changes.

## Steps

### 1. Determine what to review

If the user gave a PR/MR number or URL, fetch it. Otherwise, diff the current branch against the base branch. Detect the default branch dynamically — don't assume `main`.

If reviewing a PR, also read the PR description. Note whether the description explains the *why* behind the change, not just the *what*.

### 2. Read the diff and its context

Read the full diff. For each changed file, also read the surrounding code — not just the changed lines. Understand:
- What changed
- What the change connects to (callers, consumers, related modules)
- What the author was trying to accomplish
- Whether the commit history tells a coherent story

### 3. Check the change against these dimensions

**Correctness**
- Does it do what it claims?
- Edge cases: nil/null, empty collections, boundary values, concurrent access
- Off-by-one errors, incorrect operator precedence, wrong comparison direction
- Are error paths handled? Do errors propagate correctly or get silently swallowed?
- If state is mutated, is the mutation safe and observable where it needs to be?

**Security**
- Injection (SQL, command, template, log)
- Auth and authz bypass, privilege escalation
- Secrets or credentials in code, config, or logs
- Unsafe deserialization, path traversal, open redirects
- User input reaching sensitive operations without validation

**Tests**
- Are the changes tested?
- Are the tests testing behavior, or just re-asserting the implementation?
- Are failure paths and edge cases covered, not just the happy path?
- If the change fixes a bug, is there a regression test for the specific bug?
- Do existing tests still make sense after the change, or do some need updating?

**Design and complexity**
- Is the approach the simplest one that works?
- Could any of this be replaced by existing functionality in the codebase or standard library?
- Are abstractions introduced only when they earn their weight? (No single-use helpers, premature generalization)
- Is control flow easy to follow?

**Naming and readability**
- Do names say what things are?
- Are abbreviations clear from context?
- Would a new team member understand the intent without explanation?

**API and interface changes**
- Are public APIs, configs, or schemas changing?
- Is backward compatibility preserved, or is the break intentional and documented?
- Are deprecations communicated?

**Resource and performance**
- File handles, connections, goroutines, subscriptions — are they cleaned up?
- Any unbounded growth (maps that never shrink, event listeners never removed)?
- N+1 queries, unnecessary allocations in hot paths, missing pagination
- Only flag performance when the change is in a path where it actually matters.

**Consistency with the codebase**
- Does the change follow existing patterns and conventions already in use?
- Check CLAUDE.md or contributing guidelines if present — does the change comply?
- Is the error handling style consistent with the rest of the project?

### 4. Flag issues by severity

- **Must-fix**: bugs, security holes, data loss risks, correctness failures
- **Should-fix**: unclear code, missing tests, poor naming, broken conventions
- **Nit**: style, minor improvements, optional cleanups

### 5. Acknowledge what is good

If the approach is clean, a test is well-written, or a design decision is thoughtful — say so. Specific praise is more useful than generic praise.

## Output

Group findings by severity. For each issue:
- Name the file and line
- Describe the problem concretely
- Suggest a fix or alternative

End with an overall verdict: **ship it**, **ship with fixes**, or **rethink**.

If the change is large, lead with a one-paragraph summary of what the change does and your overall impression before listing individual findings.
