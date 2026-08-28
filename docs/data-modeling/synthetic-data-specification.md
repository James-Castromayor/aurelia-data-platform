# Aurelia Synthetic Data Specification

## 1. Purpose

This document defines the synthetic dataset used by the Aurelia Enterprise Cloud Data & Analytics Platform.

All generated information represents fictional organizations, employees, projects, financial transactions, and business activity.

The dataset should resemble a realistic professional-services company while remaining completely synthetic.

---

# 2. Company Profile

Aurelia Consulting Group is a mid-sized international professional-services company.

Primary services:

* Cloud Consulting
* Data & Analytics
* Software Engineering
* Business Transformation
* Managed Services

Operating regions:

* APAC
* North America
* Europe

Reporting currency:

**USD**

Individual transactions may use additional currencies later to support currency-conversion scenarios.

---

# 3. Dataset Time Period

Initial historical period:

**January 2024 onward**

The dataset should contain multiple years of activity so that analytics can demonstrate:

* monthly trends
* quarterly trends
* year-over-year comparison
* seasonality
* employee changes
* project lifecycle changes
* customer growth
* revenue trends

---

# 4. Approximate Dataset Size

The initial dataset should contain approximately:

| Entity               | Approximate Volume |
| -------------------- | -----------------: |
| Employees            |                150 |
| Skills               |                 30 |
| Employee Skills      |            600–900 |
| CRM Companies        |                120 |
| CRM Contacts         |            250–400 |
| Opportunities        |            300–500 |
| Clients              |              60–80 |
| Contracts            |            100–150 |
| Projects             |            150–250 |
| Resource Allocations |       8,000–15,000 |
| Capacity Records     |            50,000+ |
| Timesheet Entries    |     80,000–150,000 |
| Project Budget Lines |          500–1,000 |
| Invoices             |        1,500–3,000 |
| Invoice Lines        |        3,000–7,000 |
| Payments             |        1,000–2,500 |
| GL Entries           |      10,000–30,000 |

Exact volumes may change during implementation.

The objective is realism without unnecessary scale.

---

# 5. Employees

Approximately 150 employees should be distributed across functions such as:

* Consulting
* Data & Analytics
* Software Engineering
* Project Management
* Sales
* Finance
* Operations
* Management

Example roles:

* Data Engineer
* Analytics Engineer
* BI Developer
* Software Engineer
* Cloud Engineer
* Business Analyst
* Project Manager
* Consultant
* Solution Architect
* Sales Executive
* Finance Analyst

Employees should have realistic:

* hire dates
* job titles
* managers
* business units
* cost centers
* skills
* cost rates
* billing rates
* capacity

Some employees should leave during the historical period.

Some employees should join during the historical period.

---

# 6. Skills

Example technical and professional skills:

* SQL
* Python
* Azure
* AWS
* Snowflake
* dbt
* Power BI
* PostgreSQL
* .NET
* React
* Data Modeling
* Data Engineering
* Business Analysis
* Project Management
* Financial Analysis

Employees may have multiple skills with different proficiency levels.

---

# 7. CRM Companies and Clients

Not every CRM Company becomes a Client.

The dataset should contain approximately:

```text
120 CRM Companies
        ↓
300–500 Opportunities
        ↓
Won Opportunities
        ↓
60–80 Actual Clients
```

This allows analysis of:

* sales conversion
* pipeline value
* win rate
* lost opportunities
* client acquisition

---

# 8. Opportunities

Opportunity stages may include:

1. Qualification
2. Discovery
3. Proposal
4. Negotiation
5. Closed Won
6. Closed Lost

Opportunity values should vary significantly.

Example:

```text
Small engagement       $15,000
Medium engagement      $75,000
Large engagement       $250,000
Strategic engagement   $750,000+
```

The dataset should include both won and lost opportunities.

---

# 9. Projects

Projects should represent different service types, sizes, durations, and commercial arrangements.

Billing types:

* Time & Materials
* Fixed Price
* Retainer

Project durations may range from several weeks to more than one year.

Statuses:

* Planned
* Active
* On Hold
* Completed
* Cancelled

---

# 10. Resource Capacity

A normal full-time employee has approximately:

```text
8 hours/day
40 hours/week
```

Capacity should account for:

* weekends
* holidays
* leave
* employee start dates
* employee termination dates

This creates realistic available-hours calculations.

---

# 11. Resource Allocation

Resource allocations represent planned work.

Example:

```text
Employee: EMP-0042
Week: 2026-09-07

Project Alpha       24 hours
Project Beta         8 hours
Internal Work        4 hours

Total Allocation    36 hours
Capacity            40 hours
```

Some employees should deliberately be:

* underallocated
* fully allocated
* overallocated

Example overallocation:

```text
Capacity       40
Allocation     52

Overallocation = 12 hours
```

This creates meaningful resource-management analytics.

---

# 12. Timesheets

Timesheets represent actual work.

Actual hours should generally resemble planned allocations but should not match them perfectly.

Example:

```text
Planned = 32 hours
Actual  = 29 hours
```

Timesheets should contain:

* billable project work
* non-billable project work
* internal administration
* training
* leave where appropriate

This enables utilization analysis.

---

# 13. Project Budgets

Projects should contain budget categories such as:

* Labor
* Contractor
* Travel
* Software
* Other Direct Costs

Some projects should remain within budget.

Some should exceed budget.

Example:

```text
Project Alpha

Budget        $200,000
Actual Cost   $175,000

Variance       $25,000 favorable
```

versus:

```text
Project Beta

Budget        $150,000
Actual Cost   $190,000

Variance      -$40,000 unfavorable
```

---

# 14. Invoices

Invoices should reflect realistic project billing.

Invoice statuses:

* Draft
* Issued
* Partially Paid
* Paid
* Overdue
* Cancelled

Payment terms may include:

* Net 15
* Net 30
* Net 45
* Net 60

Invoice values should correlate with project size and billing model.

---

# 15. Payments

Payments should include:

* full payments
* partial payments
* late payments
* payments covering multiple invoices

Some invoices should remain unpaid.

This allows Accounts Receivable analysis.

---

# 16. General Ledger

The synthetic finance system should contain a simplified Chart of Accounts.

Example:

## Assets

* Cash
* Accounts Receivable

## Liabilities

* Accounts Payable

## Revenue

* Consulting Revenue
* Managed Services Revenue

## Expenses

* Labor Cost
* Contractor Cost
* Travel Expense
* Software Expense
* Administrative Expense

GL journals must remain balanced:

```text
Total Debit = Total Credit
```

---

# 17. Intentional Business Scenarios

The dataset must contain identifiable business scenarios rather than pure randomness.

## Scenario A — Highly Profitable Project

Characteristics:

* strong billing
* controlled labor cost
* high utilization
* good margin

## Scenario B — Project Over Budget

Characteristics:

* labor hours exceed plan
* cost exceeds budget
* margin declines

## Scenario C — Resource Overallocation

Characteristics:

* employee capacity = 40 hours
* planned allocation > 40 hours
* multiple simultaneous projects

## Scenario D — Underutilized Consultant

Characteristics:

* high available capacity
* low billable hours

## Scenario E — Late-Paying Client

Characteristics:

* multiple overdue invoices
* increasing accounts receivable

## Scenario F — High-Value Lost Opportunity

Characteristics:

* large opportunity
* reaches negotiation stage
* eventually Closed Lost

## Scenario G — Growing Client

Characteristics:

* initial small engagement
* subsequent larger contracts
* increasing annual revenue

## Scenario H — Unprofitable Project

Characteristics:

* significant revenue
* excessive labor/direct cost
* negative or very low margin

These scenarios should be reproducible so that analytical tests and demonstrations can reference them.

---

# 18. Seasonality

The generated data should not be perfectly uniform.

Possible patterns include:

* slower sales activity during holiday periods
* stronger pipeline during selected quarters
* reduced employee capacity during holidays
* month-end invoice concentration
* quarterly revenue patterns

The exact patterns will be defined in the generator.

---

# 19. Controlled Data Quality Problems

Selected RAW source records should deliberately contain realistic data-quality problems.

Examples:

* missing industry
* inconsistent country naming
* duplicate CRM company
* mixed capitalization
* missing optional project information
* late-arriving payment
* malformed reference value
* unexpected status value

Example:

```text
United States
USA
U.S.A.
us
```

The analytical pipeline should standardize these to a governed value such as:

```text
United States
```

These errors must be deliberate and documented rather than uncontrolled corruption.

---

# 20. Reproducibility

Synthetic generation must use a fixed random seed where appropriate.

Example:

```python
random.seed(42)
```

This allows developers and reviewers to regenerate comparable datasets.

Intentional business scenarios should use deterministic rules rather than depending entirely on randomness.

---

# 21. Privacy and Security

The synthetic dataset must not contain:

* real customer information
* employer information
* proprietary project information
* real financial records
* credentials
* confidential documents
* personally identifiable information copied from real individuals

Names and organizations must be fictional or generated specifically for the portfolio.

---

# 22. Design Principle

Synthetic data should be:

**realistic enough to produce meaningful business analytics, small enough to run cheaply, complex enough to demonstrate professional data engineering, and safe enough to publish publicly.**
