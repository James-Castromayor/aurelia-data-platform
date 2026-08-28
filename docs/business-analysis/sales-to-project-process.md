# Sales-to-Project Business Process

## 1. Purpose

This document describes the current-state and target-state process for converting a successful Aurelia sales opportunity into an operational client and project.

---

## 2. Actors

The process involves:

* Sales Representative
* Sales Manager
* Project / Operations Team
* Finance Team
* HubSpot CRM
* Aurelia Operations Platform
* Enterprise Data Platform

---

## 3. As-Is Process

Aurelia currently operates with limited integration between sales, operations, finance, and reporting systems.

```text
Sales Representative
        │
        ▼
Create / update opportunity in CRM
        │
        ▼
Opportunity becomes Closed Won
        │
        ▼
Notify Operations manually
        │
        ▼
Operations manually creates client/project
        │
        ▼
Finance receives contract/project information
        │
        ▼
Finance manually creates financial records
        │
        ▼
Reporting teams extract information
from multiple systems
        │
        ▼
Manual reconciliation / spreadsheets
        │
        ▼
Management reporting
```

---

## 4. Current-State Problems

The As-Is process creates several risks:

* Duplicate data entry
* Delayed project creation
* Inconsistent customer identifiers
* Inconsistent project identifiers
* Missing information between systems
* Manual handoffs
* Spreadsheet dependency
* Difficult reconciliation
* Limited process visibility
* Delayed management reporting
* Increased operational error risk

---

## 5. To-Be Process

The target process introduces controlled system integration.

```text
Sales
  │
  ▼
HubSpot Deal
  │
  ▼
Deal = Closed Won
  │
  ▼
Integration / Automation
  │
  ├── Validate required information
  │
  ├── Check for existing client
  │
  └── Create integration event
  │
  ▼
Operations Platform
  │
  ├── Create / link client
  │
  └── Create project
  │
  ▼
Finance Process
  │
  └── Establish financial/project references
  │
  ▼
Enterprise Data Platform
  │
  ▼
Governed Analytical Models
  │
  ▼
Power BI / Business Analytics
```

---

# 6. Target Swimlane

```text
┌────────────────┬────────────────┬─────────────────┬────────────────┬──────────────────┐
│ Sales          │ CRM            │ Integration     │ Operations     │ Finance          │
├────────────────┼────────────────┼─────────────────┼────────────────┼──────────────────┤
│                │                │                 │                │                  │
│ Create         │                │                 │                │                  │
│ opportunity ──►│ Store deal     │                 │                │                  │
│                │                │                 │                │                  │
│ Progress       │                │                 │                │                  │
│ opportunity ──►│ Update stage   │                 │                │                  │
│                │                │                 │                │                  │
│ Close deal ───►│ Closed Won     │                 │                │                  │
│                │       │        │                 │                │                  │
│                │       └───────►│ Receive event   │                │                  │
│                │                │       │         │                │                  │
│                │                │ Validate data   │                │                  │
│                │                │       │         │                │                  │
│                │                │ Check client    │                │                  │
│                │                │       │         │                │                  │
│                │                │       └────────►│ Create/link    │                  │
│                │                │                 │ client         │                  │
│                │                │                 │       │        │                  │
│                │                │                 │ Create project │                  │
│                │                │                 │       │        │                  │
│                │                │                 │       └───────►│ Establish        │
│                │                │                 │                │ financial refs   │
│                │                │                 │                │                  │
└────────────────┴────────────────┴─────────────────┴────────────────┴──────────────────┘
```

---

## 7. System Ownership

| Business Object              | Primary System              |
| ---------------------------- | --------------------------- |
| Lead / Opportunity           | HubSpot CRM                 |
| Deal Stage                   | HubSpot CRM                 |
| Client operational record    | Aurelia Operations Platform |
| Project                      | Aurelia Operations Platform |
| Financial customer reference | Finance / ERP               |
| Invoice                      | Finance / ERP               |
| Analytical customer          | Enterprise Data Platform    |
| Analytical project           | Enterprise Data Platform    |

---

## 8. Integration Principle

Systems should not freely update each other's databases.

Integration should occur through controlled interfaces such as:

* APIs
* Webhooks
* Integration workflows
* Scheduled data pipelines

Each business entity should have a clearly defined system of record.

Cross-system identifiers should be retained where required to support traceability.

---

## 9. Example Identifier Mapping

A single customer may have different technical identifiers across systems.

```text
HubSpot
Company ID: 845923

        ↓

Operations
Client ID: CLI-000127

        ↓

Finance
Customer ID: CUST-00481

        ↓

Analytics
Client Key: 1027
```

The Enterprise Data Platform will maintain the relationships necessary to provide a unified analytical view without requiring all operational systems to use the same physical primary key.

---

## 10. Expected Business Benefits

The target process should provide:

* Faster project setup
* Reduced duplicate entry
* Improved data consistency
* Better cross-system traceability
* Reduced manual handoffs
* Improved reporting timeliness
* Better integration monitoring
* Clearer system ownership
