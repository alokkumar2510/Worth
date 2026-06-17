# Claude Instructions

Project: Worth

## Tech Stack

* Flutter
* Riverpod
* Drift (with SQLCipher encryption)
* Freezed
* GoRouter (StatefulShellRoute for bottom-nav tab state preservation)
* Material 3
* fl_chart
* uuid (for all primary key generation, client-side)
* local_auth (App Lock)

## Architecture

* Feature First
* Repository Pattern (CRUD + queries only — no business logic)
* Service Layer (all financial calculations live here)
* Offline First (no network dependency in Phases 1–5)
* Cross-cutting calculation logic lives in `core/calculation/`, not inside
  any single feature folder

## Rules

1. Transactions are immutable. Corrections happen via a `void` transaction,
   never an UPDATE.
2. Transactions are the source of truth.
3. No manual balance editing, anywhere — including the balance cache. Only
   the Service layer writes to cache tables, and only as a side effect of
   writing a transaction.
4. All calculations belong in services. Repositories never contain
   business logic.
5. UI never directly accesses the database — always through Riverpod
   providers backed by repositories/services.
6. Use Riverpod for state management. Prefer Drift's `Stream<List<T>>`
   watch queries exposed via `StreamProvider`/`AsyncNotifierProvider` for
   anything that must auto-update after a transaction write — do not
   manually invalidate providers as a substitute.
7. Use Drift for persistence, with SQLCipher encryption enabled on the
   database executor.
8. Follow Material 3.
9. Use clean and maintainable code.
10. Prefer composition over inheritance.
11. All primary keys are UUIDs (v4), generated client-side before insert.
    Never use autoincrementing integer keys.
12. Every transaction write and its corresponding balance-cache update
    happen inside a single Drift database transaction (atomic).
13. List queries must use keyset pagination, not OFFSET-based pagination,
    once a list could plausibly exceed a few hundred rows.
14. Every transaction type write is validated against the field-presence
    matrix in DATABASE_SCHEMA.md before being persisted (e.g. a `transfer`
    missing either `from_account_id` or `to_account_id` must be rejected
    before reaching the database).
15. Investment sales always resolve cost basis via FIFO against
    `investment_lots`, never average cost.

## Coding Standards

* Strong typing
* Null safety
* Feature-based folder structure
* Reusable widgets
* Responsive layouts

## Testing Standards

* No financial calculation (Net Worth, balance cache update, FIFO lot
  consumption, realized/unrealized gain) ships without a unit test
  asserting its output against a hand-verified expected value.
* The balance cache must have a "replay equivalence" test: for any
  transaction sequence, incrementally-updated cache values must equal a
  full replay from the empty state.
* Every Drift schema migration ships with a test applying it to
  representative seed data.

## Performance

* Dashboard load: < 300ms (reads balance cache only, never a full
  transactions table scan)
* Transaction save: < 100ms
* Search: < 500ms (FTS5-backed)
* Net Worth calculation: < 50ms (cache read, O(1) per entity)

## Source of Truth for Conflicts

If any implementation question isn't answered here, defer to, in order:
BUSINESS_RULES.md → DATABASE_SCHEMA.md → SYSTEM_DESIGN.md → PRD.md →
APP_FLOW.md → UI_UX.md → FEATURES_ROADMAP.md.

Generate production-grade code.
