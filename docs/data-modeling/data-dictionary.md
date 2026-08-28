# Aurelia Enterprise Data Dictionary

## 1. Purpose

This document defines the meaning of important business data elements used throughout the Aurelia Enterprise Cloud Data & Analytics Platform.

The dictionary will evolve as physical source and analytical models are implemented.

## 2. Core Business Terms

| Term                | Definition                                                            |
| ------------------- | --------------------------------------------------------------------- |
| Company             | Organization recorded in the CRM that may become a customer           |
| Contact             | Individual associated with a CRM company                              |
| Opportunity         | Potential commercial engagement pursued by Sales                      |
| Client              | Organization with an established commercial relationship with Aurelia |
| Contract            | Commercial agreement between Aurelia and a client                     |
| Project             | Consulting engagement performed for a client                          |
| Employee            | Worker providing client-facing or internal services                   |
| Skill               | Capability associated with an employee                                |
| Resource Allocation | Planned assignment of an employee to a project                        |
| Capacity            | Working time available to an employee                                 |
| Timesheet Entry     | Actual time recorded by an employee                                   |
| Project Budget      | Approved planned project expenditure                                  |
| Invoice             | Financial document requesting payment                                 |
| Invoice Line        | Individual billable component of an invoice                           |
| Payment             | Money received from a customer                                        |
| Payment Allocation  | Portion of a payment applied to an invoice                            |
| GL Account          | Account used to classify accounting transactions                      |
| GL Entry            | Individual debit or credit accounting posting                         |
| Cost Center         | Organizational unit used for cost reporting                           |
| Business Unit       | Organizational structure used for management reporting                |

## 3. Core Measures

| Measure             | Definition                                 |
| ------------------- | ------------------------------------------ |
| Capacity Hours      | Hours available for work                   |
| Planned Hours       | Hours allocated to planned project work    |
| Actual Hours        | Hours actually recorded                    |
| Billable Hours      | Actual hours eligible for client billing   |
| Utilization         | Billable Hours / Capacity Hours            |
| Revenue             | Recognized or analytically defined revenue |
| Project Cost        | Costs attributable to project delivery     |
| Gross Profit        | Revenue - Direct Project Cost              |
| Gross Margin        | Gross Profit / Revenue                     |
| Budget Variance     | Budget - Actual Cost                       |
| Pipeline Value      | Potential value of active opportunities    |
| Accounts Receivable | Amount invoiced but not yet collected      |
| Overdue Amount      | Unpaid invoice amount beyond its due date  |

## 4. Important Grain Definitions

| Dataset             | Grain                                         |
| ------------------- | --------------------------------------------- |
| Resource Allocation | Employee + Project + Planning Week            |
| Employee Capacity   | Employee + Work Date                          |
| Timesheet Entry     | Employee + Project/Activity + Work Date       |
| Project Budget      | Project + Budget Version + Category           |
| Invoice             | One invoice                                   |
| Invoice Line        | One line within an invoice                    |
| Payment             | One payment received                          |
| Payment Allocation  | Portion of one payment applied to one invoice |
| GL Entry            | One posting line within a journal             |

## 5. Identifier Terminology

| Identifier    | Meaning                                                            |
| ------------- | ------------------------------------------------------------------ |
| Source Key    | Identifier created by a source application                         |
| Business Key  | Stable business-recognizable identifier                            |
| Enterprise ID | Cross-system identifier used to represent the same business entity |
| Surrogate Key | Warehouse-generated analytical identifier                          |
| Primary Key   | Identifier uniquely identifying a row                              |
| Foreign Key   | Identifier referencing another entity                              |

## 6. Example Client Identity

A single real-world client may have:

```text
HubSpot Company ID
845923

Operations Client ID
CLI-000127

Finance Customer ID
CUST-00481

Enterprise Client ID
CLIENT-000127

Warehouse Client Key
1027
```

These identifiers serve different purposes and must not be treated as interchangeable.

## 7. Governance Principle

Business definitions should be documented once and reused consistently across:

* source systems
* ingestion pipelines
* Snowflake
* dbt
* Power BI
* APIs
* AI applications

Metrics must not silently change meaning between analytical products.
