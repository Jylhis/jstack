---
name: domain-fintech
description: "Use when building fintech apps. Keywords: fintech, trading, decimal, currency, financial, money, transaction, ledger, payment, exchange rate, precision, rounding, accounting, 金融, 交易系统, 货币, 支付"
user-invocable: false
---

# FinTech Domain

## Domain Constraints → Design Implications

| Domain Rule | Design Constraint | Rust Implication |
|-------------|-------------------|------------------|
| Audit trail | Immutable records | Arc<T>, no mutation |
| Precision | No floating point | rust_decimal |
| Consistency | Transaction boundaries | Clear ownership |
| Compliance | Complete logging | Structured tracing |
| Reproducibility | Deterministic execution | No race conditions |

---

## Key Crates

| Purpose | Crate |
|---------|-------|
| Decimal math | rust_decimal |
| Date/time | chrono, time |
| UUID | uuid |
| Serialization | serde |
| Validation | validator |

## Design Patterns

| Pattern | Purpose | Implementation |
|---------|---------|----------------|
| Currency newtype | Type safety | `struct Amount(Decimal);` |
| Transaction | Atomic operations | Event sourcing |
| Audit log | Traceability | Structured logging with trace IDs |
| Ledger | Double-entry | Debit/credit balance |

## Code Pattern: Currency Type

```rust
use rust_decimal::Decimal;

#[derive(Clone, Debug, PartialEq)]
pub struct Amount {
    value: Decimal,
    currency: Currency,
}

impl Amount {
    pub fn new(value: Decimal, currency: Currency) -> Self {
        Self { value, currency }
    }

    pub fn add(&self, other: &Amount) -> Result<Amount, CurrencyMismatch> {
        if self.currency != other.currency {
            return Err(CurrencyMismatch);
        }
        Ok(Amount::new(self.value + other.value, self.currency))
    }
}
```

---

## Common Mistakes

| Mistake | Domain Violation | Fix |
|---------|-----------------|-----|
| Using f64 | Precision loss | rust_decimal |
| Mutable transaction | Audit trail broken | Immutable + events |
| String for amount | No validation | Validated newtype |
| Silent overflow | Money disappears | Checked arithmetic |

