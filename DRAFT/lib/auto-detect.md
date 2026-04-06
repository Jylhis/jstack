# Role Auto-Detection Logic

The bare command runs auto-detection. The logic is deterministic and based on observable signals.
You always override with explicit `:role` syntax. Auto-detection is a convenience, not a constraint.

---

## /brainstorm

```
IF no codebase exists AND description mentions users/customers/UX
  → :product
ELSE IF description mentions revenue/market/pricing/business
  → :business
ELSE IF codebase exists (audit.md or .git with history)
  → :scoped
ELSE
  → :engineer
```

## /research

```
IF /validate is likely next
  → :deep
ELSE
  → :light
```

## /validate

```
IF project has revenue/business context
  → :business
ELSE
  → :feature
```

## /plan

```
IF spec mentions multiple services, distributed system, migration
  → :architect
ELSE IF spec is primarily infra/deployment/CI-CD
  → :devops
ELSE
  → :engineer
```

## /implement

```
IF task involves UI files (tsx, jsx, html, css, svelte, vue)
  → :frontend
ELSE IF task involves API/server/database files
  → :backend
ELSE IF task involves Dockerfile, terraform, nix, k8s manifests, CI config
  → :infra
ELSE
  → :fullstack
```

## /review

```
IF you are the commit author
  → :solo
ELSE
  → :assist
THEN:
  IF diff touches auth, crypto, network, user input handling
    → also chain :security
  IF diff touches UI files
    → also chain :design
  IF diff touches hot paths or adds O(n²)+ algorithms
    → also chain :performance
```

## /qa

```
IF project has web UI (package.json with react/vue/svelte, or html files)
  → :browser
ELSE IF project is API-only (openapi spec, routes, no frontend)
  → :api
ELSE IF project is CLI tool
  → :cli
```

## /second-opinion

```
IF multiple models configured in jstack config
  → :model
ELSE
  → :clean
```
