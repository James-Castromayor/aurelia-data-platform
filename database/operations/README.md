# Aurelia PostgreSQL Operational Source System

## Overview

This folder contains the PostgreSQL operational source system for the **Aurelia Enterprise Cloud Data & Analytics Platform**.

The database represents the transactional and operational systems of a fictional professional services and consulting organization.

It provides operational data covering:

- Organizational structure
- Employees and skills
- Clients
- Contracts
- Projects and milestones
- Resource planning
- Employee capacity
- Timesheets
- Project budgets
- Invoicing
- Payments
- General ledger transactions

This PostgreSQL database acts as one of the primary operational source systems for the broader Aurelia data platform.

All data used by the project is fictional and synthetically generated.

No employer, client, or production data is used.

---

# Database Architecture

## Database

```text
aurelia_operations
```

## Primary Schema

```text
operations
```

The PostgreSQL database represents the **operational source layer** of Aurelia.

The broader target architecture is:

```text
Operational Source Systems
        │
        ├── PostgreSQL Operations
        └── HubSpot CRM
                │
                ▼
        n8n / REST APIs / Python
                │
                ▼
        Azure Landing / Storage
                │
                ▼
             Snowflake
                │
       ┌────────┼────────┐
       ▼        ▼        ▼
      RAW    STAGING  ANALYTICS
                │
                ▼
               dbt
                │
                ▼
       Dimensional Models
                │
                ▼
            Power BI
```

The PostgreSQL database is intentionally designed as a **normalized transactional system**.

Dimensional models such as facts and dimensions are not created directly in this database.

Those models will be introduced later in the analytical layers of the Aurelia platform.

---

# Operational Domains

The database is divided logically into several business domains.

```text
Organization
    │
    ├── Business Units
    ├── Cost Centers
    ├── Employees
    └── Skills

Commercial
    │
    ├── Clients
    ├── Contracts
    └── Projects

Delivery
    │
    ├── Projects
    └── Project Milestones

Resource Management
    │
    ├── Employee Capacity
    ├── Resource Allocation
    └── Timesheets

Project Finance
    │
    └── Project Budgets

Billing
    │
    ├── Invoices
    ├── Invoice Lines
    ├── Payments
    └── Payment Allocations

Finance
    │
    ├── GL Accounts
    ├── GL Journals
    └── GL Entries
```

---

# Organization

The organizational hierarchy is represented primarily through:

```text
business_unit
      │
      ▼
cost_center
      │
      ▼
employee
```

A business unit represents a major organizational function.

Examples include:

- Data & Analytics
- Cloud Engineering
- Software Engineering
- Business Consulting
- Managed Services

A cost center represents a more specific organizational or financial grouping within a business unit.

Employees are assigned to both a business unit and a cost center.

---

# Employee Skills

Employee skills use a many-to-many relationship.

```text
employee
    │
    ▼
employee_skill
    ▲
    │
  skill
```

An employee can have multiple skills.

A skill can belong to multiple employees.

The `employee_skill` bridge table stores additional relationship attributes such as:

- proficiency level
- years of experience

Example skills include:

- SQL
- Python
- Power BI
- Microsoft Azure
- Snowflake
- dbt
- PostgreSQL
- Apache Airflow
- .NET
- React
- DevOps
- Business Analysis

---

# Clients

The `client` table represents organizations purchasing consulting or professional services from Aurelia.

Example attributes include:

- client number
- client name
- country
- industry
- active status

The operational identifier is:

```text
client_id
```

The human-readable business identifier is:

```text
client_number
```

This follows the Aurelia naming convention:

```text
*_id      = operational database identifier

*_number  = business-facing identifier

*_key     = future analytical warehouse surrogate key
```

---

# Contracts

Contracts represent commercial agreements with clients.

Relationship:

```text
client
   │
   ▼
contract
```

A client may have multiple contracts.

Contracts contain information such as:

- contract number
- contract name
- contract type
- start date
- end date
- contract value
- currency
- active status

---

# Projects

Projects represent consulting or delivery engagements.

Relationship:

```text
client
   │
   ├─────────────┐
   ▼             ▼
contract       project
   │             ▲
   └─────────────┘
```

Projects may reference:

- client
- contract
- service
- project manager

Typical project attributes include:

- project number
- project name
- project status
- start date
- end date
- billable status
- active status

The project manager references an employee record.

---

# Project Milestones

Project milestones represent significant delivery checkpoints.

```text
project
   │
   ▼
project_milestone
```

A project may contain multiple milestones.

Milestone attributes include:

- milestone name
- status
- planned completion date
- actual completion date

---

# Services

The `service` reference table identifies the type of consulting or professional service delivered by a project.

Example services include:

```text
Data & Analytics
Cloud Consulting
Software Engineering
Business Transformation
Managed Services
```

Projects reference a service through `service_id`.

---

# Resource Planning

Resource planning is modeled using two important operational concepts:

```text
Capacity
Allocation
```

These represent different business questions.

## Employee Capacity

```text
employee_capacity
```

Capacity answers:

> How many hours is an employee available to work?

The grain is approximately:

```text
Employee + Work Date
```

Example:

```text
Employee: EMP-0025
Date:     2026-03-10
Capacity: 8 hours
```

---

## Resource Allocation

```text
resource_allocation
```

Allocation answers:

> How many hours are we planning for an employee to spend on a project?

The grain is approximately:

```text
Employee + Project + Planning Week
```

Example:

```text
Employee:        EMP-0025
Project:         PRJ-0042
Planning Week:   2026-03-09
Allocated Hours: 32
```

The combination of capacity and allocation enables future analytics such as:

- available capacity
- planned utilization
- employee over-allocation
- employee under-allocation
- workforce planning
- project staffing requirements

---

# Timesheets

The `timesheet_entry` table represents actual hours worked.

Conceptually:

```text
Capacity
   =
AVAILABLE

Allocation
   =
PLANNED

Timesheet
   =
ACTUAL
```

This distinction is fundamental to the Aurelia resource analytics model.

Example:

```text
Employee capacity: 40 hours

Planned allocation: 36 hours

Actual timesheet:   32 hours
```

This allows future calculations such as:

```text
Planned Utilization
Actual Utilization
Allocation Variance
Capacity Variance
```

The timesheet grain is approximately:

```text
Employee
+
Project / Activity
+
Work Date
```

Timesheet entries contain attributes such as:

- employee
- project
- service
- work date
- hours worked
- activity
- description
- billable status
- approval status

---

# Project Budget

Project financial planning is represented by:

```text
project_budget
```

Budgets are stored by:

```text
Project
+
Budget Version
+
Budget Category
```

Example budget versions:

```text
BASELINE
FORECAST-01
```

Example budget categories:

```text
LABOR
CLOUD
SOFTWARE
TRAVEL
```

This design enables future comparisons such as:

```text
Baseline Budget
        vs
Forecast Budget
        vs
Actual Cost
```

These comparisons will later support project profitability and financial analytics.

---

# Invoicing

Billing is represented by two primary tables:

```text
invoice
    │
    ▼
invoice_line
```

## Invoice

The grain of `invoice` is:

```text
One customer invoice
```

An invoice references:

- client
- project

Typical attributes include:

- invoice number
- invoice date
- due date
- currency
- status
- total amount

---

## Invoice Line

The grain of `invoice_line` is:

```text
One individual line within an invoice
```

Invoice lines contain:

- line number
- description
- quantity
- unit price
- line amount

Relationship:

```text
Invoice
   │
   ├── Line 1
   ├── Line 2
   └── Line 3
```

The sum of invoice lines should reconcile to the invoice total.

---

# Payments

Payments are represented by:

```text
payment
```

However, payments are not directly tied one-to-one to invoices.

Instead:

```text
payment
    │
    ▼
payment_allocation
    ▲
    │
 invoice
```

This creates a many-to-many relationship.

The design supports scenarios where:

- one payment settles multiple invoices
- one invoice receives multiple payments
- an invoice is partially paid

The `payment_allocation` table stores the amount applied between a payment and an invoice.

Example:

```text
Invoice
$40,000
   │
   ├── Payment A = $25,000
   └── Payment B = $15,000
```

This enables future calculations such as:

```text
Invoice Amount
-
Allocated Payments
=
Outstanding Balance
```

---

# General Ledger

A simplified general ledger is included to provide financial transaction data.

The main tables are:

```text
gl_account
gl_journal
gl_entry
```

Relationship:

```text
gl_journal
    │
    ▼
gl_entry
    │
    ▼
gl_account
```

---

## GL Accounts

The `gl_account` table contains the chart of accounts.

Example accounts include:

```text
1000  Cash
1100  Accounts Receivable
2000  Accounts Payable
3000  Retained Earnings
4000  Consulting Revenue
5000  Labor Cost
5100  Cloud Cost
5200  Software Cost
5300  Travel Cost
```

Account types include:

```text
ASSET
LIABILITY
EQUITY
REVENUE
EXPENSE
```

---

## GL Journals

A journal represents a financial transaction or accounting event.

Example:

```text
JE-00001
Customer Invoice
```

A journal contains one or more GL entries.

---

## GL Entries

GL entries represent individual debit and credit lines.

Example invoice journal:

```text
Accounts Receivable   Debit   $40,000

Consulting Revenue    Credit  $40,000
```

GL entries may optionally reference:

- project
- cost center

This allows future profitability analysis by project and organizational structure.

---

# Journal Balancing

Each accounting journal should satisfy:

```text
Total Debit
=
Total Credit
```

The operational table constraints validate individual debit and credit values.

Whole-journal balancing is validated using SQL queries.

Example:

```sql
SELECT
    j.journal_number,
    SUM(e.debit_amount) AS total_debit,
    SUM(e.credit_amount) AS total_credit
FROM operations.gl_journal j
JOIN operations.gl_entry e
    ON j.gl_journal_id = e.gl_journal_id
GROUP BY
    j.gl_journal_id,
    j.journal_number
HAVING
    SUM(e.debit_amount)
    <> SUM(e.credit_amount);
```

A correctly balanced dataset should return:

```text
0 rows
```

---

# Database Scripts

The operational database is defined through version-controlled SQL scripts.

```text
database/
└── operations/
    ├── 000_database_setup.sql
    ├── 001_reference_tables.sql
    ├── 002_employees.sql
    ├── 003_clients_contracts.sql
    ├── 004_projects.sql
    ├── 005_resource_planning.sql
    ├── 006_timesheets.sql
    ├── 007_project_budget.sql
    ├── 008_invoicing.sql
    ├── 009_payments.sql
    ├── 010_general_ledger.sql
    ├── 011_indexes_views.sql
    ├── 012_validation_queries.sql
    ├── README.md
    │
    └── seed/
        └── generate_synthetic_data.py
```

Scripts execute in numerical dependency order.

```text
001
 ↓
002
 ↓
003
 ↓
...
 ↓
011
```

---

# Initial Database Setup

`000_database_setup.sql` is intended for initial PostgreSQL provisioning.

It is separate from the normal schema rebuild process.

It is responsible for initial objects such as:

```text
aurelia_operations database
aurelia_app application role
```

The normal rebuild assumes these already exist.

---

# Reference Data

Reference and master data is managed through SQL rather than generated randomly.

Examples include:

- business units
- cost centers
- services
- skills
- GL accounts

Reference data is required before synthetic transactional data can be generated.

The dependency is:

```text
Reference Tables
      ↓
Reference Records
      ↓
Synthetic Generator
      ↓
Transactional Data
```

This keeps stable business classifications separate from generated transactional data.

---

# Synthetic Data

Synthetic operational data is generated by:

```text
database/operations/seed/generate_synthetic_data.py
```

The generator uses Python libraries including:

```text
Faker
psycopg
python-dotenv
```

The generator uses deterministic random seeds where appropriate so the dataset can be recreated consistently.

The generated dataset includes approximately:

```text
150 employees
70 clients
120 contracts
200 projects
100,000+ employee capacity records
thousands of resource allocations
tens of thousands of timesheet entries
project budgets
invoices
invoice lines
payments
payment allocations
general ledger journals
general ledger entries
```

The dataset contains enough volume to support:

- SQL practice
- index testing
- data engineering
- ELT development
- dimensional modeling
- dbt transformations
- BI reporting
- project profitability analytics
- resource utilization analytics

---

# Synthetic Business Scenarios

The synthetic dataset is designed to support realistic analytical scenarios.

Examples include:

```text
Resource over-allocation
Resource under-utilization
Planned vs actual hours
Project budget variance
Partial invoice payments
Outstanding receivables
Client billing analysis
Project financial performance
```

These scenarios will become increasingly important when the data reaches the analytical layers of the platform.

---

# Python Environment

Create the Python virtual environment from the repository root:

```powershell
python -m venv .venv
```

Activate it:

```powershell
.\.venv\Scripts\Activate.ps1
```

Install dependencies:

```powershell
pip install -r requirements.txt
```

Dependencies are defined in:

```text
requirements.txt
```

Example:

```text
faker
psycopg[binary]
python-dotenv
```

The virtual environment is excluded from Git:

```text
.venv/
```

---

# Environment Configuration

Local database credentials are stored in:

```text
.env
```

The `.env` file must never be committed to Git.

A safe template is stored in:

```text
.env.example
```

Example:

```text
DB_HOST=localhost
DB_PORT=5432
DB_NAME=aurelia_operations

DB_ADMIN_USER=postgres
DB_ADMIN_PASSWORD=your_admin_password

DB_USER=aurelia_app
DB_PASSWORD=your_application_password
```

The repository `.gitignore` should contain:

```text
.venv/
.env
```

---

# PostgreSQL Security Model

The environment separates administrative and application responsibilities.

```text
PostgreSQL
    │
    ├── postgres
    │      │
    │      └── Administrative / deployment operations
    │
    └── aurelia_app
           │
           └── Application / transactional operations
```

---

## postgres

The PostgreSQL administrative account is used for operations such as:

```text
CREATE
DROP
ALTER
GRANT
schema deployment
database administration
```

It should not be used by normal applications.

---

## aurelia_app

The dedicated application account is:

```text
aurelia_app
```

It receives the permissions required for operational workloads:

```text
SELECT
INSERT
UPDATE
DELETE
```

It also receives the required sequence permissions for PostgreSQL identity columns.

The Python synthetic-data generator connects using the application account rather than the PostgreSQL administrator.

This demonstrates the principle of:

```text
Least Privilege
```

Applications receive only the permissions required to perform their responsibilities.

---

# Database Permissions

The application role receives access similar to:

```sql
GRANT CONNECT
ON DATABASE aurelia_operations
TO aurelia_app;

GRANT USAGE
ON SCHEMA operations
TO aurelia_app;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES
IN SCHEMA operations
TO aurelia_app;

GRANT USAGE, SELECT, UPDATE
ON ALL SEQUENCES
IN SCHEMA operations
TO aurelia_app;
```

Default privileges are also configured so future objects created by the deployment role can automatically receive appropriate application permissions.

---

# Database Rebuild

The operational environment can be rebuilt using:

```powershell
.\scripts\rebuild_operations_db.ps1
```

The rebuild script provides a repeatable development workflow.

Conceptually:

```text
Start
  │
  ▼
Load Environment
  │
  ▼
Check PostgreSQL
  │
  ▼
Check Python Environment
  │
  ▼
Drop operations Schema
  │
  ▼
Recreate operations Schema
  │
  ▼
Create Reference Tables
  │
  ▼
Create Operational Tables
  │
  ▼
Create Finance Tables
  │
  ▼
Create Indexes
  │
  ▼
Create Views
  │
  ▼
Apply Permissions
  │
  ▼
Generate Synthetic Data
  │
  ▼
Validate Row Counts
  │
  ▼
Operational Database Ready
```

---

# Fail-Fast Deployment

The rebuild process uses fail-fast behavior.

For PostgreSQL:

```text
ON_ERROR_STOP=1
```

causes the build to stop when an SQL error occurs.

PowerShell uses:

```powershell
$ErrorActionPreference = "Stop"
```

This prevents the build from silently continuing after an error.

Conceptually:

```text
Build Step
    │
    ├── Success → Continue
    │
    └── Failure → STOP
```

This reduces the risk of ending with a partially deployed database.

---

# Reproducibility

A major objective of Phase 2 is reproducibility.

Instead of manually creating database objects, the environment is represented as code.

```text
Git Repository
      │
      ▼
SQL Scripts
      │
      ▼
PowerShell Rebuild
      │
      ▼
Python Synthetic Generator
      │
      ▼
Recreated PostgreSQL Environment
```

Another developer should be able to clone the repository, configure the environment, and rebuild the operational source system without manually recreating tables.

---

# Indexing Strategy

Indexes are created for common filtering, joining, and analytical access patterns.

Examples include:

```text
employee → business_unit

employee → cost_center

contract → client

project → client

project → contract
```

Time-based operational indexes include:

```text
(employee_id, planning_week)

(project_id, planning_week)

(employee_id, work_date)

(project_id, work_date)

(client_id, invoice_date)

(client_id, payment_date)
```

---

# Composite Index Example

An example composite index is:

```sql
CREATE INDEX idx_timesheet_employee_date
ON operations.timesheet_entry (
    employee_id,
    work_date
);
```

This is useful for queries such as:

```sql
SELECT *
FROM operations.timesheet_entry
WHERE employee_id = 25
  AND work_date BETWEEN DATE '2026-01-01'
                    AND DATE '2026-06-30';
```

The index is ordered approximately as:

```text
employee_id
    │
    └── work_date
```

This makes it efficient to find a specific employee and then search that employee's records by date.

---

# Query Plan Analysis

PostgreSQL query execution can be inspected using:

```sql
EXPLAIN ANALYZE
```

Example:

```sql
EXPLAIN ANALYZE

SELECT *
FROM operations.timesheet_entry
WHERE employee_id = 25
  AND work_date BETWEEN DATE '2026-01-01'
                    AND DATE '2026-06-30';
```

A possible execution plan is:

```text
Bitmap Heap Scan
    │
    └── Bitmap Index Scan
            │
            └── idx_timesheet_employee_date
```

This means PostgreSQL:

1. Searches the index.
2. Identifies matching row locations.
3. Retrieves the full rows from the table.

PostgreSQL may choose different access strategies depending on estimated query cost.

Examples include:

```text
Seq Scan
Index Scan
Bitmap Index Scan
Bitmap Heap Scan
```

Having an index does not guarantee PostgreSQL will use it.

The query optimizer chooses the execution strategy it estimates to be cheapest.

---

# SQL Validation

Validation and analytical queries are stored in:

```text
012_validation_queries.sql
```

The validation queries demonstrate several important SQL patterns.

---

## Row Counts

Used to confirm expected data volumes.

Example:

```sql
SELECT COUNT(*)
FROM operations.employee;
```

---

## Joins

Used to combine related operational entities.

Example:

```text
Client
  +
Project
```

or:

```text
Employee
  +
Resource Allocation
```

---

## Aggregation

Used to calculate business metrics such as:

```text
Actual hours by project
Planned hours by employee
Invoices by client
Outstanding balances
```

---

## WHERE vs HAVING

`WHERE` filters individual rows before aggregation.

```text
Rows
 ↓
WHERE
 ↓
GROUP BY
 ↓
Aggregation
```

`HAVING` filters aggregated groups.

```text
Rows
 ↓
GROUP BY
 ↓
Aggregation
 ↓
HAVING
```

Example:

```sql
HAVING SUM(allocated_hours) > 40
```

This can identify employees whose weekly planned allocation exceeds 40 hours.

---

# Common Table Expressions

CTEs use:

```sql
WITH
```

Example:

```sql
WITH project_hours AS (
    SELECT
        project_id,
        SUM(hours_worked) AS actual_hours
    FROM operations.timesheet_entry
    GROUP BY project_id
)

SELECT *
FROM project_hours;
```

A CTE creates a named query result that exists for the duration of the SQL statement.

It does not create a permanent database table.

CTEs can improve:

- query readability
- logical decomposition
- maintainability
- complex analytical SQL development

---

# Window Functions

The validation queries also demonstrate SQL window functions.

Example:

```sql
RANK() OVER (
    ORDER BY actual_hours DESC
)
```

Window functions can calculate values across related rows without collapsing the result set in the same way as a normal `GROUP BY`.

They are commonly used for:

- ranking
- running totals
- moving averages
- previous/next row comparison
- partitioned calculations

These patterns will become important in later analytics engineering work.

---

# Invoice Balance Analysis

Payments can be allocated partially against invoices.

Outstanding balances can therefore be calculated as:

```text
Invoice Total
-
Allocated Payments
=
Outstanding Amount
```

Example:

```sql
SELECT
    i.invoice_number,
    i.total_amount,
    COALESCE(
        SUM(pa.allocated_amount),
        0
    ) AS paid_amount,
    i.total_amount
        - COALESCE(
            SUM(pa.allocated_amount),
            0
        ) AS outstanding_amount
FROM operations.invoice i
LEFT JOIN operations.payment_allocation pa
    ON i.invoice_id = pa.invoice_id
GROUP BY
    i.invoice_id,
    i.invoice_number,
    i.total_amount;
```

---

# Resource Over-Allocation

Resource allocation can be compared across planning weeks.

Example business rule:

```text
Weekly Allocation > 40 Hours
=
Potential Over-Allocation
```

Example SQL:

```sql
SELECT
    employee_id,
    planning_week,
    SUM(allocated_hours) AS allocated_hours
FROM operations.resource_allocation
GROUP BY
    employee_id,
    planning_week
HAVING
    SUM(allocated_hours) > 40;
```

This provides a foundation for future resource-management dashboards.

---

# Operational Views

The database contains operational views that simplify common queries.

Examples include:

```text
operations.vw_project_summary

operations.vw_employee_resource_summary
```

`vw_project_summary` combines project information with related client, service, and project manager information.

`vw_employee_resource_summary` combines employees with organizational information such as business units and cost centers.

Views provide reusable query abstractions without duplicating underlying data.

---

# Naming Standards

The PostgreSQL operational model uses:

```text
lower_snake_case
```

Examples:

```text
employee
employee_skill
resource_allocation
project_budget
payment_allocation
```

Column examples:

```text
employee_id
project_id
work_date
allocated_hours
created_at
```

---

# Identifier Standards

Aurelia distinguishes between operational identifiers, business identifiers, and future analytical warehouse keys.

## Operational IDs

```text
employee_id
project_id
client_id
invoice_id
```

These are PostgreSQL-generated technical identifiers.

---

## Business Identifiers

```text
employee_number
project_number
client_number
invoice_number
contract_number
```

These represent identifiers visible to business processes.

---

## Future Warehouse Keys

Future analytical models may introduce:

```text
employee_key
project_key
client_key
```

These will be warehouse surrogate keys and should not be confused with operational database IDs.

---

# Data Types

Financial values use:

```text
NUMERIC
```

rather than floating-point types.

Examples:

```text
NUMERIC(18,2)
NUMERIC(6,2)
NUMERIC(5,2)
```

Python therefore uses:

```text
Decimal
```

for financial calculations where PostgreSQL `NUMERIC` values are involved.

This avoids floating-point precision problems in financial data.

---

# Python SQL Parameters

The Python generator uses parameterized SQL.

Example:

```python
cur.execute(
    """
    SELECT *
    FROM operations.employee
    WHERE employee_id = %s
    """,
    (employee_id,)
)
```

The `%s` is a database parameter placeholder.

It is not a random-value generator.

Values are supplied separately through the Python parameter tuple.

Parameterized SQL provides:

- safe value handling
- correct Python/PostgreSQL type conversion
- protection against SQL injection
- cleaner SQL construction

---

# Conflict Handling

The generator may use PostgreSQL conflict handling.

Example:

```sql
ON CONFLICT (
    employee_id,
    work_date
)
DO NOTHING;
```

This means:

> If inserting the row would violate the specified unique constraint, skip that row instead of failing the entire operation.

PostgreSQL can also support UPSERT behavior through:

```sql
ON CONFLICT (...)
DO UPDATE
```

when appropriate.

---

# Development Principles

The Phase 2 implementation follows several engineering principles.

## Reproducibility

The environment can be recreated from version-controlled scripts.

## Least Privilege

Administrative and application responsibilities use separate PostgreSQL roles.

## Fail Fast

Deployment stops when SQL or Python execution fails.

## Referential Integrity

Foreign keys enforce relationships between operational entities.

## Data Quality

Constraints enforce valid operational values where appropriate.

## Synthetic Data

No real employer or customer data is used.

## Separation of Concerns

Reference data, schema definitions, generated transactions, validation queries, and rebuild automation have separate responsibilities.

## Version Control

Database implementation is stored in Git and developed through a feature branch.

---

# Technology Stack

Phase 2 currently uses:

```text
PostgreSQL 18
SQL
Python
psycopg
Faker
python-dotenv
PowerShell
Git
GitHub
VS Code
```

Future phases will extend the platform with technologies such as:

```text
HubSpot
n8n
REST APIs
Azure
Snowflake
dbt
Power BI
PySpark
Microsoft Fabric
AI / RAG
```

---

# Phase 2 Learning Outcomes

This phase demonstrates practical experience with:

- PostgreSQL installation and configuration
- relational database modeling
- normalized operational models
- primary keys
- foreign keys
- unique constraints
- check constraints
- identity columns
- many-to-many relationships
- reference data
- transactional data
- financial data modeling
- resource planning data modeling
- indexes
- composite indexes
- PostgreSQL query optimization
- `EXPLAIN ANALYZE`
- joins
- aggregations
- CTEs
- window functions
- Python/PostgreSQL integration
- parameterized SQL
- Python `Decimal`
- synthetic data generation
- environment variables
- application database roles
- least-privilege access
- automated database rebuilds
- fail-fast deployment
- Git-based database development

---

# Role of PostgreSQL in Aurelia

PostgreSQL is an **operational source system**, not the final analytical platform.

Its job is to generate and maintain transactional business data.

The future data-engineering flow will be:

```text
Operational PostgreSQL
        │
        ▼
Ingestion / Integration
        │
        ▼
Azure
        │
        ▼
Snowflake RAW
        │
        ▼
Snowflake STAGING
        │
        ▼
dbt
        │
        ▼
Snowflake ANALYTICS
        │
        ▼
Dimensional / Star Schema
        │
        ▼
Power BI
```

This separation reflects a common enterprise architecture:

```text
OLTP
Operational System
        │
        ▼
Data Engineering
        │
        ▼
OLAP
Analytical System
```

PostgreSQL represents the OLTP side.

Snowflake and the future analytical models will represent the OLAP side.

---

# Portfolio Purpose

This module is part of the broader **Aurelia Enterprise Cloud Data & Analytics Platform** portfolio.

The portfolio is designed to demonstrate end-to-end capabilities across:

```text
Operational Systems
        ↓
Integration
        ↓
Cloud Data Engineering
        ↓
Analytics Engineering
        ↓
Business Intelligence
        ↓
Automation
        ↓
Application Development
        ↓
AI / RAG
```

Phase 2 establishes the operational data foundation required by the later phases.

The objective is not merely to demonstrate SQL syntax, but to show how a realistic operational system can be:

- modeled
- generated
- secured
- queried
- validated
- automated
- version controlled
- documented
- prepared for downstream cloud data engineering