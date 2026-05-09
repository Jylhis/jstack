---
name: kotlin
description: Use for Kotlin 2.0+ work — idiomatic style (val over var, read-only List/Map/Set, data classes + copy(), sealed interface hierarchies + exhaustive when, scope functions let/apply/also/run/with, null-safety ?./?:/!! at boundaries, object + companion, top-level extension functions, asSequence chains) and coroutines with kotlinx.coroutines 1.9+ (launch / async / runBlocking, suspend functions, coroutineScope / supervisorScope, withContext + Dispatchers, cooperative cancellation, withTimeout, cold Flow + flowOn, hot StateFlow / SharedFlow, runTest with StandardTestDispatcher). Read the matching reference before acting.
---

# Kotlin skill index

Pick the topic and read its reference before writing or reviewing
Kotlin 2.0+ code.

| Topic | When to read | Reference |
|---|---|---|
| Code style | val over var, read-only collections, data classes, sealed interface hierarchies + exhaustive when, scope functions, null-safety, object + companion, top-level extension functions, asSequence | `references/code-style.md` |
| Coroutines | launch / async / runBlocking, suspend functions, structured concurrency (coroutineScope / supervisorScope), withContext + Dispatchers, cancellation, withTimeout, Flow / StateFlow / SharedFlow, runTest | `references/coroutines.md` |

For Gradle builds, Maven Central publishing, or kotest/mockk testing
infrastructure, use the `jvm` skill.

After reading the reference, follow its guidance for the task.
