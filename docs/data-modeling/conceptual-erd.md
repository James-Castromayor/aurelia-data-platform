# Aurelia Conceptual Entity Relationship Model

## 1. Purpose

This document defines the major business entities and relationships within Aurelia Consulting Group.

The conceptual model focuses on business meaning and cardinality rather than physical database implementation.

---

# 2. Sales Domain

```text
COMPANY
   │
   ├──── 1 : * ──── CONTACT
   │
   └──── 1 : * ──── OPPORTUNITY
                         │
                         └──── 1 : * ──── PROPOSAL
```

## Relationships

A Company may have multiple Contacts.

A Company may have multiple Opportunities.

An Opportunity may have multiple Proposal versions.

A successful Opportunity may eventually result in a Client relationship.

---

# 3. Client and Contract Domain

```text
CLIENT
   │
   ├──── 1 : * ──── CONTRACT
   │                    │
   │                    └──── 1 : * ──── PROJECT
   │
   └──── 1 : * ──── PROJECT
```

## Relationships

A Client may have multiple Contracts.

A Client may have multiple Projects.

A Contract may support multiple Projects.

Each Project belongs to one Client.

---

# 4. Project Domain

```text
PROJECT
   │
   ├──── 1 : * ──── PROJECT_MILESTONE
   │
   ├──── 1 : * ──── PROJECT_BUDGET
   │
   ├──── 1 : * ──── RESOURCE_ALLOCATION
   │
   └──── 1 : * ──── TIMESHEET_ENTRY
```

Projects are the central operational delivery entity.

---

# 5. Workforce Domain

```text
EMPLOYEE
   │
   ├──── 1 : * ──── RESOURCE_ALLOCATION
   │
   ├──── 1 : * ──── TIMESHEET_ENTRY
   │
   ├──── 1 : * ──── EMPLOYEE_SKILL
   │
   └──── 1 : * ──── EMPLOYEE_CAPACITY


SKILL
   │
   └──── 1 : * ──── EMPLOYEE_SKILL
```

`EMPLOYEE_SKILL` resolves the many-to-many relationship:

```text
EMPLOYEE * ───── * SKILL
```

into:

```text
EMPLOYEE
    │
    1
    │
    *
EMPLOYEE_SKILL
    *
    │
    1
    │
  SKILL
```

---

# 6. Project Staffing

Employees and Projects have a many-to-many relationship.

```text
EMPLOYEE * ───────── * PROJECT
```

This relationship is resolved through Resource Allocation.

```text
EMPLOYEE
    │
    1
    │
    *
RESOURCE_ALLOCATION
    *
    │
    1
    │
 PROJECT
```

Resource Allocation represents planned project work.

Timesheet Entry separately represents actual work.

```text
EMPLOYEE
    │
    ├──── RESOURCE_ALLOCATION ──── PROJECT
    │              PLAN
    │
    └──── TIMESHEET_ENTRY ──────── PROJECT
                   ACTUAL
```

---

# 7. Finance Domain

```text
CLIENT
   │
   └──── 1 : * ──── INVOICE
                         │
                         └──── 1 : * ──── INVOICE_LINE
```

Invoices represent amounts billed to Clients.

Invoice Lines provide the detailed billable components.

Where possible, Invoice Lines may reference Projects.

```text
PROJECT
   │
   └──── 1 : * ──── INVOICE_LINE
```

---

# 8. Payments

The relationship between Invoice and Payment may be many-to-many.

A customer may:

* pay one invoice with one payment,
* partially pay an invoice,
* use one payment for several invoices.

Therefore:

```text
INVOICE * ───────── * PAYMENT
```

is resolved through:

```text
INVOICE
    │
    1
    │
    *
PAYMENT_ALLOCATION
    *
    │
    1
    │
 PAYMENT
```

`PAYMENT_ALLOCATION` represents how much of a payment is applied to a particular invoice.

---

# 9. Finance Organization

```text
BUSINESS_UNIT
      │
      └──── 1 : * ──── COST_CENTER


GL_ACCOUNT
      │
      └──── 1 : * ──── GL_ENTRY


COST_CENTER
      │
      └──── 1 : * ──── GL_ENTRY
```

These entities allow financial transactions to be classified for accounting and management reporting.

---

# 10. Enterprise Conceptual Model

```text
                           COMPANY
                          /       \
                         /         \
                    CONTACT     OPPORTUNITY
                                   │
                                PROPOSAL
                                   │
                              Closed Won
                                   │
                                   ▼
                                 CLIENT
                                /      \
                               /        \
                         CONTRACT      INVOICE
                            │             │
                            │        INVOICE_LINE
                            │             │
                            ▼             │
                         PROJECT ◄────────┘
                       /    │    \
                      /     │     \
                     /      │      \
            MILESTONE    BUDGET    RESOURCE_ALLOCATION
                                      │
                                      │
                                   EMPLOYEE
                                   /      \
                                  /        \
                         TIMESHEET_ENTRY   EMPLOYEE_SKILL
                              │                 │
                              │               SKILL
                              ▼
                           PROJECT


INVOICE
   │
   │
PAYMENT_ALLOCATION
   │
   ▼
PAYMENT
```

---

# 11. Key Modeling Decisions

## Plan and Actual Remain Separate

Resource Allocation represents planned work.

Timesheet Entry represents actual work.

They must not be treated as the same business transaction.

## Invoice Header and Line Remain Separate

Invoice represents the financial document.

Invoice Line represents individual billable components.

## Payments Support Flexible Allocation

Payment Allocation allows partial payments and payments covering multiple invoices.

## Many-to-Many Relationships Are Resolved Explicitly

Associative entities include:

* Employee Skill
* Resource Allocation
* Payment Allocation

This provides both relational integrity and space for attributes describing the relationship.

---

# 12. Next Modeling Stage

This conceptual model deliberately excludes most physical attributes.

The next stage will convert the business model into a logical model defining:

* identifiers
* attributes
* required fields
* data types conceptually
* foreign keys
* business rules
* status values

Physical PostgreSQL implementation will follow only after the logical model is reviewed.
