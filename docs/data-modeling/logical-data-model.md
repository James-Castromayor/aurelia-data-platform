# Aurelia Logical Data Model

## 1. Purpose

This document defines the logical structure of Aurelia's core business entities.

It identifies business attributes, keys, relationships, and important rules before physical implementation in PostgreSQL or analytical modeling in Snowflake.

---

# 2. Client

## CLIENT

| Attribute            | Description                        | Required |
| -------------------- | ---------------------------------- | -------- |
| client_id            | Operational client identifier      | Yes      |
| enterprise_client_id | Cross-system enterprise identifier | Yes      |
| client_name          | Client business name               | Yes      |
| legal_name           | Registered legal name              | No       |
| industry             | Industry classification            | No       |
| country              | Primary country                    | No       |
| region               | Reporting region                   | No       |
| status               | Prospect / Active / Inactive       | Yes      |
| created_date         | Client creation date               | Yes      |

### Relationships

* One Client may have many Contracts.
* One Client may have many Projects.
* One Client may have many Invoices.

---

# 3. Contract

## CONTRACT

| Attribute       | Description                               | Required |
| --------------- | ----------------------------------------- | -------- |
| contract_id     | Contract identifier                       | Yes      |
| client_id       | Related client                            | Yes      |
| contract_number | Business-facing contract number           | Yes      |
| contract_name   | Contract description                      | Yes      |
| start_date      | Contract start                            | Yes      |
| end_date        | Contract end                              | No       |
| contract_value  | Agreed contract amount where applicable   | No       |
| billing_type    | Time & Materials / Fixed Price / Retainer | Yes      |
| currency_code   | Contract currency                         | Yes      |
| status          | Draft / Active / Completed / Terminated   | Yes      |

---

# 4. Project

## PROJECT

| Attribute          | Description                                        | Required |
| ------------------ | -------------------------------------------------- | -------- |
| project_id         | Operational project identifier                     | Yes      |
| project_number     | Business-facing project identifier                 | Yes      |
| client_id          | Owning client                                      | Yes      |
| contract_id        | Associated contract                                | No       |
| project_name       | Project name                                       | Yes      |
| project_manager_id | Responsible project manager                        | Yes      |
| business_unit_id   | Owning business unit                               | Yes      |
| service_id         | Primary consulting service                         | Yes      |
| billing_type       | Billing arrangement                                | Yes      |
| currency_code      | Project reporting currency                         | Yes      |
| start_date         | Project start                                      | Yes      |
| end_date           | Planned/project end                                | No       |
| project_status     | Planned / Active / On Hold / Completed / Cancelled | Yes      |
| budget_amount      | High-level approved budget                         | No       |

---

# 5. Employee

## EMPLOYEE

| Attribute            | Description                             | Required |
| -------------------- | --------------------------------------- | -------- |
| employee_id          | Operational employee identifier         | Yes      |
| employee_number      | Business-facing employee number         | Yes      |
| first_name           | First name                              | Yes      |
| last_name            | Last name                               | Yes      |
| email                | Synthetic business email                | Yes      |
| job_title            | Job title                               | Yes      |
| employment_type      | Employee / Contractor                   | Yes      |
| business_unit_id     | Organizational business unit            | Yes      |
| cost_center_id       | Financial cost center                   | Yes      |
| manager_employee_id  | Employee's manager                      | No       |
| hire_date            | Start date                              | Yes      |
| termination_date     | End date where applicable               | No       |
| status               | Active / Inactive                       | Yes      |
| standard_daily_hours | Normal daily capacity                   | Yes      |
| billing_rate         | Standard billable rate where applicable | No       |
| cost_rate            | Internal labor cost rate                | No       |

---

# 6. Skill

## SKILL

| Attribute      | Description       | Required |
| -------------- | ----------------- | -------- |
| skill_id       | Skill identifier  | Yes      |
| skill_name     | Skill name        | Yes      |
| skill_category | Skill grouping    | Yes      |
| status         | Active / Inactive | Yes      |

## EMPLOYEE_SKILL

| Attribute         | Description                                 | Required |
| ----------------- | ------------------------------------------- | -------- |
| employee_id       | Employee                                    | Yes      |
| skill_id          | Skill                                       | Yes      |
| proficiency_level | Beginner / Intermediate / Advanced / Expert | Yes      |
| years_experience  | Approximate years of experience             | No       |
| certified_flag    | Whether certification is held               | Yes      |

The combination of `employee_id` and `skill_id` must be unique.

---

# 7. Resource Allocation

## RESOURCE_ALLOCATION

| Attribute         | Description                     | Required |
| ----------------- | ------------------------------- | -------- |
| allocation_id     | Allocation identifier           | Yes      |
| employee_id       | Assigned employee               | Yes      |
| project_id        | Assigned project                | Yes      |
| week_start_date   | Planning week                   | Yes      |
| planned_hours     | Planned project hours           | Yes      |
| allocation_status | Planned / Confirmed / Cancelled | Yes      |

### Business Rules

* Planned hours cannot be negative.
* One employee may have multiple project allocations in the same week.
* Total allocation may exceed capacity, but such cases must be identifiable as overallocation.

---

# 8. Employee Capacity

## EMPLOYEE_CAPACITY

| Attribute       | Description                       | Required |
| --------------- | --------------------------------- | -------- |
| employee_id     | Employee                          | Yes      |
| capacity_date   | Work date                         | Yes      |
| available_hours | Available working hours           | Yes      |
| capacity_type   | Working / Holiday / Leave / Other | Yes      |

The combination of employee and capacity date should be unique.

---

# 9. Timesheet Entry

## TIMESHEET_ENTRY

| Attribute          | Description                  | Required |
| ------------------ | ---------------------------- | -------- |
| timesheet_entry_id | Entry identifier             | Yes      |
| employee_id        | Employee                     | Yes      |
| project_id         | Project or internal project  | Yes      |
| work_date          | Work date                    | Yes      |
| activity_code      | Type of work                 | Yes      |
| hours              | Hours worked                 | Yes      |
| billable_flag      | Whether the time is billable | Yes      |
| approved_flag      | Approval status              | Yes      |
| submitted_at       | Submission timestamp         | No       |
| approved_at        | Approval timestamp           | No       |

### Business Rules

* Hours must be greater than zero.
* Hours should not exceed defined maximum daily limits without exception handling.
* Approved time contributes to official actual-hours reporting.

---

# 10. Project Budget

## PROJECT_BUDGET

| Attribute         | Description                         | Required |
| ----------------- | ----------------------------------- | -------- |
| project_budget_id | Budget row identifier               | Yes      |
| project_id        | Project                             | Yes      |
| budget_version    | Budget version                      | Yes      |
| budget_category   | Labor / Contractor / Travel / Other | Yes      |
| budget_amount     | Approved amount                     | Yes      |
| effective_date    | Effective date of budget            | Yes      |

---

# 11. Invoice

## INVOICE

| Attribute      | Description                                        | Required |
| -------------- | -------------------------------------------------- | -------- |
| invoice_id     | Finance identifier                                 | Yes      |
| invoice_number | Business invoice number                            | Yes      |
| customer_id    | Finance customer identifier                        | Yes      |
| client_id      | Enterprise/operational client reference            | Yes      |
| invoice_date   | Invoice issue date                                 | Yes      |
| due_date       | Payment due date                                   | Yes      |
| currency_code  | Invoice currency                                   | Yes      |
| invoice_status | Draft / Issued / Partially Paid / Paid / Cancelled | Yes      |
| invoice_total  | Document total                                     | Yes      |

## INVOICE_LINE

| Attribute       | Description             | Required |
| --------------- | ----------------------- | -------- |
| invoice_line_id | Invoice-line identifier | Yes      |
| invoice_id      | Parent invoice          | Yes      |
| line_number     | Invoice-line sequence   | Yes      |
| project_id      | Related project         | No       |
| service_id      | Related service         | No       |
| description     | Line description        | Yes      |
| quantity        | Billed quantity         | No       |
| unit_rate       | Unit rate               | No       |
| line_amount     | Line amount             | Yes      |

The combination of invoice and line number must be unique.

---

# 12. Payment

## PAYMENT

| Attribute        | Description                  | Required |
| ---------------- | ---------------------------- | -------- |
| payment_id       | Payment identifier           | Yes      |
| customer_id      | Finance customer             | Yes      |
| payment_date     | Date received                | Yes      |
| currency_code    | Currency                     | Yes      |
| payment_amount   | Amount received              | Yes      |
| payment_method   | Bank Transfer / Card / Other | No       |
| reference_number | Payment reference            | No       |

## PAYMENT_ALLOCATION

| Attribute             | Description               | Required |
| --------------------- | ------------------------- | -------- |
| payment_allocation_id | Allocation identifier     | Yes      |
| payment_id            | Payment                   | Yes      |
| invoice_id            | Invoice                   | Yes      |
| allocated_amount      | Amount applied to invoice | Yes      |

### Business Rule

The total amount allocated from a payment should not exceed the payment amount.

---

# 13. Finance Organization

## BUSINESS_UNIT

| Attribute          | Description              | Required |
| ------------------ | ------------------------ | -------- |
| business_unit_id   | Business-unit identifier | Yes      |
| business_unit_name | Name                     | Yes      |
| region             | Reporting region         | No       |
| status             | Active / Inactive        | Yes      |

## COST_CENTER

| Attribute        | Description            | Required |
| ---------------- | ---------------------- | -------- |
| cost_center_id   | Cost-center identifier | Yes      |
| business_unit_id | Parent business unit   | Yes      |
| cost_center_code | Business code          | Yes      |
| cost_center_name | Name                   | Yes      |
| status           | Active / Inactive      | Yes      |

---

# 14. General Ledger

## GL_ACCOUNT

| Attribute    | Description                                    | Required |
| ------------ | ---------------------------------------------- | -------- |
| account_id   | Account identifier                             | Yes      |
| account_code | Chart-of-accounts code                         | Yes      |
| account_name | Account name                                   | Yes      |
| account_type | Asset / Liability / Equity / Revenue / Expense | Yes      |
| status       | Active / Inactive                              | Yes      |

## GL_JOURNAL

| Attribute        | Description                       | Required |
| ---------------- | --------------------------------- | -------- |
| journal_id       | Journal identifier                | Yes      |
| journal_number   | Business journal number           | Yes      |
| posting_date     | Accounting posting date           | Yes      |
| source_type      | Invoice / Payment / Cost / Manual | Yes      |
| source_reference | Source transaction                | No       |
| description      | Journal description               | No       |

## GL_ENTRY

| Attribute      | Description                | Required |
| -------------- | -------------------------- | -------- |
| gl_entry_id    | Posting-line identifier    | Yes      |
| journal_id     | Parent journal             | Yes      |
| account_id     | GL account                 | Yes      |
| cost_center_id | Cost-center classification | No       |
| project_id     | Project classification     | No       |
| debit_amount   | Debit                      | Yes      |
| credit_amount  | Credit                     | Yes      |

### Business Rule

For a complete journal:

```text
SUM(debit_amount) = SUM(credit_amount)
```

---

# 15. Service

## SERVICE

| Attribute        | Description             | Required |
| ---------------- | ----------------------- | -------- |
| service_id       | Service identifier      | Yes      |
| service_code     | Business service code   | Yes      |
| service_name     | Consulting service name | Yes      |
| service_category | Service grouping        | Yes      |
| status           | Active / Inactive       | Yes      |

---

# 16. Logical Relationship Summary

```text
CLIENT
 ├── CONTRACT
 │      └── PROJECT
 │
 ├── PROJECT
 │     ├── PROJECT_BUDGET
 │     ├── RESOURCE_ALLOCATION ─── EMPLOYEE
 │     ├── TIMESHEET_ENTRY ─────── EMPLOYEE
 │     └── INVOICE_LINE
 │
 └── INVOICE
        ├── INVOICE_LINE
        └── PAYMENT_ALLOCATION ─── PAYMENT


EMPLOYEE
 ├── EMPLOYEE_SKILL ─── SKILL
 ├── RESOURCE_ALLOCATION
 ├── EMPLOYEE_CAPACITY
 └── TIMESHEET_ENTRY


BUSINESS_UNIT
 └── COST_CENTER


GL_JOURNAL
 └── GL_ENTRY
       ├── GL_ACCOUNT
       ├── COST_CENTER
       └── PROJECT
```

---

# 17. Logical Modeling Principles

1. Attributes should represent one concept each.
2. Repeating groups should be represented as related entities.
3. Many-to-many relationships should be resolved through associative entities.
4. Transaction headers and transaction lines should remain separate where they represent different grains.
5. Derived analytical measures should generally not be stored operationally unless the source system requires them.
6. Cross-system identifiers should remain traceable.
7. Physical implementation choices are deferred until the PostgreSQL design stage.
