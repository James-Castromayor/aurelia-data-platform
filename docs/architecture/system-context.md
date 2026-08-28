# Aurelia System Context

## Purpose

The Aurelia Enterprise Cloud Data & Analytics Platform provides an integrated data and analytics ecosystem for Aurelia Consulting Group.

It connects sales, project operations, resource management, finance, and business knowledge to provide trusted analytics and support business automation.

## Business Users

The platform supports the following primary user groups:

* Executives
* Sales teams
* Project managers
* Resource managers
* Consultants
* Finance teams
* Data and analytics teams
* Operations teams

## Major Business Systems

### HubSpot CRM

Supports the sales lifecycle, including:

* Companies
* Contacts
* Leads
* Opportunities
* Deals
* Sales pipeline

### Aurelia Operations Platform

Supports consulting operations, including:

* Clients
* Projects
* Employees
* Resource allocations
* Timesheets
* Project budgets
* Milestones

### Finance / ERP System

Represents Aurelia's financial processes, including:

* Customers
* Vendors
* Contracts
* Invoices
* Payments
* Accounts receivable
* Accounts payable
* General ledger
* Budgets
* Costs
* Revenue

The portfolio uses a synthetic finance system rather than a commercial ERP platform.

### Enterprise Data Platform

Integrates data from CRM, operations, finance, files, and external APIs.

It provides governed analytical datasets for reporting and downstream applications.

### Power BI

Provides executive and operational analytics based on trusted dimensional models produced by the Enterprise Data Platform.

### AI Business Assistant

Provides grounded access to structured business data and unstructured business documents.

The AI capability will be implemented only after the underlying data platform and governance mechanisms are established.

## External Sources

The architecture may also consume:

* CSV files
* Excel files
* External REST APIs
* Business documents

All portfolio data is synthetic.

## High-Level Context

```text
                         Aurelia Consulting Group

 ┌─────────────── BUSINESS USERS ─────────────────┐
 │                                                │
 │ Executives │ Sales │ PMs │ Finance │ Resources │
 │                                                │
 └──────────────────────┬─────────────────────────┘
                        │
            ┌───────────┼────────────┐
            │           │            │
            ▼           ▼            ▼
        HubSpot     Operations    Finance/ERP
          CRM        Platform      Synthetic
            │           │            │
            └───────────┼────────────┘
                        │
                        ▼
              Enterprise Data Platform
                        │
                 Trusted Analytics
                        │
               ┌────────┴────────┐
               ▼                 ▼
           Power BI        AI Assistant
```

## Architectural Principle

Operational systems remain responsible for running business transactions.

The Enterprise Data Platform integrates and transforms operational information into governed analytical data.

Analytics consumers should use the governed analytical layer rather than independently recreating business logic from operational source systems.
