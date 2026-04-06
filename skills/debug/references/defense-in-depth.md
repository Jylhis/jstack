# Defense in depth

Once you've found the root cause of a bug caused by invalid data reaching code that can't handle it, a single validation check at the point you just fixed is usually not enough. Different callers, mocks, refactors, or platform differences will find their way around it. When the cost of the bug recurring is high, add checks at every layer the data passes through so the bug becomes structurally impossible, not just unlikely.

Not every bug needs this. Use it when the failure mode is severe (data loss, destructive filesystem or git operations, security boundary, silent corruption) or when the data flows through several components that each assume the previous one validated it.

## The layers

Entry point. Reject obviously invalid input at the API boundary — empty, wrong type, path doesn't exist, out of range. This catches the majority of real cases with the clearest error message.

Business logic. Re-check the invariants the current operation actually depends on, even if an outer layer already checked. Different callers reach the same function through different paths; some of them skip the entry check.

Environment guard. Refuse dangerous operations in contexts where they shouldn't happen at all. For example, refuse to run destructive filesystem or git commands outside a temp directory while tests are running, or refuse to write to production paths when a dev flag is set. This catches the cases where the data looks valid but the context is wrong.

Debug instrumentation. Log the inputs and a stack trace immediately before the dangerous operation. When one of the earlier layers is bypassed in a way you didn't anticipate, this is what tells you how it happened.

## Applying it

Trace the data flow from where the bad value originates to where it causes harm. List every function boundary it crosses. At each boundary, ask which of the four layers fits — not all bugs need all four. Then try to bypass each layer from the outside and confirm the next one catches it.

The point is not to be paranoid everywhere. The point is that when you've just spent real time tracking down a nasty bug, the cheapest moment to prevent its cousins is right now, while the data flow is fresh in your head.
