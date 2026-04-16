---
name: golang-benchmark
description: "Golang benchmarking, profiling, and performance measurement. Use when writing, running, or comparing Go benchmarks, profiling hot paths with pprof, interpreting CPU/memory/trace profiles, analyzing results with benchstat, setting up CI benchmark regression detection, or investigating production performance with Prometheus runtime metrics. Also use when the developer needs deep analysis on a specific performance indicator - this skill provides the measurement methodology, while golang-performance provides the optimization patterns."
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Golang.
metadata:
  author: samber
  version: "1.1.2"
  openclaw:
    emoji: "📊"
    homepage: https://github.com/samber/cc-skills-golang
    requires:
      bins:
        - go
        - benchstat
    install:
      - kind: go
        package: golang.org/x/perf/cmd/benchstat@latest
        bins: [benchstat]
allowed-tools: Read Edit Write Glob Grep Bash(go:*) Bash(golangci-lint:*) Bash(git:*) Agent WebFetch Bash(benchstat:*) Bash(benchdiff:*) Bash(cob:*) Bash(gobenchdata:*) Bash(curl:*) mcp__context7__resolve-library-id mcp__context7__query-docs WebSearch AskUserQuestion
---

**Persona:** You are a Go performance measurement engineer. You never draw conclusions from a single benchmark run — statistical rigor and controlled conditions are prerequisites before any optimization decision.

**Thinking mode:** Use `ultrathink` for benchmark analysis, profile interpretation, and performance comparison.

# Go Benchmarking & Performance Measurement

Full measurement workflow: write, run, profile, compare with statistical rigor, track regressions in CI. For optimization patterns after measurement, see `samber/cc-skills-golang@golang-performance`. For pprof on running services, see `samber/cc-skills-golang@golang-troubleshooting`.

## Writing Benchmarks

### `b.Loop()` (Go 1.24+) — preferred

`b.Loop()` prevents the compiler from optimizing away the code under test — without it, the compiler can detect dead results and eliminate them, producing misleadingly fast numbers. It also excludes setup code before the loop from timing automatically. **Go 1.26+**: `b.Loop()` no longer prevents inlining of the benchmarked function, producing more accurate results that reflect real-world performance.

```go
func BenchmarkParse(b *testing.B) {
    data := loadFixture("large.json") // setup — excluded from timing
    for b.Loop() {
        Parse(data)  // compiler cannot eliminate this call
    }
}
```

Existing `for range b.N` benchmarks still work but should migrate to `b.Loop()` — the old pattern requires manual `b.ResetTimer()` and a package-level sink variable to prevent dead code elimination.

### Memory tracking

```go
func BenchmarkAlloc(b *testing.B) {
    b.ReportAllocs() // or run with -benchmem flag
    for b.Loop() {
        _ = make([]byte, 1024)
    }
}
```

`b.ReportMetric()` adds custom metrics (e.g., throughput):

```go
b.ReportMetric(float64(totalBytes)/b.Elapsed().Seconds(), "bytes/s")
```

### Sub-benchmarks and table-driven

```go
func BenchmarkEncode(b *testing.B) {
    for _, size := range []int{64, 256, 4096} {
        b.Run(fmt.Sprintf("size=%d", size), func(b *testing.B) {
            data := make([]byte, size)
            for b.Loop() {
                Encode(data)
            }
        })
    }
}
```

## Running Benchmarks

```bash
go test -bench=BenchmarkEncode -benchmem -count=10 ./pkg/... | tee bench.txt
```

| Flag                   | Purpose                                   |
| ---------------------- | ----------------------------------------- |
| `-bench=.`             | Run all benchmarks (regexp filter)        |
| `-benchmem`            | Report allocations (B/op, allocs/op)      |
| `-count=10`            | Run 10 times for statistical significance |
| `-benchtime=3s`        | Minimum time per benchmark (default 1s)   |
| `-cpu=1,2,4`           | Run with different GOMAXPROCS values      |
| `-cpuprofile=cpu.prof` | Write CPU profile                         |
| `-memprofile=mem.prof` | Write memory profile                      |
| `-trace=trace.out`     | Write execution trace                     |

**Output format:** `BenchmarkEncode/size=64-8  5000000  230.5 ns/op  128 B/op  2 allocs/op` — the `-8` suffix is GOMAXPROCS, `ns/op` is time per operation, `B/op` is bytes allocated per op, `allocs/op` is heap allocation count per op.

## Profiling from Benchmarks

Generate profiles directly from benchmark runs — no HTTP server needed:

```bash
# CPU profile
go test -bench=BenchmarkParse -cpuprofile=cpu.prof ./pkg/parser
go tool pprof cpu.prof

# Memory profile (alloc_objects shows GC churn, inuse_space shows leaks)
go test -bench=BenchmarkParse -memprofile=mem.prof ./pkg/parser
go tool pprof -alloc_objects mem.prof

# Execution trace
go test -bench=BenchmarkParse -trace=trace.out ./pkg/parser
go tool trace trace.out
```

For full pprof CLI reference (all commands, non-interactive mode, profile interpretation), see [pprof Reference](./references/pprof.md). For execution trace interpretation, see [Trace Reference](./references/trace.md). For statistical comparison, see [benchstat Reference](./references/benchstat.md).

## Reference Files

- **[pprof Reference](./references/pprof.md)** — CPU, memory, goroutine profile analysis (CLI, web UI, interpretation)
- **[benchstat Reference](./references/benchstat.md)** — Statistical comparison of benchmark runs with confidence intervals and p-values
- **[Trace Reference](./references/trace.md)** — Execution tracer: goroutine scheduling, GC phases, network blocking, custom spans
- **[Diagnostic Tools](./references/tools.md)** — fieldalignment, GODEBUG, fgprof, race detector, and other focused diagnostics
- **[Compiler Analysis](./references/compiler-analysis.md)** — Escape analysis, inlining decisions, SSA dump, assembly output
- **[CI Regression Detection](./references/ci-regression.md)** — benchdiff, cob, gobenchdata for automated regression gating in CI
- **[Investigation Session](./references/investigation-session.md)** — Production troubleshooting with Prometheus runtime metrics and PromQL
- **[Prometheus Go Metrics Reference](./references/prometheus-go-metrics.md)** — Go runtime metrics exposed via `prometheus/client_golang`

## Cross-References

- `samber/cc-skills-golang@golang-performance` — optimization patterns after measuring
- `samber/cc-skills-golang@golang-troubleshooting` — pprof on running services, Delve, GODEBUG
- `samber/cc-skills-golang@golang-observability` — always-on monitoring, Pyroscope, OpenTelemetry
- `samber/cc-skills-golang@golang-testing` — general testing practices
- `samber/cc-skills@promql-cli` — querying Prometheus runtime metrics
