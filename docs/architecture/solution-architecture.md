# Aurelia Solution Architecture v1

## 1. Purpose

This document defines the initial technical architecture for the Aurelia Enterprise Cloud Data & Analytics Platform.

The architecture is designed to integrate CRM, operational, finance, file-based, and API-based data into a governed analytical platform.

---

## 2. Architecture Goals

The solution should:

* Integrate multiple business systems.
* Preserve clear system ownership.
* Separate operational workloads from analytical workloads.
* Support incremental data processing.
* Provide reliable and testable transformations.
* Minimize cloud cost.
* Remain understandable and maintainable.
* Support future BI, automation, and AI use cases.

---

## 3. High-Level Architecture

```text
                       SOURCE SYSTEMS

      HubSpot CRM          Operations App        Finance Source
           │                    │                     │
           │               PostgreSQL                 │
           │                    │                     │
           ├──────────────┬─────┴──────┬─────────────┤
           │              │            │             │
           ▼              ▼            ▼             ▼
       REST APIs       Webhooks     CSV / Excel   External APIs
           │              │            │             │
           └──────────────┴──────┬─────┴─────────────┘
                                 │
                                 ▼
                         INGESTION LAYER
                           Python + n8n
                                 │
                         Validation / Logs
                                 │
                                 ▼
                           AZURE LANDING
                         Blob Storage / ADLS
                                 │
                                 ▼
                              SNOWFLAKE
                                 │
                              RAW Layer
                                 │
                                 ▼
                                dbt
                                 │
               ┌─────────────────┼─────────────────┐
               ▼                 ▼                 ▼
            STAGING         INTERMEDIATE       ANALYTICS
                                                   │
                                         Dimensional Models
                                                   │
                         ┌─────────────────────────┼────────────────────────┐
                         ▼                         ▼                        ▼
                     Power BI                  Data APIs                AI/RAG
```

---

## 4. Source Systems

### HubSpot CRM

HubSpot is the system of record for:

* Companies
* Contacts
* Deals
* Opportunity stages
* Sales pipeline

Data will be accessed through approved API capabilities.

### Aurelia Operations Platform

The Operations Platform supports:

* Clients
* Projects
* Employees
* Resource allocations
* Timesheets
* Budgets
* Milestones

Its transactional database is PostgreSQL.

### Synthetic Finance Source

The finance source simulates ERP concepts including:

* Customers
* Invoices
* Payments
* Accounts receivable
* General ledger
* Costs
* Budgets
* Forecasts

### File and External Sources

Additional source data may arrive from:

* CSV
* Excel
* REST APIs
* Reference data
* Business documents

---

## 5. Ingestion Layer

The ingestion layer uses Python and n8n.

### Python

Python is responsible for engineering-oriented ingestion tasks such as:

* API extraction
* Pagination
* Authentication
* File processing
* Validation
* Retry logic
* Logging
* Batch metadata
* Incremental extraction

### n8n

n8n is responsible for workflow-oriented integration such as:

* Webhook processing
* Scheduled workflows
* Closed-Won automation
* Notifications
* API orchestration
* Simple business workflows

Python and n8n serve different purposes and should not duplicate unnecessary logic.

---

## 6. Azure Landing Layer

Azure Blob Storage or equivalent ADLS capabilities provide the cloud landing zone.

The landing layer stores source-aligned data before analytical transformation.

Example structure:

```text
landing/
├── hubspot/
│   ├── companies/
│   ├── contacts/
│   └── deals/
├── operations/
│   ├── projects/
│   ├── employees/
│   └── timesheets/
├── finance/
│   ├── invoices/
│   ├── payments/
│   └── gl/
└── reference/
```

Where practical, landed data should remain close to the source representation.

The landing zone allows data to be retained independently of downstream warehouse processing.

---

## 7. Snowflake RAW Layer

Snowflake receives landed source data.

The RAW layer preserves source-oriented structures with limited transformation.

Typical metadata may include:

* `_source_system`
* `_source_file`
* `_batch_id`
* `_ingested_at`

The RAW layer provides a reproducible input for downstream analytics engineering.

---

## 8. dbt Transformation Layers

### Staging

Staging models standardize source data.

Typical responsibilities:

* Rename columns
* Cast data types
* Standardize dates
* Normalize text
* Handle basic null values
* Remove obvious duplicates

Example:

```text
stg_hubspot__deals
stg_operations__projects
stg_finance__invoices
```

### Intermediate

Intermediate models implement reusable business logic.

Examples:

```text
int_employee_capacity
int_project_labor_cost
int_invoice_payment_status
int_sales_pipeline
```

### Analytics

Analytics models provide business-ready facts and dimensions.

Examples:

```text
dim_employee
dim_client
dim_project
dim_date

fact_timesheet
fact_sales_pipeline
fact_invoice
fact_payment
fact_project_financial
```

---

## 9. Consumption Layer

### Power BI

Power BI consumes governed analytical models rather than recreating core business logic directly from raw source systems.

### Data APIs

Selected analytical information may be exposed through controlled APIs where required by applications or integrations.

### AI / RAG

AI capabilities will consume:

* Governed analytical information
* Approved business documents

AI will initially operate with read-only access.

---

## 10. Core Architectural Principles

### Separation of Concerns

Operational systems process business transactions.

The analytical platform processes reporting and analytical workloads.

### System of Record

Each important business entity should have a clearly defined authoritative source.

### ELT Preference

Data should generally be landed and loaded before extensive business transformations are applied.

### Incremental Processing

Full reloads should not be used where incremental processing is practical and justified.

### Governed Metrics

Important business calculations should be implemented in controlled analytical models rather than repeatedly recreated by downstream users.

### Cost Awareness

Cloud resources should be created only where they provide meaningful learning or architectural value.

### Security by Design

Secrets, access controls, and least-privilege principles should be considered throughout implementation.

---

## 11. Production Evolution

A production implementation could extend this architecture with:

* Separate DEV / TEST / PROD environments
* Private networking
* Managed identities
* Azure Key Vault
* Enterprise monitoring
* Formal orchestration
* Disaster recovery
* High availability
* Infrastructure as Code
* Deployment approvals
* Enterprise data cataloging
* Formal data governance

These controls are documented conceptually where implementing them would add unnecessary portfolio cost or complexity.
