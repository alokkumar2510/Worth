# Worth - Application Flow

## Philosophy

Worth is not an expense tracker. Worth is not a budgeting application.

Worth is a personal wealth operating system designed to answer one question:

> What am I worth today?

The entire application flow revolves around this question.

---

# User Journey

```text
Open App
    ↓
View Net Worth
    ↓
Understand Changes
    ↓
Explore Assets / Liabilities
    ↓
Review Transactions
    ↓
Add New Financial Event
    ↓
Net Worth Updates Automatically
```

---

# First Launch Flow

## Splash Screen

```text
Worth
Know What You're Worth.
```
Duration: 2 seconds

---

## Welcome Screen

### Headline
Welcome to Worth

### Description
Track your assets, liabilities, investments, and overall net worth in one place.

### Actions
* Get Started

---

## Financial Philosophy Screen

### Assets Included
* Cash
* Bank Balances
* Receivables
* Invested Capital

### Excluded
* Unrealized Gains
* Expected Income

### Formula
```text
Net Worth = Assets - Liabilities
```

Action: Continue

---

## Currency Selection

Single screen, set once.

```text
Select your currency
[ INR ▾ ]
```

Note: this cannot be changed later without a dedicated migration tool.
Choose carefully.

Action: Continue

---

## Initial Setup

### Step 1 — Create Accounts

Examples: Cash Wallet, Slice, Canara, Kotak

Fields: Account Name, Type (cash/bank/wallet/credit/other), Opening Balance

> If Type = credit, the "opening balance" is recorded as an opening
> liability, not a cash balance — the screen relabels the field
> accordingly ("Current Amount Owed on this Card").

### Step 2 — Existing Wealth (Optional, Skippable)

For users who already have investments, receivables, or liabilities
before they started using Worth:

```text
Do you have any of the following already?

[ ] Existing Investments
[ ] Money Someone Owes You
[ ] Money You Owe Someone
```

Each checked item opens a short inline form to record an opening
transaction (e.g. an `investment_buy` dated today with today's cost basis,
or a `lend_money`/`borrow_money` dated today). This ensures Day 1 Net
Worth reflects the user's actual full position, not just their bank
accounts — a gap in the original flow.

Action: Skip for now / Finish Setup

---

# Main Navigation

Bottom Navigation

```text
Dashboard
Portfolio
Transactions
Reports
More
```

> **Naming consistency rule:** this tab is called "Portfolio" everywhere
> in the app — in code, in UI copy, and in all specs. UI_UX.md previously
> used "Holdings" for the same tab; that has been corrected there to match
> this document. Pick one name and do not let it drift.

---

# Dashboard Flow

## Purpose
Provide a complete financial snapshot.

## Header
```text
Worth
```

## Primary Metric

### Net Worth
```text
₹214,350
```
Tap: Navigate to Net Worth Breakdown.

## Summary Cards

### Assets — tap: Open Assets Overview
### Liabilities — tap: Open Liabilities Overview
### Invested Capital — tap: Open Investments
### Expected Income — tap: Open Expected Income

## Net Worth Trend Chart

Filters: 30D / 90D / 1Y / ALL
Tap point: Open Snapshot Details

## Quick Actions

```text
+ Transaction
+ Investment
+ Receivable
+ Liability
```

---

# Portfolio Flow

Purpose: Track all wealth-related entities in one consistent place.

> **Liabilities now live inside Portfolio as a peer tab to Assets,
> Investments, and Receivables** — not only reachable from the Dashboard.
> The original flow placed Liabilities in a different navigational tier
> than the conceptually equivalent Receivables, which was a real
> information-architecture inconsistency. The Dashboard liability card
> still deep-links here; it's simply no longer the *only* entry point.

## Tabs

```text
Assets
Liabilities
Investments
Receivables
Expected Income
```

---

# Assets Flow

## Asset List
Examples: Cash Wallet, Canara, Slice, Gold Holdings

## Asset Detail

Displays: Current Balance (calculated), Notes, Transaction History

Actions: Add Transaction, Edit Details (name/notes only — never balance),
Archive Account

---

# Investments Flow

## Investment List
Examples: Gold ETF, Mutual Fund, Stocks

## Investment Detail

Displays:
* Invested Capital (FIFO cost basis of open lots)
* Market Value (manually updated, with "Last updated" timestamp shown)
* Unrealized Gain/Loss
* Realized Gain/Loss (all-time, from past sales)
* Lot-level purchase history
* Transaction History

Actions: Add Purchase (creates a new lot), Add Sale (consumes oldest open
lot(s) first via FIFO — UI shows which lot(s) will be consumed before
confirming), Update Market Value

---

# Receivables Flow

## Receivable List
Examples: Sohan ₹17,700 · Manoj ₹3,100

## Receivable Detail

Displays: Outstanding Amount, Recovery History, Notes

Actions: Recover Money, Mark Settled

---

# Expected Income Flow

## List
Examples: Referral Reward, Cashback, Pending Payment

## Detail

Displays: Expected Amount, Expected Date, Notes

Actions: Mark Received (prompts for destination account, creates a real
income transaction), Mark Expired

---

# Liabilities Flow

Accessed from Portfolio (peer tab) or Dashboard card (deep link).

## Liability List
Examples: Mama ₹120,000 · Pragnya ₹22,000 · HDFC Credit Card ₹8,500

> Credit account liabilities appear in this same list alongside person
> liabilities — both are "money the user owes," consistent with
> BUSINESS_RULES.md.

## Liability Detail

Displays: Outstanding Amount, Payment History, Notes

Actions: Repay, Close Liability

---

# Transactions Flow

Purpose: Every financial activity must be recorded here.

## Transaction Feed

Displays chronological events, grouped by date, paginated.

Example:
```text
Today
Received ₹500 from Sohan
Paid ₹2,000 to Mama
```

Voided transactions appear with a "Voided" strikethrough label and are
excluded from all balance calculations, but remain visible for audit.

## Add Transaction Flow (Revised — Single Screen for Common Cases)

The original 6-step linear wizard exceeded the app's own "max 5 taps"
goal for the most common cases (income/expense/transfer). Revised:

### Common case (Income, Expense, Transfer): one screen

```text
[ Income | Expense | Transfer ]   ← segmented control, top of sheet
Amount: [______]
Account: [______]   (Transfer shows From + To)
Category: [______]   (Income/Expense only)
Notes: [______]   (optional, collapsed by default)
[ Save ]
```

This is reachable in 2-3 taps: open sheet → type amount → tap save (with
smart defaults pre-filling the most recently used account).

### Cases needing a person or investment (Borrow, Repay, Lend, Recover,
Investment Buy/Sell): progressive disclosure

Same single bottom-sheet pattern, with an additional required field
(Person or Investment) that appears based on the selected type. Still no
more than one screen, no multi-step wizard.

### Correcting a Mistake

From the Transaction Feed, swipe or long-press → "Void Transaction" →
confirm. Creates the inverse transaction automatically; both entries
remain visible.

## Result

All balances update automatically via the live balance cache (see
SYSTEM_DESIGN.md) — no manual refresh needed.

---

# Reports Flow

## Tabs
```text
Monthly
Quarterly
Yearly
```

## Monthly Report
Opening Net Worth, Closing Net Worth, Net Change, New Investments,
Liabilities Reduced, Spending by Category

## Annual Report
Opening Net Worth, Closing Net Worth, Growth %, Largest Asset, Largest
Liability

---

# Goals Flow

Passive milestone markers only (not budgeting). Examples: Emergency Fund,
Laptop Fund, Travel Fund.

## Goal Detail

Displays: Target Amount, Current Progress (calculated live from Net Worth
or a linked account — never an editable field), Deadline

---

# Definitions Center

Purpose: Explain all financial terms.

## Search
Examples: Net Worth, Assets, Liabilities, Receivables, Invested Capital

## Definition Page
Contains: Definition, Formula, Example, Included Items, Excluded Items

---

# Search Flow

Global Search (FTS5-backed, instant results, no search button required)

Search: Accounts, Investments, People, Transactions, Liabilities, Goals

---

# Backup Flow

```text
Settings → Backup → Set Passphrase → Export Encrypted JSON
```

---

# Restore Flow

```text
Settings → Restore → Import Encrypted JSON → Enter Passphrase →
Validate → Replace Database → Rebuild Balance Cache (full replay) →
Rebuild Search Index
```

---

# Recalculate Balances Flow (New)

For trust and recovery — lets a user force a full replay rebuild of all
calculated balances if they ever doubt the numbers shown.

```text
Settings → Advanced → Recalculate Balances → Confirm →
Full replay from transaction log → Cache rebuilt → Confirmation shown
```

---

# Constrained Natural-Language Query (V1 scope — see SYSTEM_DESIGN.md)

Entry point: ✨ icon, top-right corner.

Supported query patterns (intent-classified, not free-form AI chat):

```text
How much does [Person] owe me?
How much do I owe [Person]?
What was my net worth in [Month]?
Show investments above ₹[Amount].
```

Each maps to a known calculation already exposed by the Service layer —
no general-purpose conversational assistant in V1. A broader assistant is
a distinct, future-scoped feature (see FEATURES_ROADMAP.md).

---

# Core User Loop

```text
Open App
    ↓
Check Net Worth
    ↓
Review Changes
    ↓
Record New Financial Event
    ↓
Net Worth Updates
    ↓
Track Progress Over Time
```
