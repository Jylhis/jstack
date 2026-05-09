---
name: java
description: Use for modern Java 21 LTS work — code style (Google Java Style + google-java-format, records, sealed interfaces, pattern-matching switch JEP 441, var, text blocks, Optional, JSpecify nullness, java.time, SLF4J), and concurrency (virtual threads JEP 444, structured concurrency StructuredTaskScope, CompletableFuture chains, ReentrantLock vs synchronized on virtual threads, ConcurrentHashMap, AutoCloseable executors). Read the matching reference before acting.
---

# Java skill index

Pick the topic and read its reference before writing or reviewing
Java 21 code.

| Topic | When to read | Reference |
|---|---|---|
| Code style | Google Java Style, google-java-format, records + compact ctors, sealed interfaces, pattern-matching switch (JEP 441), var, text blocks, Optional, JSpecify, java.time, SLF4J | `references/code-style.md` |
| Concurrency | virtual threads (JEP 444), StructuredTaskScope, CompletableFuture chains, ReentrantLock / ReadWriteLock, ConcurrentHashMap, atomics, AutoCloseable executors via try-with-resources | `references/concurrency.md` |

For Gradle build, packaging to Maven Central, or JUnit/AssertJ/kotest
testing, use the `jvm` skill. For JVM **security** topics (JNDI,
deserialization, XXE, SSRF, SQLi, secrets, crypto), use `security`.

After reading the reference, follow its guidance for the task.
