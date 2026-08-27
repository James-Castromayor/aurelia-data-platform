# Aurelia Enterprise Business Domain Model

## 1. Purpose

This document defines the core business domains, entities, ownership boundaries, and relationships used throughout the Aurelia Enterprise Cloud Data & Analytics Platform.

The model is technology-independent. It describes Aurelia's business before defining PostgreSQL tables, Snowflake structures, or dimensional models.

---

# 2. Business Domains

Aurelia is divided into six major information domains.

## Sales

Responsible for the commercial lifecycle before work begins.

Core entities:

* Lead
* Contact
* Company
* Opportunity
* Proposal

Primary source system:

**HubSpot CRM**

---

## Client & Contract Management

Represents the commercial relationship established after an opportunity is won.

Core entities:

* Client
* Contract
* Contract Service
* Billing Terms

Primary systems:

**Operations Platform + Finance**

---

## Project Operations

Represents delivery of consulting engagements.

Core entities:

* Project
* Project Milestone
* Project Budget
* Project Status
* Service

Primary source:

**Aurelia Operations Platform**

---

## Workforce & Resource Management

Represents employees, consultants, capacity, skills, and project assignments.

Core entities:

* Employee
* Skill
* Employee Skill
* Resource Allocation
* Capacity
* Timesheet
* Timesheet Entry

Primary source:

**Aurelia Operations Platform**

---

## Finance

Represents financial transactions and accounting information.

Core entities:

* Customer
* Invoice
* Invoice Line
* Payment
* Vendor
* Purchase Order
* GL Account
* GL Entry
* Cost Center
* Business Unit
* Budget
* Forecast

Primary source:

**Synthetic Finance / ERP System**

---

## Analytics

Provides integrated analytical representations of information from the preceding domains.

Core analytical concepts include:

* Revenue
* Cost
* Gross Profit
* Margin
* Utilization
* Capacity
* Pipeline
* Budget vs Actual
* Accounts Receivable
* Customer Profitability
* Project Profitability

Primary source:

**Enterprise Data Platform**

Analytics is not the authoritative transactional source for operational entities.

---

# 3. Core Business Lifecycle

```text
Company
   │
   ├── Contact
   │
   ▼
Opportunity
   │
   ▼
Proposal
   │
   ▼
Closed Won
   │
   ▼
Client
   │
   ▼
Contract
   │
   ▼
Project
   │
   ├───────────────┐
   │               │
   ▼               ▼
Milestones     Resource Allocation
                   │
                   ▼
                Employee
                   │
                   ▼
               Timesheet
                   │
                   ▼
                Labor Cost
                   │
Project ───────────┤
                   ▼
                Invoice
                   │
                   ▼
                Payment
                   │
                   ▼
           Financial Results
                   │
                   ▼
              Analytics
```

---

# 4. Core Entity Definitions

## Company

An organization recorded in the CRM that Aurelia may conduct business with.

A Company does not automatically become a Client.

---

## Contact

A person associated with a Company.

Examples include:

* prospective customer contact
* decision maker
* project sponsor
* billing contact

---

## Opportunity

A potential commercial engagement being pursued by the Sales team.

An Opportunity may be won or lost.

---

## Client

A Company that has established an active commercial relationship with Aurelia.

A Client may have multiple Contracts and Projects.

---

## Contract

A commercial agreement defining the terms under which Aurelia provides services to a Client.

A Contract may support one or more Projects.

---

## Project

A defined consulting engagement performed for a Client.

A Project has attributes such as:

* start date
* end date
* project manager
* status
* budget
* service
* business unit

A Client may have many Projects.

---

## Employee

A person providing services or internal work for Aurelia.

Employees may include:

* consultants
* project managers
* engineers
* analysts
* sales staff
* finance staff
* operations staff

---

## Skill

A capability associated with an Employee.

Examples:

* SQL
* Python
* Azure
* Snowflake
* Power BI
* Project Management
* Business Analysis

Employees may have multiple Skills and Skills may belong to multiple Employees.

---

## Resource Allocation

A planned assignment of an Employee to a Project for a defined period.

An allocation represents planned work rather than actual hours worked.

---

## Capacity

The amount of working time an Employee has available during a defined period.

Capacity is used when comparing workforce availability with planned demand.

---

## Timesheet Entry

Actual time recorded by an Employee against a Project or internal activity.

Timesheets represent actual work.

This is distinct from Resource Allocation, which represents planned work.

---

## Invoice

A financial document requesting payment from a Client for services or other billable activity.

One Invoice contains one or more Invoice Lines.

---

## Payment

Money received from a Client.

Payments may settle one or more invoices depending on the finance process.

---

## GL Account

An account within Aurelia's Chart of Accounts used to classify accounting transactions.

Examples:

* Cash
* Accounts Receivable
* Consulting Revenue
* Labor Cost
* Travel Expense

---

## GL Entry

An accounting transaction posted against one or more GL Accounts.

---

## Cost Center

An organizational structure used to associate expenses with responsible organizational areas.

---

## Business Unit

A higher-level organizational structure used for management and financial reporting.

---

# 5. Important Business Relationships

```text
Company 1 ─────── * Contact

Company 1 ─────── * Opportunity

Client 1 ──────── * Contract

Client 1 ──────── * Project

Contract 1 ────── * Project

Project 1 ─────── * Milestone

Employee * ────── * Skill

Employee 1 ────── * Resource Allocation

Project 1 ─────── * Resource Allocation

Employee 1 ────── * Timesheet Entry

Project 1 ─────── * Timesheet Entry

Client 1 ──────── * Invoice

Invoice 1 ─────── * Invoice Line

Invoice * ─────── * Payment

GL Account 1 ──── * GL Entry
```

---

# 6. Planned vs Actual

Aurelia deliberately separates planning information from actual transactions.

## Planned

Examples:

* Project budget
* Resource allocation
* Employee capacity
* Sales forecast
* Finance forecast

## Actual

Examples:

* Timesheet hours
* Labor cost
* Invoice amount
* Payment
* GL transaction

This separation allows analytics such as:

```text
Budget vs Actual Cost

Planned Hours vs Actual Hours

Resource Demand vs Capacity

Forecast Revenue vs Actual Revenue
```

---

# 7. System-of-Record Principle

The same real-world concept may appear in multiple systems.

For example:

```text
HubSpot Company
      ↓
Operations Client
      ↓
Finance Customer
      ↓
Analytics Client
```

These records are related but are not assumed to have identical technical identifiers.

Cross-system identifiers and mappings will be maintained explicitly.

---

# 8. Modeling Principle

This business-domain model is intentionally independent of physical database implementation.

The next modeling stages will progressively translate it into:

```text
Business Domain Model
        ↓
Conceptual ERD
        ↓
Logical Data Model
        ↓
Physical PostgreSQL Model
        ↓
Source Data
        ↓
Snowflake RAW
        ↓
dbt Models
        ↓
Dimensional Model
```

This prevents database design decisions from prematurely defining the business model.
