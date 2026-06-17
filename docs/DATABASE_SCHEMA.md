# DATABASE_SCHEMA.md

## Database Philosophy

Transactions are the source of truth.

The following are **derived** and must always be reproducible by replaying
the transaction log from scratch:

* Net Worth
* Account balances
* Receivable balances
* Liability balances
* Invested Capital
* Realized/Unrealized Gain or Loss

The **only exception** is the Balance Cache (see below), which exists
purely for performance and is fully rebuildable at any time.

---

## Primary Key Strategy

**All tables use TEXT UUIDs (v4) as primary keys, not autoincrementing
integers.**

Rationale: this app is designed for future multi-device sync. Autoincrement
integer keys collide the instant two offline devices each create a record
and later try to merge. Migrating integer keys to UUIDs after users have
real production data is expensive and risky. UUIDs cost nothing extra now.

```sql
id TEXT PRIMARY KEY  -- UUID v4, generated client-side at creation time
```

All foreign keys below reference these UUID columns.

---

# Tables

## accounts

Stores money containers.

```sql
CREATE TABLE accounts (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  type          TEXT NOT NULL,        -- cash | bank | wallet | credit | other
  notes         TEXT,
  is_archived   INTEGER NOT NULL DEFAULT 0,
  created_at    DATETIME NOT NULL,
  updated_at    DATETIME NOT NULL
);
```

### Account Types

```
cash
bank
wallet
credit      -- special handling, see BUSINESS_RULES.md
other
```

Accounts are never hard-deleted (would orphan transaction history). Use
`is_archived` to hide from active lists while preserving history.

---

## people

Stores individuals related to receivables or liabilities.

```sql
CREATE TABLE people (
  id            TEXT PRIMARY KEY,
  name          TEXT NOT NULL,
  phone         TEXT,
  notes         TEXT,
  is_archived   INTEGER NOT NULL DEFAULT 0,
  created_at    DATETIME NOT NULL,
  updated_at    DATETIME NOT NULL
);
```

---

## investments

Stores investment instruments (the instrument itself, not individual
purchase lots).

```sql
CREATE TABLE investments (
  id                TEXT PRIMARY KEY,
  name              TEXT NOT NULL,
  type              TEXT NOT NULL,   -- stock | mutual_fund | etf | gold | crypto | bond | fd | other
  symbol            TEXT,
  market_value      REAL,            -- externally supplied; NOT derived from transactions
  market_value_updated_at DATETIME,
  is_archived       INTEGER NOT NULL DEFAULT 0,
  notes             TEXT,
  created_at        DATETIME NOT NULL,
  updated_at        DATETIME NOT NULL
);
```

> **Important deviation from "never store calculated values":** `market_value`
> is the one deliberate, documented exception. It is external market data
> (manual entry or future price feed), not derivable from this app's own
> transactions. `units` and `invested_capital` are NOT stored here — they
> are calculated from `investment_lots` (below). Storing them here would
> violate the core philosophy and would drift out of sync with reality.

---

## investment_lots

Tracks individual purchase lots for FIFO cost-basis accounting. One row
created per `investment_buy` transaction. Consumed (partially or fully) by
`investment_sell` transactions.

```sql
CREATE TABLE investment_lots (
  id                  TEXT PRIMARY KEY,
  investment_id       TEXT NOT NULL REFERENCES investments(id),
  buy_transaction_id  TEXT NOT NULL REFERENCES transactions(id),
  units_purchased     REAL NOT NULL,
  units_remaining      REAL NOT NULL,   -- decremented as units are sold via FIFO
  cost_per_unit       REAL NOT NULL,
  purchase_date       DATETIME NOT NULL,
  created_at          DATETIME NOT NULL,
  updated_at          DATETIME NOT NULL
);
```

`units_remaining` is the one mutable field in this table, updated whenever
a sale consumes units from this lot. This is still fully derivable by
replaying transactions in order — it is a cache field, not new authoritative
state.

---

## investment_lot_consumptions

Records exactly which lots were consumed by which sale, and the realized
gain/loss attributed to each. Required for audit and for correct realized
gain/loss reporting.

```sql
CREATE TABLE investment_lot_consumptions (
  id                    TEXT PRIMARY KEY,
  sell_transaction_id   TEXT NOT NULL REFERENCES transactions(id),
  lot_id                TEXT NOT NULL REFERENCES investment_lots(id),
  units_consumed        REAL NOT NULL,
  cost_basis            REAL NOT NULL,   -- units_consumed * lot.cost_per_unit
  proceeds_allocated    REAL NOT NULL,   -- portion of sale proceeds attributed to this lot
  realized_gain_loss    REAL NOT NULL,   -- proceeds_allocated - cost_basis
  created_at            DATETIME NOT NULL
);
```

---

## expected_income

Stores future income opportunities.

```sql
CREATE TABLE expected_income (
  id              TEXT PRIMARY KEY,
  source          TEXT NOT NULL,
  amount          REAL NOT NULL,
  status          TEXT NOT NULL,        -- pending | received | expired
  expected_date   DATETIME,
  received_transaction_id TEXT REFERENCES transactions(id),  -- set when status -> received
  notes           TEXT,
  created_at      DATETIME NOT NULL,
  updated_at      DATETIME NOT NULL
);
```

---

## goals

Passive net-worth milestone markers only. Not a budgeting/envelope system.

```sql
CREATE TABLE goals (
  id              TEXT PRIMARY KEY,
  name            TEXT NOT NULL,
  target_amount   REAL NOT NULL,
  deadline        DATETIME,
  notes           TEXT,
  is_archived     INTEGER NOT NULL DEFAULT 0,
  created_at      DATETIME NOT NULL,
  updated_at      DATETIME NOT NULL
);
```

`current_amount` is intentionally NOT stored — a goal's progress is always
calculated live from current Net Worth (or a specific account/category, per
goal configuration), never tracked as an independently mutable field.

---

# Core Table

## transactions

Every financial event is stored here. Immutable once written.

```sql
CREATE TABLE transactions (
  id                  TEXT PRIMARY KEY,
  type                TEXT NOT NULL,
  amount              REAL NOT NULL,
  category             TEXT,              -- for income/expense reporting breakdowns
  from_account_id     TEXT REFERENCES accounts(id),
  to_account_id       TEXT REFERENCES accounts(id),
  person_id           TEXT REFERENCES people(id),
  investment_id       TEXT REFERENCES investments(id),
  voided_transaction_id TEXT REFERENCES transactions(id), -- set when type = 'void'
  notes               TEXT,
  transaction_date    DATETIME NOT NULL,
  created_at          DATETIME NOT NULL,
  updated_at          DATETIME NOT NULL
);
```

### Why `from_account_id` AND `to_account_id` (not a single `account_id`)

A single `account_id` cannot represent a transfer between two of the
user's own accounts, and cannot cleanly represent cash leaving an account
to buy an investment. Each transaction type uses only the fields relevant
to it:

| type                      | from_account_id | to_account_id | person_id | investment_id |
|---------------------------|:---:|:---:|:---:|:---:|
| income                    |     |  ✓  |     |     |
| expense                   |  ✓  |     |     |     |
| transfer                  |  ✓  |  ✓  |     |     |
| borrow_money              |     |  ✓  |  ✓  |     |
| repay_money               |  ✓  |     |  ✓  |     |
| lend_money                |  ✓  |     |  ✓  |     |
| recover_money             |     |  ✓  |  ✓  |     |
| investment_buy            |  ✓  |     |     |  ✓  |
| investment_sell           |     |  ✓  |     |  ✓  |
| expected_income_received  |     |  ✓  |     |     |
| interest_accrued          |     |     |  ✓  |     |
| void                      | (mirrors voided transaction, inverted) | | | |

A transaction with neither `from_account_id` nor `to_account_id` populated
where one is required must be rejected at the service layer before it
reaches the database.

---

# Transaction Types (Complete List)

```
income                      -- money entering the system
expense                      -- money leaving the system
transfer                     -- money moved between two of the user's own accounts
borrow_money                 -- creates/increases a liability
repay_money                  -- reduces a liability
lend_money                   -- creates/increases a receivable
recover_money                -- reduces a receivable
investment_buy                -- creates a lot, increases invested capital
investment_sell               -- consumes lot(s) via FIFO, realizes gain/loss
expected_income_received      -- converts an expected_income record into real income
interest_accrued              -- interest owed/earned on a receivable or liability
void                          -- reverses a prior transaction's financial effect
```

---

# Balance Cache (Performance Layer)

This is the **only** stored, mutable aggregate in the entire schema. It is
not authoritative — it is fully rebuildable from `transactions` at any time
(e.g. on restore, or via a manual "Recalculate" action in Settings).

```sql
CREATE TABLE account_balance_cache (
  account_id      TEXT PRIMARY KEY REFERENCES accounts(id),
  cash_balance    REAL NOT NULL DEFAULT 0,   -- meaningless for credit accounts
  liability_balance REAL NOT NULL DEFAULT 0, -- only nonzero for credit accounts
  last_transaction_id TEXT REFERENCES transactions(id),
  updated_at      DATETIME NOT NULL
);

CREATE TABLE person_balance_cache (
  person_id          TEXT PRIMARY KEY REFERENCES people(id),
  receivable_balance REAL NOT NULL DEFAULT 0,  -- they owe the user
  liability_balance  REAL NOT NULL DEFAULT 0,  -- the user owes them
  last_transaction_id TEXT REFERENCES transactions(id),
  updated_at         DATETIME NOT NULL
);

CREATE TABLE investment_balance_cache (
  investment_id       TEXT PRIMARY KEY REFERENCES investments(id),
  invested_capital    REAL NOT NULL DEFAULT 0,
  units_held          REAL NOT NULL DEFAULT 0,
  last_transaction_id TEXT REFERENCES transactions(id),
  updated_at          DATETIME NOT NULL
);
```

**Update rule:** every transaction write happens inside a single DB
transaction (Drift `transaction()` block) that also updates the relevant
cache row(s). The cache is never the source of truth and must be fully
reconstructible by replaying `transactions` in `transaction_date` order
from empty.

---

# Historical Snapshots

## snapshots

Stores periodic financial state for historical charting and reports.

```sql
CREATE TABLE snapshots (
  id                TEXT PRIMARY KEY,
  snapshot_date     DATETIME NOT NULL,
  net_worth         REAL NOT NULL,
  assets            REAL NOT NULL,
  liabilities       REAL NOT NULL,
  invested_capital  REAL NOT NULL,
  expected_income   REAL NOT NULL,
  created_at        DATETIME NOT NULL
);
```

**Generation trigger:** lazily generated on first dashboard load detected
in a new calendar month (not a background scheduled job — Android
background execution is unreliable and should not be depended upon for
data integrity). If the app is not opened in a given month, that month's
snapshot is backfilled retroactively from transaction history the next
time the app opens.

---

# Audit Log

```sql
CREATE TABLE audit_logs (
  id              TEXT PRIMARY KEY,
  entity_type     TEXT NOT NULL,    -- transaction | account | investment | person | goal
  entity_id       TEXT NOT NULL,
  action          TEXT NOT NULL,    -- created | voided | restored | archived
  details_json    TEXT,             -- snapshot of relevant fields at time of action
  created_at      DATETIME NOT NULL
);
```

Every void, archive, or restore action writes an audit log row. This is
what makes "immutable + voidable" trustworthy and inspectable.

---

# Settings

```sql
CREATE TABLE settings (
  key   TEXT PRIMARY KEY,
  value TEXT
);
```

Required keys:

```
theme
currency_code        -- e.g. "INR" — single currency for all V1 data
snapshot_frequency
last_balance_recalculation_at
```

---

# Full-Text Search

```sql
CREATE VIRTUAL TABLE search_index USING fts5(
  entity_type,     -- account | person | investment | transaction | goal
  entity_id,
  searchable_text
);
```

Populated/updated whenever a name, note, or transaction note changes.
Backs the Global Search feature (Section: Search Flow in APP_FLOW.md)
without falling back to slow `LIKE '%...%'` scans as data grows.

---

# Relationships

```
Account
│
├── transactions.from_account_id
├── transactions.to_account_id
└── account_balance_cache (1:1)

Person
│
├── lend_money / recover_money  → person_balance_cache.receivable_balance
├── borrow_money / repay_money  → person_balance_cache.liability_balance
└── person_balance_cache (1:1)

Investment
│
├── investment_buy  → investment_lots (1:many)
├── investment_sell → investment_lot_consumptions (1:many)
└── investment_balance_cache (1:1)
```

---

# Derived Calculations (Definitions)

## Cash Holdings (per account, non-credit types)

```
SUM(amount WHERE to_account_id = account.id)
-
SUM(amount WHERE from_account_id = account.id)
```
across types: income, expense, transfer, investment_buy, investment_sell,
expected_income_received. Excludes any transaction with type = `void`'s
target, and the `void` transaction itself carries the inverse sign.

## Credit Account Liability Balance

```
SUM(expense/investment_buy WHERE from_account_id = credit_account.id)
-
SUM(repay_money WHERE to "this credit account")
```

## Receivables (per person)

```
SUM(lend_money) - SUM(recover_money)
```
grouped by person_id.

## Liabilities (per person or credit account)

```
SUM(borrow_money) - SUM(repay_money)     -- per person
SUM(credit account liability balance)     -- per credit account
```

## Invested Capital (per investment)

```
SUM(investment_lots.units_remaining * investment_lots.cost_per_unit)
```
for all open lots belonging to that investment. This is mathematically
equivalent to SUM(investment_buy cost) − SUM(cost basis of all sells), but
is calculated via lots to support FIFO correctly.

## Realized Gain/Loss (per investment, all-time)

```
SUM(investment_lot_consumptions.realized_gain_loss)
```

## Unrealized Gain/Loss (per investment, point-in-time)

```
market_value - invested_capital
```

## Assets

```
SUM(non-credit account cash balances)
+
SUM(person receivable balances)
+
SUM(invested capital across all investments)
```

## Liabilities

```
SUM(person liability balances)
+
SUM(credit account liability balances)
```

## Net Worth

```
Assets - Liabilities
```

---

# Required Indexes

```sql
CREATE INDEX idx_tx_date            ON transactions(transaction_date);
CREATE INDEX idx_tx_type            ON transactions(type);
CREATE INDEX idx_tx_from_account    ON transactions(from_account_id, transaction_date);
CREATE INDEX idx_tx_to_account      ON transactions(to_account_id, transaction_date);
CREATE INDEX idx_tx_person          ON transactions(person_id, transaction_date);
CREATE INDEX idx_tx_investment      ON transactions(investment_id, transaction_date);

CREATE INDEX idx_people_name        ON people(name);
CREATE INDEX idx_accounts_name      ON accounts(name);
CREATE INDEX idx_investments_type   ON investments(type);

CREATE INDEX idx_expected_income_status ON expected_income(status);
CREATE INDEX idx_snapshots_date         ON snapshots(snapshot_date);

CREATE INDEX idx_lots_investment    ON investment_lots(investment_id, purchase_date);
CREATE INDEX idx_lot_consumptions_sell ON investment_lot_consumptions(sell_transaction_id);
```

---

# Engineering Rules

1. Transactions are immutable. Corrections happen via `void`, never via UPDATE.
2. Never write to balance/net-worth fields directly from UI or repository code — only the calculation service may write to the balance cache, and only as a side effect of writing a transaction.
3. Net Worth is calculated, never stored as standalone state.
4. Receivables and Liabilities are calculated, with cache acceleration.
5. Every financial event is a transaction — no exceptions.
6. Snapshots are for historical reporting only; never used for "current" balance reads.
7. The database must support complete offline operation.
8. All primary keys are UUIDs, generated client-side before insert.
9. The balance cache must be rebuildable from `transactions` alone, verified by an automated test that compares cache output to a full replay.
10. Every schema migration must include a forward migration script and a corresponding test using representative seed data.
