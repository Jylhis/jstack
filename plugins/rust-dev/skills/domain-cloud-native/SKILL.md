---
name: domain-cloud-native
description: "Use when building cloud-native apps. Keywords: kubernetes, k8s, docker, container, grpc, tonic, microservice, service mesh, observability, tracing, metrics, health check, cloud, deployment, 云原生, 微服务, 容器"
user-invocable: false
---

# Cloud-Native Domain

## Domain Constraints → Design Implications

| Domain Rule | Design Constraint | Rust Implication |
|-------------|-------------------|------------------|
| 12-Factor | Config from env | Environment-based config |
| Observability | Metrics + traces | tracing + opentelemetry |
| Health checks | Liveness/readiness | Dedicated endpoints |
| Graceful shutdown | Clean termination | Signal handling |
| Horizontal scale | Stateless design | No local state |
| Container-friendly | Small binaries | Release optimization |

---

## Key Crates

| Purpose | Crate |
|---------|-------|
| gRPC | tonic |
| Kubernetes | kube, kube-runtime |
| Docker | bollard |
| Tracing | tracing, opentelemetry |
| Metrics | prometheus, metrics |
| Config | config, figment |
| Health | HTTP endpoints |

## Design Patterns

| Pattern | Purpose | Implementation |
|---------|---------|----------------|
| gRPC services | Service mesh | tonic + tower |
| K8s operators | Custom resources | kube-runtime Controller |
| Observability | Debugging | tracing + OTEL |
| Health checks | Orchestration | `/health`, `/ready` |
| Config | 12-factor | Env vars + secrets |

## Code Pattern: Graceful Shutdown

```rust
use tokio::signal;

async fn run_server() -> anyhow::Result<()> {
    let app = Router::new()
        .route("/health", get(health))
        .route("/ready", get(ready));

    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .with_graceful_shutdown(shutdown_signal())
        .await?;

    Ok(())
}

async fn shutdown_signal() {
    signal::ctrl_c().await.expect("failed to listen for ctrl+c");
    tracing::info!("shutdown signal received");
}
```

## Health Check Pattern

```rust
async fn health() -> StatusCode {
    StatusCode::OK
}

async fn ready(State(db): State<Arc<DbPool>>) -> StatusCode {
    match db.ping().await {
        Ok(_) => StatusCode::OK,
        Err(_) => StatusCode::SERVICE_UNAVAILABLE,
    }
}
```

---

## Common Mistakes

| Mistake | Domain Violation | Fix |
|---------|-----------------|-----|
| Local file state | Not stateless | External storage |
| No SIGTERM handling | Hard kills | Graceful shutdown |
| No tracing | Can't debug | tracing spans |
| Static config | Not 12-factor | Env vars |

