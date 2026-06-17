# Worth - UI & UX Guidelines

## Design Philosophy

Worth should feel like: a wealth management app, a personal financial
operating system, premium, calm, trustworthy, data-focused.

Worth should NOT feel like: an expense tracker, a budgeting app, a stock
trading platform, a banking application.

---

# Design Principles

## 1. Net Worth First

Every screen should reinforce the user's understanding of their financial
position. The Net Worth card should always be visible or easily
accessible.

## 2. Minimal Data Entry

Goals:
* Maximum 5 taps to record a common transaction (income/expense/transfer)
* Smart defaults — pre-fill most recently used account
* Autofill recent entries

> The transaction entry flow is a single bottom-sheet screen with
> progressive disclosure, not a multi-step wizard — see "Add Transaction"
> below. This is required to actually meet the 5-tap goal stated here;
> a 6-step linear wizard cannot meet it.

## 3. Financial Clarity

Every metric includes: Info icon, Definition, Formula, Example.

## 4. Human-Friendly Finance

Use professional financial terms (Net Worth, Assets, Liabilities, Invested
Capital, Receivables, Expected Income) but always provide explanations via
the Definitions Center.

---

# Design Language

## Theme
Premium Wealth Dashboard

Inspiration: Apple Wallet, Wealthfront, Monarch Money, Copilot Money, CRED

## Visual Style
Modern, minimal, rounded corners, high readability, large typography.
No unnecessary gradients. No flashy animations.

---

# Color System

## Light Mode
Background: `#F8FAFC`
Cards: `#FFFFFF`
Text: `#0F172A`
Success: `#16A34A`
Warning: `#B45309`  *(darkened from #F59E0B for WCAG AA contrast on white)*
Danger: `#DC2626`

## Dark Mode
Background: `#0F172A`
Cards: `#1E293B`
Text: `#F8FAFC`
Success: `#22C55E`
Warning: `#FBBF24`
Danger: `#EF4444`

> **Note:** the Warning color in Light Mode was adjusted from `#F59E0B` to
> `#B45309`. The original amber fails WCAG AA contrast (4.5:1) against a
> white card background when used for text or icons. Verify all
> color/background pairs against WCAG AA before final sign-off — this is
> a one-time accessibility audit, not a one-off fix.

---

# Typography

## Font
Recommended: Inter, SF Pro (iOS), Google Sans
Flutter: Google Fonts — Inter

## Sizes
Net Worth: 36-42px
Card Values: 24-28px
Section Headers: 18-20px
Body Text: 14-16px

---

# Navigation

## Bottom Navigation

```text
Dashboard
Portfolio
Transactions
Reports
More
```

> **Naming fixed:** this tab is "Portfolio," matching APP_FLOW.md exactly.
> The previous version of this document used "Holdings" for the same tab
> — that inconsistency is resolved here. Use "Portfolio" everywhere:
> code, copy, specs.

Maximum 5 tabs. Never exceed.

---

# Dashboard

## Layout
```text
Header
Net Worth Card
Summary Cards
Charts
Recent Activity
Quick Actions
```

## Net Worth Card

Largest element on screen.

```text
Net Worth
₹214,350
+4.5% this month
```

## Summary Cards

Grid layout: Assets, Liabilities, Invested Capital, Expected Income.
Tap card → navigate to details.

## Quick Actions

Floating Action Button:
```text
Add Transaction
Add Investment
Add Receivable
Add Liability
```

---

# Portfolio Screen

Tabs:
```text
Assets
Liabilities
Investments
Receivables
Expected Income
```

> Liabilities is now a peer tab here, consistent with Receivables being
> the conceptual mirror of Liabilities (both are "money between me and a
> person, or a credit account"). It is no longer reachable only via the
> Dashboard — see APP_FLOW.md for the full rationale.

## List Design

Card-based.

```text
Sohan
Outstanding: ₹17,700
```

Tap → open detail page.

---

# Transaction Screen

## Design Goal
Fastest screen in the app.

## Transaction Feed

Grouped by date, paginated (keyset pagination — required once a user has
more than a few hundred transactions; do not use simple OFFSET paging,
which slows down at scale).

```text
Today
Received ₹500 from Sohan
Paid ₹2,000 to Mama
```

Voided transactions show with a strikethrough + "Voided" badge and are
excluded from balance totals but remain visible.

## Add Transaction — Single Screen, Bottom Sheet

Replaces the previous 6-step linear wizard, which exceeded the app's own
5-tap goal.

```text
┌─────────────────────────────┐
│  [Income] [Expense] [Transfer] [More ▾]
│
│  Amount
│  ₹ [____________]
│
│  Account                      (From/To if Transfer)
│  [ Recently used ▾ ]
│
│  Category                     (Income/Expense only)
│  [ ____________ ]
│
│  ▸ Add notes (collapsed by default)
│
│  [          Save          ]
└─────────────────────────────┘
```

Tapping "More ▾" reveals the remaining types (Borrow, Repay, Lend,
Recover, Investment Buy/Sell, Expected Income Received) — each adds one
relevant field (Person or Investment) to this same sheet. Still one
screen, never a multi-step wizard.

### Voiding a Transaction

Long-press a transaction in the feed → "Void" → confirm. No separate
screen needed.

---

# Investment Screen

## Card Layout

```text
Gold ETF

Invested Capital     ₹20,000
Market Value          ₹24,500
Unrealized Gain        ₹4,500
Realized Gain (all-time) ₹0

Last market value update: 2 days ago
```

## Lot Detail (New)

Tapping "View Lots" shows individual purchase lots (date, units, cost per
unit, units remaining) — needed for transparency now that FIFO governs
partial sales.

## Selling

```text
Sell Gold ETF
Units to sell: [____]

This will close, in order:
  • Lot from 12 Mar 2025 — 10 units @ ₹2,000
  • Lot from 02 Jun 2025 — 5 units @ ₹2,100 (partial)

Estimated realized gain: ₹1,200
```

Showing which lots will be consumed before confirming a sale makes FIFO
visible and trustworthy rather than a hidden backend detail.

---

# Reports Screen

Charts first, numbers second.

Recommended charts:
* Net Worth Trend — Line Chart
* Asset Allocation — Pie Chart
* Liability Breakdown — Pie Chart
* Growth Rate — Bar Chart

---

# Empty States

Never show blank screens.

```text
No Investments Yet
Start tracking your first investment.
[ Add Investment ]
```

---

# Definitions Center

Accessible from ℹ icon.

Page structure: Definition, Formula, Example, Included, Excluded.

Example — Net Worth:
Definition: The value of everything you own minus everything you owe.
Formula: Assets - Liabilities
Example: Assets = ₹100,000, Liabilities = ₹20,000, Net Worth = ₹80,000

---

# Search UX

Global Search. Instant results (FTS5-backed). No search button required.

Search: Accounts, Investments, People, Transactions, Liabilities, Goals.

---

# Micro Interactions

Use subtle animations: card hover, page transition, success state.
Avoid: excessive bouncing, gamification overload, confetti. Worth should
feel professional.

---

# App Lock (New)

Optional biometric or PIN lock on app launch, recommended given the app
displays sensitive amounts (loans between family members, net worth)
that the user may not want visible to anyone who picks up their phone.

Settings → App Lock → Enable → Choose Biometric or PIN

---

# Accessibility

Minimum touch target: 48dp
Support: Large text, dark mode, screen readers
All color/background pairs verified against WCAG AA contrast minimums
(see Color System note above — this was not previously verified).

---

# Constrained Natural-Language Query

Entry point: ✨ icon, top-right corner.

Example questions (all map to known calculations — not free-form AI chat,
see SYSTEM_DESIGN.md):
* How much does Sohan owe me?
* Show liabilities above ₹10,000.
* What changed this month?

---

# UX Success Criteria

A user should be able to answer these questions within 10 seconds:

1. What is my Net Worth?
2. How much do people owe me?
3. How much do I owe?
4. How much have I invested?
5. What changed this month?
6. What future income is expected?
7. Where is my money allocated?

If any answer takes more than 10 seconds to find, the UI should be
redesigned.
