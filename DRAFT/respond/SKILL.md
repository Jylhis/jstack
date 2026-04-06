---
name: respond
description: |
  Parse PR/MR review comments, categorize them, implement fixes, draft responses,
  and re-request review. Turns review feedback into action without context-switching.
  Use when asked to "respond to review", "address comments", "fix review feedback",
  or "handle PR comments".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
  - WebSearch
---

> **Preamble:** Read and apply `lib/preamble.md` before proceeding.

# /respond: Review Comment Resolution

You are running the `/respond` workflow. Parse review comments from a PR/MR,
categorize each one, implement necessary fixes, draft responses, and re-request
review. The goal is to close the feedback loop with zero context-switching for
the developer.

---

## Artifact Contract

**PRODUCES:**
- Code fixes (atomic commits per comment or group)
- Review responses (posted to PR/MR comments)

**REQUIRES:** PR/MR with review comments (GitHub PR or GitLab MR)
**READS:** spec.md, plan.md, constitution (optional but consulted when present)

---

## Steps

### Step 1: Fetch Review Comments

1. Detect the current PR/MR:
   ```bash
   gh pr view --json number,url,reviewDecision,reviews,comments 2>/dev/null
   ```
   If no PR exists for this branch, stop: "No PR found for this branch. Run /ship first."

2. Fetch all review comments including inline code comments:
   ```bash
   gh api repos/{owner}/{repo}/pulls/{number}/comments
   gh api repos/{owner}/{repo}/issues/{number}/comments
   ```

3. Filter to unresolved comments only. Skip resolved threads and bot comments.

### Step 2: Categorize Comments

For each comment, classify into exactly one category:

| Category       | Description                                | Action            |
|----------------|--------------------------------------------|-------------------|
| **must-fix**   | Correctness issue, bug, security concern   | Implement fix     |
| **discussion** | Architecture question, design alternative  | Draft response    |
| **nit**        | Style, naming, minor improvement           | Fix if trivial    |
| **praise**     | Positive feedback, approval                | Acknowledge       |

Classify by keyword signals ("bug"/"broken" -> must-fix, "consider"/"what about" -> discussion,
"nit"/"minor" -> nit, "LGTM"/"+1" -> praise). If ambiguous, thread context and request-changes
status signal intent. Output categorization table before proceeding.

### Step 3: Read Context

Read spec.md, plan.md, constitution. For each must-fix/nit, read referenced file and context.

### Step 4: Implement Fixes

For each **must-fix** comment:
1. Read the referenced code and understand the reviewer's concern.
2. Implement the fix. Prefer the reviewer's suggested approach unless it conflicts
   with spec.md or constitution.
3. If the fix requires a different approach than suggested, note why in the response.
4. Commit: `git add <files> && git commit -m "fix: address review -- <description>"`

For each **nit** comment:
1. If the fix is trivial (rename, formatting, small refactor), implement it.
2. Group multiple nits into a single commit: `git commit -m "fix: address review nits"`
3. If a nit requires significant effort, recategorize as discussion.

### Step 5: Draft Responses

For each comment, draft a response appropriate to its category:
- **must-fix (fixed):** "Fixed in <sha>. <1-line what changed and why.>"
- **must-fix (disagreement):** Explain alternative approach, cite spec.md if applicable.
- **discussion:** Thoughtful response with evidence. Agree and act, or disagree with data.
- **nit (fixed):** "Fixed. <sha>"
- **praise:** Brief acknowledgment.

### Step 6: Present Response Plan

Show all drafted responses in a summary table: `[category] @reviewer file:line -> action`.
Ask: "Post these responses and push fixes? A) Yes  B) Edit first  C) Abort"

### Step 7: Post and Push

Push fix commits, post each response as a reply. If all must-fix items resolved,
re-request review via `gh pr edit --add-reviewer`. Output summary of actions taken.

---

## Output Format

```markdown
# Respond: PR #<number>

**Date:** YYYY-MM-DD | **Branch:** <name> | **Comments:** N

## Categorization
| # | Reviewer | File:Line | Category | Action |

## Fixes Applied
- <sha>: <description> (comment #N)

## Status
Must-fix: X/Y resolved | Nits: A/B | Discussions: C/D | Re-requested: yes/no
```

---

## Important Rules

- Never ignore must-fix comments. Every one gets a fix or a substantive explanation.
- Never argue with reviewers combatively. Be factual, cite evidence.
- Never bundle must-fix and nit commits. Must-fixes get their own commits.
- Always show the response plan before posting. The user must approve.
- If a reviewer's suggestion conflicts with spec.md, explain the conflict. Do not
  silently ignore the suggestion.
- If a comment is ambiguous, ask the user to clarify rather than guessing.
- Re-request review only when all must-fix items are addressed.
