# Phase 3 — HubSpot CRM Source

## Overview

Phase 3 established HubSpot CRM as the customer-facing sales source for the Aurelia Enterprise Cloud Data & Analytics Platform.

The purpose of HubSpot in Aurelia is to represent the commercial lifecycle before operational delivery begins.

High-level flow:

HubSpot CRM
→ Company
→ Contact
→ Deal
→ Closed Won
→ Future Integration
→ PostgreSQL Operations
→ Contract
→ Project
→ Resource Planning
→ Timesheets
→ Billing
→ Payments

HubSpot remains the sales system, while PostgreSQL Operations remains the operational delivery system.

---

## CRM Objects

Aurelia uses three primary HubSpot objects:

### Companies

Companies represent customer or prospect organizations.

Examples:

- Northstar Manufacturing
- Meridian Financial Group
- Pacific Crest Logistics
- Solara Energy Solutions
- BluePeak Healthcare
- Vertex Retail Group
- Horizon Property Partners
- NovaTech Industries

Custom Company properties:

- `aurelia_customer_status`
- `aurelia_client_number`

Customer Status values:

- Prospect
- Active Customer
- Former Customer

Operational Client Number stores the operational business identifier after a customer exists in the PostgreSQL operational system.

Example:

`CLI-0003`

---

## Contacts

Contacts represent individual stakeholders associated with Companies.

Examples:

- Sarah Chen — Chief Financial Officer
- Daniel Cruz — IT Director
- Emma Thompson — Director of Finance
- Oliver Bennett — Head of Data
- Liam Walker — Chief Operating Officer
- Sophie Martin — Digital Transformation Director
- Michael Reed — VP Finance
- Rachel Kim — Director of Analytics
- Ethan Clark — Head of Technology
- Amelia Wright — Finance Director
- Noah Taylor — Chief Technology Officer
- Grace Lee — Data Engineering Manager

Contacts are associated with Companies using native HubSpot associations.

No custom Contact properties were required.

---

## Deals

Deals represent sales opportunities.

Custom Deal properties:

- `aurelia_service_type`
- `aurelia_project_number`

Service Type values:

- Data & Analytics
- Cloud Transformation
- Business Systems
- Digital Automation
- Advisory

Operational Project Number stores the operational project business identifier after the Closed-Won opportunity is handed off.

Example:

`PRJ-2026-021`

---

## Aurelia Sales Pipeline

The HubSpot deal pipeline is named:

`Aurelia Sales Pipeline`

Stages:

| Stage | Probability |
|---|---:|
| Qualified | 20% |
| Discovery | 40% |
| Proposal | 60% |
| Negotiation | 80% |
| Closed Won | 100% |
| Closed Lost | 0% |

Lead and Prospect were not implemented as Deal stages.

Prospecting occurs before an opportunity becomes a Deal.

Closed Won represents the conceptual trigger for operational handoff.

---

## Synthetic CRM Data

The repository contains reproducible synthetic CRM seed data under:

`hubspot/seed/`

Files:

- `companies.csv`
- `contacts.csv`
- `deals.csv`

All data is fictional and intended only for portfolio demonstration.

---

## Company Dataset

Eight Aurelia Companies were created.

Customer distribution:

- 5 Prospects
- 2 Active Customers
- 1 Former Customer

Existing operational Client Numbers were assigned only where appropriate.

Examples:

- Pacific Crest Logistics → `CLI-0003`
- BluePeak Healthcare → `CLI-0005`
- Horizon Property Partners → `CLI-0007`

---

## Deal Dataset

Ten synthetic Deals were created across the Aurelia Sales Pipeline.

Stage distribution:

- Qualified: 1
- Discovery: 2
- Proposal: 2
- Negotiation: 2
- Closed Won: 2
- Closed Lost: 1

Closed-Won examples:

### Pacific Crest Analytics Expansion

Company:

Pacific Crest Logistics

Operational Project Number:

`PRJ-2026-021`

### BluePeak Reporting Platform

Company:

BluePeak Healthcare

Operational Project Number:

`PRJ-2026-018`

---

## Associations

Native HubSpot associations are used instead of duplicating relationship fields.

Primary relationships:

Company
→ Contacts

Company
→ Deals

Example:

Northstar Manufacturing
→ Sarah Chen
→ Daniel Cruz
→ Northstar Data Modernization
→ Northstar Finance Automation

HubSpot Record IDs were used during imports to create reliable object associations.

Record IDs are technical identifiers specific to the HubSpot environment and are not portable business identifiers.

---

## Identifier Strategy

Aurelia intentionally separates technical identifiers, business identifiers, and future warehouse surrogate keys.

### HubSpot

HubSpot Record ID

Purpose:

CRM technical identifier.

---

### PostgreSQL Operations

Technical identifiers:

- `client_id`
- `project_id`

Business identifiers:

- `client_number`
- `project_number`

Examples:

- `CLI-0003`
- `PRJ-2026-021`

---

### Future Data Warehouse

Surrogate keys will use names such as:

- `client_key`
- `project_key`

These will be introduced in the dimensional warehouse layer.

---

## Cross-System Identifier Rule

The architecture does not attempt to make HubSpot Record IDs equal PostgreSQL IDs.

Instead:

HubSpot Record ID
→ CRM technical identity

PostgreSQL `*_id`
→ operational technical identity

`*_number`
→ business-facing cross-system identity

Future `*_key`
→ warehouse surrogate identity

This separation avoids tight coupling between source systems.

---

## Closed-Won Handoff Design

Closed Won represents the conceptual boundary between CRM and Operations.

Flow:

HubSpot Deal
→ Closed Won
→ Integration evaluates customer
→ Existing or new PostgreSQL Client
→ Contract
→ Project
→ Delivery

A future integration should retrieve:

- Company
- Deal
- associated Contacts
- Service Type
- Deal Amount
- Close Date

It can then determine whether an operational Client already exists.

Conceptually:

Closed Won
→ Does Operational Client Number exist?

If yes:
→ use existing Client

If no:
→ create Client

Then:

→ Contract
→ Project

After operational records are created, selected identifiers may be synchronized back to HubSpot.

Examples:

Company
→ Operational Client Number

Deal
→ Operational Project Number

---

## System Responsibility

### HubSpot CRM owns

- prospects
- customer-facing contacts
- sales opportunities
- deal stages
- deal amounts
- sales lifecycle
- Closed-Won event

### PostgreSQL Operations owns

- clients
- contracts
- projects
- employees
- resource planning
- employee capacity
- allocations
- timesheets
- budgets
- invoices
- payments
- financial operational records

HubSpot does not become an operational ERP system.

---

## API Authentication

A HubSpot Service Key was configured for system-to-system API access.

The real credential is stored locally in:

`.env`

Variable:

`HUBSPOT_ACCESS_TOKEN`

The real `.env` file is excluded from Git.

The repository contains only:

`.env.example`

Example:

`HUBSPOT_ACCESS_TOKEN=your_hubspot_service_key_here`

Secrets must never be committed to source control.

---

## API Connectivity

Basic HubSpot API connectivity was validated using PowerShell.

API objects successfully retrieved:

- Companies
- Contacts
- Deals

Example endpoint pattern:

`/crm/v3/objects/companies`

Properties can be explicitly requested to avoid retrieving unnecessary fields.

Example concepts tested:

- HTTP GET requests
- Bearer authentication
- JSON responses
- object properties
- Record IDs
- associations
- pagination metadata

---

## API Associations

A Company was queried with:

`associations=contacts,deals`

The response successfully returned Contact and Deal association IDs.

The associated records were then retrieved using their respective object endpoints.

This demonstrated that HubSpot represents objects and relationships separately.

Conceptually:

Company API
→ Contact association IDs
→ Contact API

Company API
→ Deal association IDs
→ Deal API

This relationship structure will be important when the CRM source is ingested into the analytics platform.

---

## Pagination

HubSpot does not necessarily return every record in a single request.

Pagination uses an `after` token.

Conceptually:

Request Page 1
→ records
→ `paging.next.after`
→ Request Page 2
→ continue until no next page exists

Reusable pagination logic will be implemented during the data ingestion phase rather than Phase 3.

---

## Rate Limits

API consumers must respect HubSpot request limits.

Production-quality integrations should:

- avoid unnecessary API calls
- detect HTTP 429 responses
- implement retries
- use appropriate backoff
- avoid hard-coded assumptions about API limits

This logic belongs in the reusable ingestion layer.

---

## Data Quality Lessons

Several source-system validation issues were encountered during setup.

### Synthetic Domains

Reserved `.example` domains were rejected by HubSpot's Company Domain validation.

Resolution:

The Company Domain field was removed rather than using potentially real internet domains.

---

### Synthetic Emails

Reserved synthetic email addresses were rejected by HubSpot email validation.

Resolution:

Email addresses were removed from the synthetic Contact dataset.

---

### Industry Values

HubSpot requires valid Industry option values.

For Northstar Manufacturing, the working value used was:

`ELECTRICAL/ELECTRONIC MANUFACTURING`

This demonstrates an important data-engineering principle:

Source-system reference values must conform to the source application's accepted domain values.

---

### Contact Associations

The initial Contact import created Contacts without reliable Company associations.

Resolution:

Company HubSpot Record IDs were added to the Contact seed file and used as the unique Company identifier during import.

This successfully established:

Company
→ Contact

associations.

---

### Deal Associations

Company names alone were insufficient as reliable unique identifiers during the Deal import.

Resolution:

HubSpot Company Record IDs were exported and used to associate Deals with existing Companies.

This successfully established:

Company
→ Deal

associations.

---

## Phase 3 Validation

The completed CRM source contains:

- 8 Aurelia Companies
- 12 Contacts
- 10 Deals
- configured Aurelia Sales Pipeline
- four required custom properties
- Company-to-Contact associations
- Company-to-Deal associations
- two Closed-Won Deals
- operational Client Number examples
- operational Project Number examples
- working API authentication
- working Company API retrieval
- working Contact API retrieval
- working Deal API retrieval
- working association retrieval
- working pagination metadata
- Git-safe credential handling

---

## Architecture Result

Phase 3 establishes HubSpot as the CRM source in the Aurelia architecture.

Current architecture:

HubSpot CRM
+
PostgreSQL Operations

These are now two independent operational source systems.

Future phases will extract data from these systems into the analytics platform.

Target direction:

HubSpot CRM
+
PostgreSQL Operations
→ ingestion
→ cloud landing
→ warehouse
→ dbt transformations
→ dimensional model
→ Power BI

---

## Phase 3 Outcome

Phase 3 is complete.

The Aurelia project now demonstrates:

- CRM source-system design
- synthetic CRM data creation
- sales pipeline modeling
- object relationships
- cross-system identifier strategy
- source-system data validation
- REST API fundamentals
- API authentication
- JSON responses
- pagination
- API associations
- secret management
- CRM-to-operations system boundaries

The project is now ready to move from source-system setup into data engineering and analytics.