# Aurelia Dimensional Modeling Blueprint

## 1. Purpose

This document defines the initial dimensional-modeling strategy for the Aurelia Enterprise Cloud Data & Analytics Platform.

The dimensional layer will transform normalized source-system data into business-oriented analytical models optimized for reporting, BI, and downstream analytical consumption.

---

# 2. Operational vs Analytical Modeling

The Aurelia Operations Platform uses a relatively normalized relational model.

Example:

```text
CLIENT
  ↓
CONTRACT
  ↓
PROJECT
  ↓
RESOURCE_ALLOCATION
```

This structure is appropriate for transactional applications.

The analytical platform instead organizes information around:

```text
FACTS
  +
DIMENSIONS
```

to simplify business analysis.

---

# 3. Fact Tables

A fact table represents a measurable business process at a clearly defined grain.

Initial Aurelia facts:

| Fact                | Grain                                        | Example Measures            |
| ------------------- | -------------------------------------------- | --------------------------- |
| fact_sales_pipeline | Opportunity / snapshot grain to be finalized | Pipeline value, probability |
| fact_resource_plan  | Employee + Project + Week                    | Planned hours               |
| fact_capacity       | Employee + Date                              | Available hours             |
| fact_timesheet      | Employee + Project/Activity + Date           | Actual hours                |
| fact_project_budget | Project + Budget Version + Category          | Budget amount               |
| fact_invoice        | Invoice Line                                 | Quantity, billed amount     |
| fact_payment        | Payment allocation to invoice                | Applied amount              |
| fact_gl_transaction | Journal posting line                         | Debit, credit               |
| fact_project_cost   | Project cost transaction                     | Cost amount                 |

Fact grains will be finalized before implementation.

---

# 4. Dimension Tables

Dimensions describe the business entities surrounding facts.

Initial dimensions:

```text
dim_date
dim_employee
dim_client
dim_project
dim_service
dim_business_unit
dim_cost_center
dim_account
dim_activity
dim_currency
```

Possible later dimensions:

```text
dim_contract
dim_sales_stage
dim_geography
```

Dimensions will only be introduced where they provide useful analytical context.

---

# 5. Example Timesheet Star Schema

```text
                    DIM_EMPLOYEE
                         │
                         │
                         ▼
DIM_DATE ─────── FACT_TIMESHEET ─────── DIM_PROJECT
                         │
                         │
                         ▼
                    DIM_ACTIVITY
```

Example fact:

```text
fact_timesheet

date_key
employee_key
project_key
activity_key
hours
billable_hours
labor_cost
```

Example dimensions provide descriptive attributes such as:

```text
dim_employee
-------------
employee_key
employee_number
employee_name
job_title
business_unit
employment_type
```

and:

```text
dim_project
-------------
project_key
project_number
project_name
client
service
project_status
billing_type
```

---

# 6. Conformed Dimensions

Important dimensions should be reusable across multiple facts.

For example:

```text
                        DIM_PROJECT
                            │
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                 ▼
   FACT_TIMESHEET     FACT_INVOICE      FACT_BUDGET
```

The same governed Project dimension allows different business processes to be analyzed consistently.

Similarly:

```text
                         DIM_DATE
                            │
       ┌────────────┬───────┼────────┬────────────┐
       ▼            ▼       ▼        ▼            ▼
   TIMESHEET     INVOICE  PAYMENT  PIPELINE     CAPACITY
```

These are **conformed dimensions**.

---

# 7. Sales Analytics

Initial sales star:

```text
                    DIM_CLIENT
                         │
                         ▼
DIM_DATE ─── FACT_SALES_PIPELINE ─── DIM_SALES_STAGE
                         │
                         ▼
                    DIM_SERVICE
```

Potential measures:

* opportunity value
* weighted pipeline
* opportunity count
* won amount
* lost amount

Derived KPIs may include:

* win rate
* average deal size
* sales-cycle duration

---

# 8. Resource Analytics

Resource planning requires multiple facts:

```text
                DIM_EMPLOYEE
                     │
          ┌──────────┼───────────┐
          ▼          ▼           ▼
      CAPACITY    RESOURCE     TIMESHEET
                    PLAN
          │          │           │
          └──────────┼───────────┘
                     │
                  DIM_DATE
```

These facts should not be directly joined together at their raw grains.

Instead, compatible analytical models may aggregate them to:

```text
Employee + Week
```

to calculate:

```text
Capacity Hours
Planned Hours
Actual Hours
Billable Hours
Available Hours
Overallocation
Utilization
```

---

# 9. Project Financial Analytics

Project profitability combines several business processes.

```text
                    DIM_PROJECT
                         │
        ┌────────────────┼─────────────────┐
        ▼                ▼                 ▼
    INVOICE           COST             BUDGET
      FACT             FACT              FACT
```

A downstream mart may aggregate these to:

```text
Project + Month
```

and calculate:

```text
Revenue
Labor Cost
Direct Cost
Total Cost
Gross Profit
Gross Margin
Budget
Budget Variance
```

---

# 10. Additive Measures

Some measures can safely be summed across all dimensions.

Examples:

```text
Timesheet Hours
Invoice Amount
Cost Amount
Planned Hours
```

These are generally additive.

---

# 11. Semi-Additive Measures

Some measures can be summed across certain dimensions but not all dimensions.

Examples may include:

* account balance
* outstanding AR balance
* headcount snapshots

A month-end AR balance should not normally be summed across every day in the month.

These require deliberate modeling.

---

# 12. Non-Additive Measures

Ratios and percentages generally should not simply be summed.

Examples:

```text
Gross Margin %
Utilization %
Win Rate %
```

For example:

```text
Project A margin = 50%
Project B margin = 10%
```

does not necessarily mean:

```text
Overall margin = 60%
```

The correct overall calculation should normally derive from the underlying additive values.

Example:

```text
Overall Margin =
Total Gross Profit / Total Revenue
```

---

# 13. Slowly Changing Dimensions

Aurelia will evaluate historical tracking requirements dimension by dimension.

Potential SCD Type 2 candidates:

* Employee organizational assignment
* Employee job role
* Client reporting region
* Project classification where historical reporting requires it

Example:

```text
employee_key | employee_number | job_title       | valid_from | valid_to
101          | EMP-001         | Data Engineer   | 2024-01-01 | 2025-06-30
247          | EMP-001         | Senior Data Eng | 2025-07-01 | Current
```

Not every changed attribute requires Type 2 history.

---

# 14. Role-Playing Date Dimension

The same `dim_date` may represent different business dates.

For an invoice:

```text
Invoice Date
Due Date
Payment Date
```

Rather than creating unrelated calendar logic for each one, the same Date dimension can play different roles.

Example:

```text
dim_date → invoice_date_key

dim_date → due_date_key
```

This is called a role-playing dimension.

---

# 15. Degenerate Dimensions

Some transaction identifiers may remain directly in fact tables without requiring their own descriptive dimension.

Examples:

```text
invoice_number
journal_number
timesheet_entry_number
```

These are potential degenerate dimensions.

---

# 16. Fact-to-Fact Joining

Raw fact tables should generally not be directly joined simply because they share a Project or Employee.

Bad example:

```text
FACT_TIMESHEET
      ↓
FACT_INVOICE
      ↓
FACT_BUDGET
```

This can multiply rows and produce incorrect totals.

Preferred pattern:

```text
              DIM_PROJECT
             /     |      \
            /      |       \
 TIMESHEET_FACT INVOICE_FACT BUDGET_FACT
```

or create a controlled downstream model at a compatible grain.

---

# 17. Initial Analytical Marts

The initial dbt analytical layer is expected to eventually provide marts such as:

```text
marts/
├── core/
├── sales/
├── projects/
├── resources/
├── finance/
└── executive/
```

Examples:

```text
mart_sales_pipeline
mart_resource_utilization
mart_project_profitability
mart_accounts_receivable
mart_executive_kpis
```

These will be designed after the underlying facts and dimensions are validated.

---

# 18. Design Principle

The dimensional model should make business questions easier to answer without sacrificing correctness.

The goal is not to create the largest possible warehouse model.

The goal is to create a small number of well-defined facts and conformed dimensions that support Aurelia's actual analytical requirements.
