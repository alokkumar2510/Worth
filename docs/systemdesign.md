# Worth - System Design

## Architecture Overview

Worth follows an Offline-First Architecture.

```text
UI Layer
    ↓
State Layer (Riverpod)
    ↓
Service Layer
    ↓
Repository Layer
    ↓
Drift Database (SQLite, encrypted via SQLCipher)
```

All data is stored locally. Internet is not required for V1.

---

# High-Level Architecture

```text
┌────────────────────┐
│      Flutter UI    │
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Riverpod Providers  │  (AsyncNotifier + Drift Stream Queries)
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│     Services        │  (NetWorthService, InvestmentService, etc.)
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│   Repositories      │  (DAOs — CRUD + queries, no business logic)
└─────────┬──────────┘
          │
          ▼
┌────────────────────┐
│ Drift + SQLite       │  (SQLCipher-encrypted)
│ + Balance Cache      │
└────────────────────┘
```

---

# Core Design Principle

Transactions are the source of truth.

Never manually edit:

* Net Worth
* Account Balances
* Receivables
* Liabilities
* Invested Capital

Everything must be derived from transaction history. The Balance Cache
(below) is a performance optimization, not an exception to this rule — it
is fully rebuildable from transactions at any time.

---

# Example

Wrong:

```text
Sohan Balance = ₹17,700
```

Correct:

```text
01 Jan  Loaned Sohan ₹20,000

15 Jan  Received ₹2,300

Current Balance

=
20,000 - 2,300

=
17,700
```

This is still true in this design. The difference from a naive
implementation is *how* "Current Balance" gets to the screen fast at scale
— see "Balance Calculation Strategy" below.

---

# Balance Calculation Strategy (Critical — Resolves Performance Risk)

**Problem:** if every dashboard load sums the entire `transactions` table,
performance degrades linearly as transaction count grows. At 50,000+ rows
this will miss the <300ms dashboard target.

**Solution — incremental materialized cache, not live aggregation:**

1. Every transaction write happens inside a single Drift database
   transaction that does two things atomically:
   - Inserts the immutable transaction row.
   - Updates the relevant row(s) in `account_balance_cache`,
     `person_balance_cache`, and/or `investment_balance_cache` by applying
     just the delta from this one transaction (not a full re-sum).
2. Dashboard reads, account detail reads, and Net Worth calculation read
   *only* from the cache tables — O(1) per account/person/investment,
   never a full table scan.
3. The cache is provably correct because it's derived transactionally
   alongside the immutable log, and is fully rebuildable: a
   "Recalculate Balances" action in Settings replays the entire
   transaction log in `transaction_date` order and rewrites the cache
   from scratch. This is the recovery path after a Restore, after a bug
   fix, or if a user ever doubts the numbers.
4. An automated test suite includes a "replay equivalence" test: generate
   random transaction sequences, compute balances both via incremental
   cache updates and via full replay, and assert they always match.

This is what makes "Net Worth Calculation: <50ms" achievable at any data
volume, not just at launch with an empty database.

---

# Project Structure

```text
lib/

├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   ├── calculation/        # cross-cutting calculation services
│   │   ├── net_worth_service.dart
│   │   ├── balance_cache_service.dart
│   │   └── fifo_lot_service.dart
│   └── services/
│       ├── backup_service.dart
│       ├── encryption_service.dart
│       └── search_index_service.dart
│
├── features/
│
│   ├── dashboard/
│   ├── accounts/
│   ├── investments/
│   ├── receivables/
│   ├── liabilities/
│   ├── transactions/
│   ├── reports/
│   ├── goals/
│   ├── settings/
│   ├── search/
│   └── definitions/
│
├── database/
│   ├── tables/
│   ├── dao/
│   └── database.dart       # Drift database, SQLCipher key management
│
└── main.dart
```

**Rule:** cross-cutting calculation logic (Net Worth, balance cache
maintenance, FIFO lot consumption) lives in `core/calculation/`, never
inside a single feature folder. These are consumed by multiple features
(Dashboard, Reports, Investments all need Net Worth/balance data) and
placing them in one feature creates circular feature dependencies.

---

# Database Design

## Important Rules

1. Only create tables for actual entities or for the documented Balance
   Cache. Do not create tables for other calculated values.
2. All primary keys are UUIDs (see DATABASE_SCHEMA.md). This is required
   for future multi-device sync and must not be deferred.
3. The database file is encrypted at rest via SQLCipher (Drift supports
   this directly). See SECURITY section below.

For full table definitions, see **DATABASE_SCHEMA.md** — this document
defers entirely to it as the canonical schema source.

---

# Repository Layer

Purpose: database abstraction. No business logic.

```text
AccountRepository
TransactionRepository
InvestmentRepository
InvestmentLotRepository
PersonRepository
GoalRepository
ExpectedIncomeRepository
SnapshotRepository
```

Responsibilities:

* CRUD against Drift tables
* Filtering and pagination (every list-returning query must support
  `limit`/`offset` or keyset pagination — required at scale, see
  Performance section)
* Exposing Drift's reactive `Stream<List<T>>` watch queries for
  dashboard-facing data, so the UI updates automatically without manual
  cache invalidation

Repositories do not know about Net Worth, FIFO, or balance caching. That
logic belongs entirely in the Service layer.

---

# Service Layer

Contains all financial calculations and is the only layer permitted to
write to balance cache tables.

```text
NetWorthService        -- reads balance cache, computes Assets/Liabilities/Net Worth
TransactionService      -- validates + writes transactions, updates balance cache atomically
InvestmentService        -- FIFO lot consumption, realized/unrealized gain calculation
SnapshotService          -- generates monthly snapshots lazily
ReportService            -- monthly/annual report aggregation
BalanceRecalculationService -- full replay rebuild, used after restore or on-demand
SearchService             -- queries the FTS5 index
```

Responsibilities:

* Validate transaction shape against the type-field matrix in
  DATABASE_SCHEMA.md before writing (e.g. reject a `transfer` missing
  either `from_account_id` or `to_account_id`)
* Calculate balances, real-time, from cache
* Generate reports and chart data (using snapshots for long ranges, raw
  transactions only for short ranges — see Performance)
* Maintain the balance cache transactionally on every write
* Generate monthly snapshots

---

# State Management

Riverpod.

**Rule:** any provider backed by data that should auto-update when a
transaction is written (dashboard totals, account lists, transaction feed)
must be built on Drift's `Stream<List<T>>` watch queries, exposed via
`StreamProvider` or `AsyncNotifierProvider.watch`. Do not manually
invalidate providers after a write — let Drift's stream emit the change.
This is what actually delivers "Net Worth Updates Automatically" from
APP_FLOW.md, and the original design omitted this mechanism entirely.

```text
netWorthProvider           -- AsyncNotifierProvider, watches balance cache stream
assetsProvider
liabilitiesProvider
investmentProvider
transactionFeedProvider     -- paginated stream
searchResultsProvider       -- debounced, backed by FTS5 query
```

---

# Dashboard Data Flow

```text
User Opens Dashboard
        ↓
netWorthProvider (Stream, already live from balance cache)
        ↓
NetWorthService.currentNetWorth()
        ↓
Reads account_balance_cache + person_balance_cache + investment_balance_cache
        ↓
(NOT a full transactions table scan)
```

---

# Monthly Snapshot Flow

Trigger: lazily, on first dashboard load detected within a new calendar
month. Not a scheduled background job (Android background execution is
unreliable and must not be load-bearing for financial data integrity).
If the app wasn't opened during a given month, that month's snapshot is
backfilled retroactively the next time the app opens, computed from
transaction history as of the last day of that month.

```text
Detect new month since last snapshot
        ↓
Calculate Assets, Liabilities, Net Worth, Invested Capital, Expected Income
        ↓
Store Snapshot row
```

Used for: trend charts at 90D/1Y/ALL ranges, monthly/annual reports.

---

# Backup System

Export contents:

```text
accounts
people
investments
investment_lots
investment_lot_consumptions
transactions
goals
expected_income
settings (excluding device-specific keys)
```

Format: JSON, **encrypted with a user-supplied passphrase** before being
written to disk (see Security section — plaintext financial backups are
a real data-leak risk once the file leaves the device via email, cloud
drive, etc.).

---

# Restore Flow

```text
Import encrypted JSON
        ↓
Decrypt with user-supplied passphrase
        ↓
Validate schema version + structure
        ↓
Replace local database
        ↓
BalanceRecalculationService: full replay rebuild of all cache tables
        ↓
Rebuild FTS5 search index
```

Restoring never trusts an imported balance cache (if present in older
backup formats) — it always rebuilds via full replay to guarantee
correctness against transaction history.

---

# Search System

Global Search backed by SQLite FTS5 (not `LIKE` scans — required for
acceptable performance past a few thousand records).

```text
Sources indexed:
  Accounts (name, notes)
  People (name, notes)
  Transactions (notes)
  Investments (name, symbol, notes)
  Goals (name, notes)
```

Index updated synchronously whenever a relevant row is inserted/updated.

---

# Future Cloud Sync (V2 — Not V1)

```text
Flutter
   ↓
Repository
   ↓
SQLite (UUID-keyed, ready for sync)
   ↓
Sync Engine
   ↓
Supabase
```

Offline remains primary. Cloud acts as backup and multi-device source of
truth merge point.

### Conflict Resolution Policy (Must Be Decided Before V2 Build Starts)

* **Transactions:** append-only by nature — conflicts are rare (two
  devices each create new transactions, both get merged, no real
  conflict). Sync strategy: union of transaction logs by UUID, idempotent
  on duplicate UUID.
* **Mutable fields** (e.g. `investments.market_value`,
  `expected_income.status`, `accounts.is_archived`): last-write-wins by
  `updated_at` timestamp, with the losing device shown a "this was
  updated elsewhere" notice rather than silently discarding data.
* **Balance cache tables:** never synced directly — always rebuilt
  locally via full replay after a sync merge, on every device.

This section exists so that V2 sync work has an agreed starting policy
instead of being designed ad hoc mid-implementation.

---

# Future AI Assistant (Re-scoped — see FEATURES_ROADMAP.md)

V1 ships a **constrained natural-language query feature**, not a general
AI assistant:

```text
User Question (constrained to personal-data queries)
        ↓
On-device Intent Classifier (which entity + which calculation)
        ↓
Templated Query Builder (maps intent → known-safe SQL against
repositories — no free-form SQL generation)
        ↓
Result
```

Example:

"How much does Sohan owe me?"
→ classified as: `receivable_balance` intent, person="Sohan"
→ calls `PersonRepository.receivableBalance(personId)`
→ returns calculated value

This requires no LLM API call and no internet connection, and is
realistic to ship. A general-purpose conversational assistant ("what
should I invest in") is a different product, requires an LLM API, and is
explicitly out of scope until a dedicated AI Assistant specification is
written — see FEATURES_ROADMAP.md.

---

# Performance Goals

```
Dashboard Load:            < 300ms   (reads balance cache only, not transactions table)
Transaction Save:          < 100ms   (single Drift transaction: insert + cache update)
Search:                    < 500ms   (FTS5-backed)
Net Worth Calculation:     < 50ms    (cache read, O(1) per entity)
Transaction Feed Scroll:   60fps     (paginated, keyset pagination, not OFFSET-based)
```

These targets are achievable specifically because of the Balance Cache
strategy above. They are not achievable under naive full-table-scan
aggregation past roughly 5,000–10,000 transactions.

---

# Security

* SQLite database file is encrypted at rest using SQLCipher via Drift's
  encrypted executor.
* JSON backups are encrypted with a user-supplied passphrase before
  being written to disk or shared.
* App supports an optional biometric/PIN lock on launch (device-level
  `local_auth`), recommended given the app displays loan amounts and
  net worth that may involve family members' financial information.
* No financial data is transmitted anywhere in V1 (fully offline) — there
  is no network attack surface to defend in V1 beyond the on-device file
  itself.

---

# Testing Strategy

* **Service layer:** unit tests for every calculation — Net Worth, FIFO
  lot consumption, receivable/liability balances, realized/unrealized
  gain. Tests use known transaction sequences with hand-verified expected
  outputs.
* **Balance cache:** property-based "replay equivalence" tests — for
  randomly generated transaction sequences, incremental cache results
  must always equal full-replay results.
* **Repository layer:** integration tests against an in-memory Drift
  database.
* **Migration tests:** every schema migration ships with a test that
  applies it to representative seed data and asserts no data loss.
* No financial calculation ships without a corresponding test. This is
  non-negotiable for an app whose entire purpose is showing the user a
  correct number.

---

# Engineering Rules

1. Transactions are immutable. Corrections happen via `void`, never edit.
2. No manual balance editing, anywhere, including in the balance cache —
   only the Service layer writes to cache tables, and only as a side
   effect of writing a transaction.
3. All balances are derived from transactions; the cache is an
   optimization, not an exception.
4. Net Worth is calculated, never stored as standalone state.
5. Snapshots are for historical reporting only — never read for "current"
   balances.
6. Business logic belongs in services. Repositories contain no business
   logic.
7. UI never directly queries SQLite — always through Riverpod providers
   backed by repositories/services.
8. Repository layer is mandatory for all database access.
9. Every financial term must have a Definitions Center entry.
10. Offline mode must always work; V1 has no network dependency.
11. All primary keys are UUIDs.
12. Every calculation in the Service layer has an automated test before
    it is considered done.
13. List queries must be paginated (keyset, not OFFSET) once data volume
    can plausibly exceed one screen.
