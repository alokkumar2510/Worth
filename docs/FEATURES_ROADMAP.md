# Features Roadmap

**Everything below ships in Phase 1.** There is no Phase 2+ — this is a
single-phase build. The list is still ordered, because build order
within Phase 1 matters (later items depend on earlier ones existing
first), but "ordered" here means *sequence of construction*, not
*separate releases*. Nothing is held back from the user.

This intentionally overrides the earlier multi-phase staging. The
tradeoff is explicit: a longer time-to-first-usable-build, in exchange
for not having to revisit "is this V1 or V2" decisions later. See the
Risk Note at the end before committing to this — it has real
consequences, particularly for the two items marked ⚠️.

---

## Build Order (all within Phase 1)

### 1. Foundation
* Encrypted local database (Drift + SQLCipher)
* UUID primary keys across all tables
* Accounts (cash, bank, wallet, credit)
* People
* Settings (currency, theme — set once at onboarding)
* App Lock (biometric/PIN)

### 2. Ledger Core
* Transactions — income, expense, transfer, borrow_money, repay_money,
  lend_money, recover_money — using the from/to account schema
* Void transaction (correction mechanism)
* Balance Cache (account/person/investment) + Net Worth calculation
  service
* Audit log

### 3. Wealth Completeness
* Receivables module (full detail screens, recovery history)
* Liabilities module (full detail screens, credit account integration)
* Investments module with FIFO lot tracking, invested capital, market
  value, realized/unrealized gain, lot-level detail screens
* Expected Income module (pending/received/expired, linked income
  transaction on receipt)

### 4. Dashboard & Definitions
* Full Dashboard — Net Worth, Assets, Liabilities, Invested Capital,
  Expected Income summary cards
* Asset Allocation chart, Liability Distribution chart
* Net Worth Trend chart (30D/90D/1Y/ALL)
* Definitions Center (every financial term)

### 5. Trust & Recovery
* Encrypted JSON Backup
* Encrypted JSON Restore (full balance replay on import)
* Recalculate Balances (manual trigger, Settings → Advanced)
* Monthly Snapshots (lazy generation, retroactive backfill)

### 6. Insight Layer
* Reports — Monthly, Quarterly, Yearly
* Global Search (FTS5-backed)
* CSV Export (reports)

### 7. Polish & Retention
* Goals (passive milestone markers — explicitly not budgeting)
* Dark Mode
* Notes on all entities
* Constrained natural-language query ("How much does Sohan owe me?") —
  on-device intent classification + templated queries, no LLM API

### 8. Platform Expansion ⚠️
* Supabase Sync
* Multi-Device Support
* Automatic Cloud Backup
* Conflict resolution policy execution (see SYSTEM_DESIGN.md)

### 9. Previously-Speculative Features ⚠️
Each of these still needs the short spec described below *written*
before its build starts — "everything in Phase 1" does not waive that
requirement, it just means the spec-writing now sits on the critical
path instead of being deferred:

* **General-purpose AI Assistant** — needs a decision on LLM API vs
  fully on-device, and guardrails so it never implies unrealized gains
  are "real" net worth.
* **OCR Import** — needs a defined accuracy bar and correction UX before
  build; low accuracy here damages trust in the core numbers.
* **Shared Family Accounts** — needs a full multi-user data model and
  permissions spec.
* **Wealth Forecasting** — needs a defined methodology (assumptions,
  range vs point estimate).
* **Financial Health Score** — needs a transparent, documented formula.
* **Investment Analytics** (XIRR, benchmarking) — needs a defined metric
  set and exact formulas.

---

## Explicitly Out of Scope (Not Staged — Genuinely Not Built)

* Multi-currency conversion — until a dedicated spec exists
* Average-cost investment accounting — FIFO only, by design
* Budgeting, spending limits, envelope tracking — contradicts core
  positioning

---

## Risk Note — Read Before Committing to Single-Phase

Collapsing everything into one phase removes staged validation. Two
consequences are worth naming explicitly rather than discovering later:

1. **Cloud Sync and AI Assistant are architecturally risky to build
   before the ledger core has run against real transaction data.**
   The UUID/sync strategy in DATABASE_SCHEMA.md is designed to be
   sync-ready, but "designed to be ready" and "validated under real
   sync conflicts" are different claims. Building Sync in the same pass
   as the ledger means any modeling mistake in the ledger gets
   propagated into the sync layer before anyone has used the ledger
   long enough to find that mistake.
2. **No phase boundary means no natural checkpoint to stop and ship.**
   If timeline or budget pressure hits midway, there is no longer a
   "Phase 1 is a complete, shippable product" fallback — that fallback
   only exists if you choose to treat the Build Order above as an
   informal checkpoint anyway, even though it's no longer a release
   boundary on paper.

