---
description: Find the root cause of a software issue. No guessing, no shotgun fixes.
---

# Debug

Find the root cause of a software issue. No guessing, no shotgun fixes.

## Steps

1. Get the symptoms: error message, full stack trace, repro steps, expected vs actual behavior, and what changed recently. If the user gave partial info, ask for the rest.
2. Form a hypothesis. Say it out loud: "I think X is happening because Y." Be specific enough that the next observation will confirm or kill it.
3. Read the relevant code and trace the execution path. When the bug spans multiple components (CI → build → signing, request → service → DB), instrument the boundaries first — log what enters and leaves each layer, run once, and let the evidence tell you which layer is wrong before you touch any of them.
4. Trace backward from the bad value, not forward from the error. The line that throws is usually a victim. Walk up the call chain until you find where the bad value was first produced, and fix it there.
5. Verify the hypothesis with evidence: log output, test results, debugger state, or code analysis. If the evidence contradicts the hypothesis, form a new one. Don't force-fit.
6. Once you have the root cause, propose a fix. Explain what it changes and why that addresses the cause, not the symptom.

## When print debugging isn't enough

If you're adding more log lines than you're learning from, or the bug depends on state you can't easily serialize, reach for an interactive debugger through the project's language-specific plugin. Set a breakpoint where the problem *begins*, not where it manifests. If two hypotheses fail at the same breakpoint, your mental model is wrong — rethink from scratch rather than poking the same spot a third time.

## Rules

- No fix without a root cause. "I'm not sure why it's broken" is a valid answer. A random change that happens to work is not.
- One change at a time. Bundled fixes hide which one actually worked and tend to introduce new bugs.
- If you apply a fix, write a regression test that fails without the fix and passes with it.
- If you've tried 3 hypotheses and none panned out, stop and tell the user what you've ruled out. That's still useful progress.
- If each fix you try reveals a new problem in a different place, that's not a hypothesis problem — it's an architecture problem. Stop fixing and raise it with the user before the next attempt.

## Output

- **Root cause**: what is actually wrong, with evidence
- **Fix**: what to change and why
- **Regression test**: a test that would catch this if it came back

## See also

- `references/defense-in-depth.md` — once you've found the root cause of a data-validity bug, consider adding checks at multiple layers so the same class of bug can't come back through a different path.
