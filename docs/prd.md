# Worth — Product Requirements Document

## Tagline

Know What You're Worth.

---

# Product Vision

Worth is a personal wealth operating system designed to help users track
their actual financial position.

Unlike traditional finance apps, Worth follows a conservative wealth model:

* Only confirmed assets contribute to Net Worth.
* Borrowed money contributes to Liabilities.
* Unrealized gains do not affect Net Worth.
* Expected income does not affect Net Worth.

The application focuses on clarity, accountability, and long-term wealth
tracking. Worth is explicitly not a budgeting app, expense tracker, banking
app, or trading platform.

---

# Platform

Android (V1). iOS and cross-platform sync are out of scope until a
dedicated platform expansion spec exists.

---

# Technology Stack

Frontend: Flutter, Material 3
State Management: Riverpod
Database: Drift (SQLite), encrypted via SQLCipher
Charts: fl_chart
Local Auth: optional biometric/PIN app lock
Export: Encrypted JSON Backup, CSV (reports only, not full backup)

Future (V2+, not V1): Supabase Sync

---

# Core Financial Model

```
Net Worth = Assets - Liabilities
```

Net Worth is always calculated, never stored. See BUSINESS_RULES.md
(canonical) and DATABASE_SCHEMA.md for full mechanics.

---

# Financial Definitions

## Assets

Resources currently owned by the user, or money owed to the user with
confirmed certainty (receivables).

Included: Cash, Bank Balances, Wallet Balances, Receivables, Invested
Capital, Gold Holdings.

Excluded: Unrealized Gains, Referral Rewards, Future Salary, Cashback
Rewards (until received).

## Liabilities

Money owed by the user. Includes family loans, personal loans, credit
dues, and any balance on a `credit`-type account.

> Credit accounts are liability-bearing, not cash-bearing. Spending on a
> credit account increases a liability; it is never treated as available
> cash. See BUSINESS_RULES.md.

## Invested Capital

The cost basis of currently-held investment units, calculated via FIFO
lot tracking (see DATABASE_SCHEMA.md — `investment_lots`).

Example:
Invested ₹20,000 in ETF, current Market Value ₹25,000.
Invested Capital = ₹20,000 (unaffected by market movement).

## Unrealized Gain/Loss

```
Market Value - Invested Capital
```

Does not contribute to Net Worth. Market Value is externally supplied
(manual entry in V1; price feed in a future version), not calculated from
transactions.

## Realized Gain/Loss

Calculated at the moment of sale via FIFO cost-basis matching against the
specific lot(s) consumed. Immediately affects Net Worth as the difference
between sale proceeds and cost basis. See BUSINESS_RULES.md for full
mechanics.

## Expected Income

Income expected but not yet realized: referrals, cashback, pending
rewards, pending payments. Excluded from Net Worth until the user marks it
"Received," which requires specifying a destination account and creates a
real `income` transaction.

---

# Currency

V1 supports a single currency, set during onboarding (default INR), stored
once in `settings`. Multi-currency support is out of scope until a
dedicated specification is written.

---

# Dashboard

## Summary Cards

* Net Worth
* Assets
* Liabilities
* Invested Capital
* Unrealized Gains
* Expected Income

## Charts

### Net Worth Trend
30D / 90D / 1Y / ALL. Short ranges (30D) query raw transactions; long
ranges (1Y/ALL) query the `snapshots` table for performance.

### Asset Allocation (Pie Chart)
Cash, Investments, Receivables, Gold

### Liability Distribution (Pie Chart)
Family Loans, Personal Loans, Credit Dues, Others

## Quick Insights

Example: "Net Worth increased by ₹12,500 this month."

---

# Accounts Module

Fields: Account Name, Type (cash/bank/wallet/credit/other), Notes, Created
Date. Balance is always calculated/displayed, never an editable field.

Accounts are archived, never deleted, once they have transaction history.

---

# Transactions Module

Every financial activity must be stored as an immutable transaction. No
manual balance editing, anywhere in the app.

## Transaction Types

```
income
expense
transfer                  -- requires both a source and destination account
borrow_money
repay_money
lend_money
recover_money
investment_buy
investment_sell
expected_income_received
interest_accrued
void                       -- the correction mechanism, see below
```

## Correcting a Mistake

Since transactions are immutable, the only correction mechanism is
**Void**: selecting a transaction and choosing "Void" creates a new
transaction with the inverse financial effect, linked to the original.
The original remains visible (marked "Voided") for audit purposes. See
BUSINESS_RULES.md for full rule.

## Transaction Fields

* Amount
* Date
* Type
* Category (for income/expense — required for reporting breakdowns)
* Notes
* From Account (where relevant)
* To Account (where relevant)
* Linked Person (where relevant)
* Linked Investment (where relevant)

---

# Receivables Module

Money owed TO the user.

Fields: Person, Amount, Notes, Created Date, Status (Outstanding / Partial
Recovery / Settled). Outstanding balance is always calculated:
`SUM(lend_money) − SUM(recover_money)` for that person.

# Liabilities Module

Money the user owes — to a person, or via a credit account.

Fields: Person or Credit Account, Amount, Notes, Borrowed Date, Status
(Active / Partially Paid / Closed). Outstanding balance is always
calculated: `SUM(borrow_money) − SUM(repay_money)`.

---

# Investments Module

Supported types: Stocks, Mutual Funds, ETFs, Gold ETFs, Crypto, Bonds, FDs.

Fields: Asset Name, Type, Market Value (manual entry, with last-updated
timestamp), Purchase transactions (each creates a FIFO lot).

Calculated (never stored directly on the investment):

* Invested Capital — sum of remaining cost basis across open lots
* Units Held — sum of remaining units across open lots
* Unrealized Gain/Loss — Market Value − Invested Capital
* Realized Gain/Loss (all-time) — sum across all lot consumptions

**Cost basis method: FIFO.** Average cost is not supported in V1. See
BUSINESS_RULES.md and DATABASE_SCHEMA.md for full mechanics.

Only Invested Capital contributes to Net Worth.

---

# Expected Income Module

Track: Referrals, Cashback, Rewards, Pending Income, Pending Recoveries.

Fields: Source, Amount, Expected Date, Notes. Status: Pending / Received /
Expired. Marking "Received" requires a destination account and
automatically creates a linked `income` transaction — this is the only
path by which expected income affects Net Worth.

---

# Monthly Snapshots

Generated lazily on first dashboard load detected within a new calendar
month (not a background job — see SYSTEM_DESIGN.md for rationale).
Backfilled retroactively for any month the app wasn't opened in.

Stores: Net Worth, Assets, Liabilities, Invested Capital, Expected Income.

Purpose: historical trend charts and reports without scanning the full
transaction log on every chart render.

---

# Reports Module

## Monthly Report

Opening Net Worth, Closing Net Worth, Growth %, New Investments, Debt
Recovered, New Borrowings, spending by category.

## Annual Report

Starting Net Worth, Ending Net Worth, Total Growth, Highest Asset
Category, Largest Liability.

---

# Goals Module (Re-scoped)

Goals are **passive net-worth milestone markers**, not a budgeting or
envelope system — this distinction matters because Worth's core
positioning is explicitly "not a budgeting app."

Examples: Emergency Fund target, Travel Fund target.

Fields: Goal Name, Target Amount, Deadline. Progress toward the target is
always calculated live from current Net Worth (or a specified account
balance), never tracked as an independently editable "current amount"
field.

---

# Notes

Every entity (Accounts, Liabilities, Investments, Receivables,
Transactions, Goals) supports an inline `notes` field directly on its own
table. There is no separate generic notes table — a polymorphic notes
table was considered and rejected because SQLite cannot enforce
referential integrity across mixed entity types.

---

# Definitions Center

Every financial term includes: Definition, Formula, Example, Included
Items, Excluded Items. Accessible through an ℹ icon next to every metric
in the app.

---

# Search

Global search across Accounts, People, Transactions, Investments, Goals.
Backed by SQLite FTS5 for performance at scale (not `LIKE` scans).

---

# Export & Backup

* **Backup:** full data export as JSON, encrypted with a user-supplied
  passphrase before being written to disk.
* **Restore:** import an encrypted JSON backup; the app always rebuilds
  all calculated balances via full transaction replay after restore — it
  never trusts a cached balance value from the backup file.
* **CSV Export:** for reports only (e.g. "export this month's
  transactions to CSV"), not a substitute for full backup/restore.

---

# Settings

Currency (set once at onboarding), Theme, App Lock (biometric/PIN),
Backup, Restore, Recalculate Balances (manual trigger for full replay),
Snapshot Frequency, Definition Preferences.

---

# Database Tables (Authoritative List — see DATABASE_SCHEMA.md)

```
accounts
people
investments
investment_lots
investment_lot_consumptions
transactions
expected_income
goals
snapshots
settings
audit_logs
account_balance_cache
person_balance_cache
investment_balance_cache
search_index (FTS5 virtual table)
```

---

# Out of Scope for V1

Documented explicitly to prevent silent scope creep during implementation:

* Multi-currency
* Multi-device sync / cloud backup (Supabase)
* Shared/family accounts
* OCR import
* General-purpose conversational AI assistant (a constrained, on-device
  natural-language query feature for personal data is in scope — see
  SYSTEM_DESIGN.md)
* Wealth forecasting
* Financial health scoring
* Average-cost investment accounting (FIFO only)
* Budgeting, spending limits, or envelope tracking

---

# Success Metric

Worth should answer these questions in less than 5 seconds:

1. What is my Net Worth today?
2. How much money do people owe me?
3. How much money do I owe?
4. How much have I invested?
5. What is my monthly growth?
6. What future income is expected?
7. Where is most of my wealth allocated?

These targets are achievable specifically because of the Balance Cache
architecture in SYSTEM_DESIGN.md — they are not achievable under naive
full-table aggregation as transaction volume grows.
