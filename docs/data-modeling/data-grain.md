# Aurelia Data Grain Definitions

## 1. Purpose

This document defines the intended grain of Aurelia's major transactional, planning, and analytical datasets.

The grain describes exactly what a single row represents.

Grain must be established before facts, dimensions, measures, and analytical relationships are designed.

---

# 2. Sales Pipeline

## Opportunity Grain

**One row represents one sales opportunity at its current state.**

Example:

| Opportunity | Client        | Stage    |  Amount |
| ----------- | ------------- | -------- | ------: |
| OPP-1001    | Northstar Ltd | Proposal | 120,000 |

For historical pipeline analysis, separate opportunity-stage history may later be captured.

---

# 3. Resource Allocation

## Allocation Grain

**One row represents one employee's planned allocation to one project for one defined planning period.**

Initial planning period:

**Week**

Example:

| Week       | Employee | Project  | Planned Hours |
| ---------- | -------- | -------- | ------------: |
| 2026-09-07 | EMP-001  | PRJ-1001 |            24 |
| 2026-09-07 | EMP-001  | PRJ-1002 |             8 |

This allows weekly capacity and demand planning.

---

# 4. Employee Capacity

## Capacity Grain

**One row represents the available working capacity of one employee for one work date.**

Example:

| Date       | Employee | Available Hours |
| ---------- | -------- | --------------: |
| 2026-09-07 | EMP-001  |               8 |
| 2026-09-08 | EMP-001  |               8 |

Daily capacity provides sufficient flexibility to aggregate into weeks, months, quarters, and years.

---

# 5. Timesheets

## Timesheet Entry Grain

**One row represents one employee's recorded hours against one project or internal activity on one work date.**

Example:

| Date       | Employee | Project  | Activity    | Hours |
| ---------- | -------- | -------- | ----------- | ----: |
| 2026-09-07 | EMP-001  | PRJ-1001 | Development |     6 |
| 2026-09-07 | EMP-001  | INTERNAL | Training    |     2 |

Timesheet data represents actual work rather than planned allocation.

---

# 6. Project Budget

## Budget Grain

**One row represents one project budget category for one budget version.**

Example:

| Project  | Version  | Category |  Budget |
| -------- | -------- | -------- | ------: |
| PRJ-1001 | Original | Labor    | 150,000 |
| PRJ-1001 | Original | Travel   |  20,000 |

Future revisions may introduce additional budget versions.

---

# 7. Invoice

Invoices contain two different grains.

## Invoice Header Grain

**One row represents one invoice issued to one customer.**

Example:

| Invoice  | Customer | Invoice Date |  Total |
| -------- | -------- | ------------ | -----: |
| INV-1001 | CUST-001 | 2026-09-30   | 50,000 |

## Invoice Line Grain

**One row represents one chargeable line within an invoice.**

Example:

| Invoice  | Line | Project  | Description         | Amount |
| -------- | ---: | -------- | ------------------- | -----: |
| INV-1001 |    1 | PRJ-1001 | Consulting Services | 40,000 |
| INV-1001 |    2 | PRJ-1001 | Expenses            | 10,000 |

Invoice-line grain will generally be more useful for detailed analytical modeling.

---

# 8. Payment

## Payment Grain

**One row represents one payment received from a customer.**

A payment may later require a bridge/allocation structure when one payment settles multiple invoices or one invoice receives multiple payments.

Example:

| Payment  | Customer | Date       | Amount |
| -------- | -------- | ---------- | -----: |
| PAY-1001 | CUST-001 | 2026-10-15 | 50,000 |

---

# 9. General Ledger

## GL Entry Grain

**One row represents one accounting posting line within a journal transaction.**

Example:

| Journal | Line | Account             |  Debit | Credit |
| ------- | ---: | ------------------- | -----: | -----: |
| JE-1001 |    1 | Accounts Receivable | 50,000 |      0 |
| JE-1001 |    2 | Consulting Revenue  |      0 | 50,000 |

A journal transaction therefore normally contains multiple GL-entry rows.

---

# 10. Project Financials

Project financial analytics may combine multiple transactional sources.

The underlying datasets should retain their natural transaction grain rather than prematurely aggregating everything into one project-level row.

Examples include:

* Timesheet labor transactions
* Invoice lines
* Direct expenses
* Budget lines
* GL entries

Aggregated project financial models may subsequently provide:

```text
Project + Month

Revenue
Labor Cost
Direct Cost
Gross Profit
Margin
Budget
Variance
```

---

# 11. Grain Rule

Before creating a fact table, the engineer must be able to complete the sentence:

> **One row represents...**

If that sentence is ambiguous, the fact table is not sufficiently designed.

Measures from different grains must not be joined directly in ways that duplicate or distort values.
