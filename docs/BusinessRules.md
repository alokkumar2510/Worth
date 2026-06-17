# Business Rules (Canonical Source of Truth)

This document wins all conflicts with any other spec. If another document
disagrees with this one, this one is correct and the other must be updated.

---

## Core Formula

```
Net Worth = Assets - Liabilities
```

Net Worth is **never stored**. It is always calculated from transactions
(via the Balance Cache — see DATABASE_SCHEMA.md).

---

## Assets Include

* Cash held physically
* Bank account balances
* Wallet balances (non-credit)
* Receivables (money owed TO the user)
* Invested Capital (original amount put into investments, not market value)

## Assets Exclude

* Unrealized Gains (market value above invested capital)
* Expected Income (anything not yet received)
* Future Salary
* Cashback Rewards (until actually received, at which point they become Income)

## Liabilities Include

* Family loans (money borrowed from a person)
* Personal borrowings
* Credit account balances (money spent on credit, not yet repaid)
* Credit dues

> **Rule:** A `credit` type account never holds a positive cash balance.
> Spending on a credit account increases a liability. It is never treated
> as available cash. See "Credit Accounts" below.

---

## Currency

* V1 supports a single currency, defined at setup (default INR).
* Every amount in the database is stored in this single currency.
* The currency code is stored once in `settings`, not per-transaction.
* Multi-currency is explicitly out of scope until a dedicated
  Multi-Currency Specification is written and approved. Do not build
  partial multi-currency support speculatively.

---

## Accounts

### Account Types

```
cash
bank
wallet
credit
other
```

### Credit Accounts (Special Rule)

A `credit` account behaves opposite to other account types:

* Spending FROM a credit account increases the linked liability balance.
* Repaying a credit account decreases the linked liability balance.
* A credit account's balance is never added to Cash Holdings.
* A credit account's balance is always added to Liabilities.

Internally, every `credit` account automatically has a corresponding
liability ledger. The user sees one "account," but the system tracks it
as a liability-bearing container, not a cash container.

---

## Transactions

* Transactions are immutable once saved. They are never edited or hard-deleted.
* Transactions are the only source of truth for all financial state.
* All balances (account, receivable, liability, investment) are calculated
  from transactions. They are never manually edited.
* Corrections happen via a **Void** action (see "Correcting Mistakes" below),
  never by editing the original transaction.

### Correcting Mistakes

Because transactions are immutable, mistakes are corrected with a
**Void Transaction**:

1. The user selects a transaction and chooses "Void."
2. The system creates a new transaction with type `void`, referencing the
   original transaction's id, with the inverse financial effect.
3. The original transaction remains in the database, untouched, for audit
   purposes, but is visually marked "Voided" in the UI and excluded from
   balance calculations.
4. A voided transaction cannot itself be voided. To "undo a void," the user
   re-enters a fresh transaction.

This preserves immutability and auditability while giving users a real-world
way to fix typos.

### Transfers

A transfer moves money between two of the user's own accounts. It is
net-worth-neutral. A transfer always has both a source account and a
destination account (see DATABASE_SCHEMA.md — `from_account_id` and
`to_account_id`). A transfer with only one account specified is invalid
and must be rejected at the validation layer.

---

## Investment Rules

* Only **Invested Capital** contributes to Net Worth.
* **Market Value** is tracked separately and never contributes to Net Worth.
* **Unrealized Gain/Loss** (Market Value − Invested Capital) does not affect
  Net Worth.
* **Realized Gain/Loss** affects Net Worth immediately upon sale, as cash
  income (or loss) landing in a specified account.
* Market Value is externally supplied data (manual entry or future price
  feed), not derived from transactions. It is the one explicitly documented
  exception to "balances are always calculated."

### Cost Basis Method

* Worth uses **FIFO (First-In, First-Out)** for calculating invested capital
  reduction and realized gain/loss on partial sales.
* Each `investment_buy` transaction creates one **lot** with its own
  purchase date, units, and cost.
* Each `investment_sell` transaction consumes the oldest open lot(s) first.
* If a sell quantity spans multiple lots, the realized gain/loss is the
  sum of (sale proceeds allocated to that lot − that lot's cost basis)
  across all consumed lots.
* Average-cost-method is not supported in V1. Do not implement it
  speculatively.

### Investment Sale Mechanics (Resolved)

When a user sells part or all of an investment:

1. The system determines, via FIFO, which lot(s) are being closed and their
   total cost basis for the units sold.
2. `invested_capital` decreases by the cost basis of the units sold (not the
   sale proceeds).
3. The difference between sale proceeds and cost basis is the **realized
   gain or loss**, recorded as its own line item within the same
   `investment_sell` transaction.
4. Sale proceeds (full amount received) are credited to the `to_account_id`
   specified on the transaction — this is real cash entering an account.
5. Net Worth increases by exactly the realized gain (or decreases by the
   realized loss), because invested capital fell by the cost basis while
   cash rose by the full proceeds.

---

## Receivable Rules

* Money owed TO the user (by a person) counts as an Asset.
* Created by a `lend_money` transaction.
* Partial recovery (`recover_money`) reduces the outstanding balance.
* Full recovery closes the receivable (outstanding balance reaches zero).
* A receivable's outstanding balance is always calculated as:
  `SUM(lend_money) - SUM(recover_money)` for that person, grouped by the
  originating receivable.
* Interest on a receivable, if applicable, is recorded as a distinct
  `interest_accrued` transaction type, never blended into principal.

## Liability Rules

* Money owed BY the user counts as a Liability.
* Created by a `borrow_money` transaction.
* Repayment (`repay_money`) reduces the outstanding balance.
* Full repayment closes the liability.
* A liability's outstanding balance is always calculated as:
  `SUM(borrow_money) - SUM(repay_money)` for that person/credit account.
* Interest owed, if applicable, is recorded as a distinct
  `interest_accrued` transaction type, never blended into principal.

## Expected Income Rules

* Categories: Referrals, Cashback, Pending Rewards, Pending Payments.
* Tracked in the `expected_income` table with status `pending`, `received`,
  or `expired`.
* Never included in Net Worth while status is `pending` or `expired`.
* When marked `received`, the system requires the user to specify a
  destination account, and automatically creates a corresponding `income`
  transaction. The expected income record is then linked to that
  transaction and its status becomes `received`. This is the only way
  expected income affects Net Worth.

---

## Source of Truth

Transactions are the only source of truth for financial history.

Balances, receivable/liability outstanding amounts, invested capital, and
Net Worth are always calculated, never manually edited.

The **Balance Cache** (see DATABASE_SCHEMA.md) is a performance
optimization only. It is fully rebuildable from the transaction log at any
time and is never treated as authoritative on its own.

---

## Out of Scope for V1 (Explicitly)

To prevent scope ambiguity, the following are explicitly NOT part of V1
business rules and must not be partially implemented:

* Multi-currency conversion
* Budgeting or spending limits (categorization for reporting is fine;
  enforcement/alerts are not)
* Average-cost investment accounting
* Multi-user / shared household ledgers
* Any feature requiring a network connection to function
